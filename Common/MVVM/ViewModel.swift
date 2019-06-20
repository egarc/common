//
//  ViewModel.swift
//  Reddit
//
//  Created by Eric Garcia on 5/29/19.
//  Copyright © 2019 Eric Garcia. All rights reserved.
//

import Foundation

open class ViewModel<State: ViewState>: Store<State> {

    /// A set of views that subscribes to the view model.
    private var views = Set<AnyStatefulView<State>>()

    /// This should only be changed by subclasses. It shouldn't be accessed directly from views; views
    /// should only access this state via the render method.
    override public var state: State {
        didSet(oldState) {
            views.forEach {
                stateDidChange(oldState: oldState, newState: state, view: $0)
            }
        }
    }

    /// Subscribes the view to receive view state changes.
    ///
    /// - Parameter view: The view.
    /// - Returns: A unique identifier used that can be used to unsubscribe the view. Unless you
    /// are manually handling subscription, this can be ignored.
    @discardableResult
    public func subscribe<V: StatefulView>(from view: V) -> String where V.State == State {
        let anyView = AnyStatefulView(view)
        if views.insert(anyView).inserted {
            stateDidChange(oldState: state, newState: state, view: anyView, force: true)
        } else {
            #if DEBUG
            fatalError("Trying to subscribe from an already subscribed view.")
            #endif
        }

        return anyView.identifier
    }

    /// Unsubscribes the view from receiving view state changes.
    ///
    /// - Parameter identifier: The unique identifier of the view.
    public func unsubscribe(viewWithIdentifier identifier: String) {
        guard let index = views.firstIndex(where: { $0.identifier == identifier }) else {
            fatalError("Trying to unsubscribe from a not subscribed view.")
        }
        views.remove(at: index)
    }

}

private extension ViewModel {

    /// Notifies the view that the view state has changed depending on its render policy.
    ///
    /// - Parameters:
    ///   - oldState: The previous view state.
    ///   - newState: The new view state.
    ///   - view: The subscribing view.
    ///   - force: Whether or not to force updates even if the view state hasn't actually changed.
    func stateDidChange(oldState: State, newState: State, view: AnyStatefulView<State>, force: Bool = false) {
        switch view.renderPolicy {
        case .possible:
            handlePossibleRender(newState: newState, oldState: oldState, view: view, force: force)
        case .notPossible(let renderError):
            handleNotPossibleRender(error: renderError, view: view)
        }
    }

    func handlePossibleRender(newState: State, oldState: State, view: AnyStatefulView<State>, force: Bool) {
        let viewLogDescription = view.logDescription

        if !force && newState == oldState {
            Logger.log("[\(viewLogDescription)] Skip rendering with the same state: \(newState.logDescription)")
            return
        }

        Logger.log("[\(viewLogDescription)] Render with state: \(newState.logDescription)")

        let renderBlock = {
            view.render(state: newState)
        }

        if Thread.isMainThread {
            renderBlock()
        } else {
            DispatchQueue.main.async(execute: renderBlock)
        }
    }

    func handleNotPossibleRender(error: RenderPolicy.RenderError, view: AnyStatefulView<State>) {
        switch error {
        case .viewNotReady:
            #if DEBUG
                fatalError("[\(view.logDescription)] Render error: view not ready to be rendered")
            #endif
        case .viewDeallocated:
            Logger.log("[\(view.logDescription)] Render error: view deallocated")
            views.remove(view)
        }
    }

}

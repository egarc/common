//
//  AnyStatefulView.swift
//  Reddit
//
//  Created by Eric Garcia on 6/1/19.
//  Copyright © 2019 Eric Garcia. All rights reserved.
//

import Foundation

/// This class uses type erasure to link a common state between a view and its view model. It holds
/// a weak reference to the view.
public class AnyStatefulView<T: ViewState>: StatefulView {

    let identifier: String = UUID().uuidString

    private let _logDescription: () -> String

    private let _render: (T) -> Void

    private let _renderPolicy: () -> RenderPolicy

    // MARK: -
    // MARK: Initialization

    init<U: StatefulView>(_ statefulView: U) where U.State == T {
        _logDescription = { [weak statefulView] in
            statefulView?.logDescription ?? "Deallocated view"
        }

        _render = { [weak statefulView] state in
            statefulView?.render(state: state)
        }

        _renderPolicy = { [weak statefulView] in
            statefulView?.renderPolicy ?? .notPossible(.viewDeallocated)
        }
    }

}

// MARK: -
// MARK: StatefulView

extension AnyStatefulView {

    public var logDescription: String {
        return _logDescription()
    }

    public var renderPolicy: RenderPolicy {
        return _renderPolicy()
    }

    public func render(state: T) {
        guard renderPolicy.canBeRendered else {
            fatalError("View is not ready to be rendered.")
        }
        _render(state)
    }

}

// MARK: -
// MARK: Hashable

extension AnyStatefulView: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    public static func ==(lhs: AnyStatefulView, rhs: AnyStatefulView) -> Bool {
        return lhs.identifier == rhs.identifier
    }

}


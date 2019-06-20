//
//  Store.swift
//  Reddit
//
//  Created by Eric Garcia on 5/29/19.
//  Copyright © 2019 Eric Garcia. All rights reserved.
//

import Foundation

open class Store<State: DomainState> {

    // MARK: -
    // MARK: Public Properties

    /// Any changes to the domain state get tracked here. Do not set outside of a `write` block.
    public var state: State {
        didSet(oldState) {
            stateDidChange(oldState: oldState, newState: state)
        }
    }

    // MARK: -
    // MARK: Private Properties

    /// Holds weak references to store subscriptions.
    private var subscriptions: [ObjectIdentifier: Weak<StoreSubscription<State>>] = [:]

    /// Holds subscriptions to other stores including child stores.
    private var otherStoreSubscriptions: [ObjectIdentifier: AnyObject] = [:]

    /// This synchonous queue avoids conflicts.
    private let operationQueue: OperationQueue

    // MARK: -
    // MARK: Initialization

    public init(initialState: State) {
        state = initialState

        operationQueue = OperationQueue()
        operationQueue.name = "\(type(of: self)).OperationQueue"
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInitiated
    }

    // MARK: -
    // MARK: Methods

    /// All states changes must occur within the write transaction.
    ///
    /// - Parameter block: The block containing the state change.
    public func write(_ block: @escaping () -> Void) {
        operationQueue.addOperation(block)
    }

    /// Subscribes to this store. The block will be called when the state updates. As the subscription
    /// is not retained within this store to avoid retain cycles, you are responsible for retaining it
    /// as needed.
    ///
    /// - Parameter block: The block that is called when the state updates.
    /// - Returns: An unretained store subscription.
    public func subscribe(_ block: @escaping ((State) -> Void)) -> StoreSubscription<State> {
        let subscription = StoreSubscription<State>(block: block)
        let objectIdentifier = ObjectIdentifier(subscription)
        subscriptions[objectIdentifier] = Weak<StoreSubscription<State>>(value: subscription)
        subscription.fire(state)
        return subscription
    }

    /// Helper method to subscribe to child stores. The subscription tokens are strongly retained.
    ///
    /// - Parameters:
    ///   - store: The store to subscribe to.
    ///   - block: The block to execute each time the state changes in the child store.
    public func subscribe<T>(to store: Store<T>, block: @escaping (T) -> Void) {
        let storeIdentifier = ObjectIdentifier(store)

        #if DEBUG
        if otherStoreSubscriptions[storeIdentifier] != nil {
            fatalError("Trying to subscribe to an already subscribed store.")
        }
        #endif

        otherStoreSubscriptions[storeIdentifier] = store.subscribe(block)
    }

    /// Helper method to unsubscribe to a child store.
    ///
    /// - Parameter store: The child store.
    public func unsubscribe<T>(from store: Store<T>) {
        let storeIdentifier = ObjectIdentifier(store)

        #if DEBUG
        if otherStoreSubscriptions[storeIdentifier] == nil {
            fatalError("Trying to unsubscribe from an already unsubscribed store.")
        }
        #endif

        otherStoreSubscriptions[storeIdentifier] = nil
    }

}

private extension Store {

    /// Notifies subscribers of a state change provided the old state is different from the new state.
    ///
    /// - Parameters:
    ///   - oldState: The old state.
    ///   - newState: The new state.
    func stateDidChange(oldState: State, newState: State) {
        guard oldState != newState else {
            Logger.log("State did not change: \(oldState.logDescription)")
            return
        }

        Logger.log("[\(logDescription)] State change: \(newState.logDescription)")

        if Thread.isMainThread {
            fireAllSubscriptions(state: newState)
        } else {
            DispatchQueue.main.async { self.fireAllSubscriptions(state: newState) }
        }
    }

    /// Fires the state change block for all subscribers.
    ///
    /// - Parameter state: The new state.
    func fireAllSubscriptions(state: State) {
        for subscription in subscriptions.values {
            subscription.value?.fire(state)
        }
    }

}

// MARK: -
// MARK: Logging

extension Store: Loggable {

    public var logDescription: String {
        return String(describing: type(of: self))
    }

}

// MARK: -
// MARK: Weak Reference Wrapper

private class Weak<T: AnyObject> {

    weak var value: T?

    init(value: T?) {
        self.value = value
    }

}

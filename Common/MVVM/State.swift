//
//  State.swift
//  Reddit
//
//  Created by Eric Garcia on 5/29/19.
//  Copyright © 2019 Eric Garcia. All rights reserved.
//

/// The business logic used in stores.
public protocol DomainState: Equatable, Loggable {}

/// The view logic used in view models, converted from domain state.
public protocol ViewState: DomainState {}

public extension Equatable where Self: DomainState {

    static func ==(lhs: Self, rhs: Self) -> Bool {
        return false
    }

}

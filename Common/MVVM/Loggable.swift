//
//  Loggable.swift
//  Reddit
//
//  Created by Eric Garcia on 5/29/19.
//  Copyright © 2019 Eric Garcia. All rights reserved.
//

public protocol Loggable {

    /// A detailed string used for logging purposes.
    var logDescription: String { get }

}

// MARK: -
// MARK: Default Implementation

public extension Loggable {

    var logDescription: String {
        return String(describing: self)
    }

}

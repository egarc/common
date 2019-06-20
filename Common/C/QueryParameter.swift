//
//  QueryParameter.swift
//  Reddit
//
//  Created by Eric Garcia on 6/17/19.
//  Copyright © 2019 Eric Garcia. All rights reserved.
//

import Foundation

public struct QueryParameter : RawRepresentable, Equatable, Hashable {

    public var rawValue: String

    public var hashValue: Int {
        return rawValue.hashValue
    }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

}

// MARK: - Query Definitions

public extension QueryParameter {

}

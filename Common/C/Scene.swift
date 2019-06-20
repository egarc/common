//
//  Scene.swift
//  Reddit
//
//  Created by Eric Garcia on 6/17/19.
//  Copyright © 2019 Eric Garcia. All rights reserved.
//

import Foundation

struct Scene : RawRepresentable, Equatable, Hashable {

    public var rawValue: String

    public var hashValue: Int {
        return rawValue.hashValue
    }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

}

extension Scene {

    static let home = Scene(rawValue: "home")

    static let favorites = Scene(rawValue: "favorites")

}

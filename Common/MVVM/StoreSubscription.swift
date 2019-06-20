//
//  StoreSubscription.swift
//  Reddit
//
//  Created by Eric Garcia on 6/18/19.
//  Copyright © 2019 Eric Garcia. All rights reserved.
//

import Foundation

/// The store subscription links a subscribing object to a store using a block. A store holds this
/// subscription and calls the block when state changes until the subscription and underlying block
/// are released.
public class StoreSubscription<State> {

    private(set) var block: ((State) -> Void)?

    init(block: @escaping ((State) -> Void)) {
        self.block = block
    }

    func fire(_ state: State) {
        block?(state)
    }

    func stop() {
        block = nil
    }

    deinit {
        block = nil
    }

}

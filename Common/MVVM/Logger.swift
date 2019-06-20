//
//  Log.swift
//  Reddit
//
//  Created by Eric Garcia on 5/30/19.
//  Copyright © 2019 Eric Garcia. All rights reserved.
//

import Foundation
import os

public class Logger {

    static var enabled = true

    /// Logs the given string to console.
    ///
    /// - Parameter text: The text to log.
    static func log(_ text: @autoclosure () -> String) {
        guard enabled else { return }
        
        #if DEBUG
        os_log("%@", type: .debug, text())
        #endif
    }

}

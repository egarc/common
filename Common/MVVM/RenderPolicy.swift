//
//  RenderPolicy.swift
//  Reddit
//
//  Created by Eric Garcia on 6/1/19.
//  Copyright © 2019 Eric Garcia. All rights reserved.
//

/// Describes conditions of a view or view controller with regard to whether it can render or not.
///
/// - possible: The view or view controller can render.
/// - notPossible: The view or view controller is unable to render.
public enum RenderPolicy {

    case possible

    case notPossible(RenderError)

    /// Describes why a view or view controller is unable to render.
    ///
    /// - viewNotReady: The view controller has not been loaded or the view has no superview.
    /// - viewDeallocated: The view or view controller has been deallocated.
    public enum RenderError {

        case viewNotReady

        case viewDeallocated
    }

    /// A convenience accessor describing if the view or view controller can be rendered.
    var canBeRendered: Bool {
        switch self {
        case .possible:
            return true
        case .notPossible:
            return false
        }
    }
}

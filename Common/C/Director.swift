//
//  Director.swift
//  Reddit
//
//  Created by Eric Garcia on 6/17/19.
//  Copyright © 2019 Eric Garcia. All rights reserved.
//

import Foundation

class Director {

    // MARK: -
    // MARK: Apps

    static let reddit: Director = Director(
        scenes: [
        ],
        queryParameters: [
        ])

    /// The app's URL scheme. Only URLs that match this scheme will be parsed.
    let scheme: String = externalURLScheme()

    /// Only scenes in this dictionary will be parsed.
    let scenes: [String : Scene]

    /// Only query parameters in this dictionary will be parsed.
    let queryParameters: [String : QueryParameter]

    // MARK: -
    // MARK: Initialization

    /// Initialize a new Director instance with given scenes and query parameters.
    ///
    /// - Parameters:
    ///   - scenes: The scenes to look for in URL paths.
    ///   - queryParameters: The query parameters to look out for in URLs.
    init(scenes: [Scene], queryParameters: [QueryParameter]) {
        self.scenes = arrayToDictionary(scenes)
        self.queryParameters = arrayToDictionary(queryParameters)
    }

    /// Returns true if the URL matches the scheme and contains at least one scene.
    ///
    /// - Parameter url: The URL that we are attempting to handle.
    /// - Returns: True if the URL can be handled.
    func canHandle(url: URL) -> Bool {
        guard url.scheme == scheme, let host = url.host, let _ = scenes[host] else {
            return false
        }

        return true
    }

    /// Parses scenes from a URL and also provides a callback to handle any query parameters.
    ///
    /// - Parameters:
    ///   - url: The URL to parse.
    ///   - handleQuery: A block that receives a dictionary of query parameters given that there
    /// are matching query parameters found in the URL.
    /// - Returns: An array of scenes parsed from the URL.
    func scenes(fromURL url: URL, handleQuery: (([QueryParameter : String]) -> Void)?) -> [Scene] {
        guard canHandle(url: url) else { return [] }

        var returnScenes: [Scene] = []

        if let host = url.host, let scene = scenes[host] {
            returnScenes.append(scene)
        }

        for component in url.pathComponents where component != "/" {
            if let scene = scenes[component] {
                returnScenes.append(scene)
            } else {
                break
            }
        }

        if let queryComponents = url.query?.components(separatedBy: "&") {
            var queryDictionary: [QueryParameter : String] = [:]
            for keyValuePair in queryComponents {
                let pairComponents = keyValuePair.components(separatedBy: "=")
                if let key = pairComponents.first, let value = pairComponents.last {
                    if let param = queryParameters[key] {
                        queryDictionary[param] = value
                    }
                }
            }

            if !queryDictionary.isEmpty {
                handleQuery?(queryDictionary)
            }
        }


        return returnScenes
    }

    /// Creates a new URL with the given scenes and query parameters. This URL can be passed into
    /// `scenes(fromURL:handleQuery)` to generate the scenes and handle the parameters.
    ///
    /// - Parameters:
    ///   - scenes: The scenes to use to create a new URL.
    ///   - parameters: The query parameters used to create a new URL.
    /// - Returns: The generated URL.
    func url(forScenes scenes: [Scene], parameters: [QueryParameter : String] = [:]) -> URL? {
        var sceneUrl = "\(scheme)://"

        sceneUrl.append(scenes.map { $0.rawValue }.joined(separator: "/"))

        if !parameters.isEmpty {
            sceneUrl.append("?")
            let query = parameters.map { "\($0.rawValue)=\($1)" }.joined(separator: "&")
            sceneUrl.append(query)
        }

        return URL(string: sceneUrl)
    }

}

// MARK: -
// MARK: Private Helpers

/// Takes an array of `RawRepresentable` objects, where the RawValue is a String, and returns
/// a dictionary of those `RawRepresentable` objects keyed by their raw strings values.
///
/// - Parameter array: The array to turn into a dictionary.
/// - Returns: A new dictionary with the `RawRepresentable.rawValue` as keys and the
/// `RawRepresentable` as values.
private func arrayToDictionary<T: RawRepresentable>(_ array: [T]) -> [String : T] where T.RawValue == String {
    return array.reduce([:]) { running, representable in
        var newRunning = running
        newRunning[representable.rawValue] = representable
        return newRunning
    }
}

/// The current URL scheme e.g. "com.ericgarcia.reddit"
///
/// - Returns: The current URL scheme.
func externalURLScheme() -> String {
    guard
        let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [AnyObject],
        let urlTypeDictionary = urlTypes.first as? [String: AnyObject],
        let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as? [AnyObject],
        let externalURLScheme = urlSchemes.first as? String else {
            return ""
    }

    return externalURLScheme
}

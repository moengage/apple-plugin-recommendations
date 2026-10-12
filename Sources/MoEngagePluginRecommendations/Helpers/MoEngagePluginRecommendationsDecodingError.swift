//
//  MoEngagePluginRecommendationsDecodingError.swift
//  MoEngagePluginRecommendations
//
//  Created by Rakshitha on 24/09/26.
//

import Foundation

struct MoEngagePluginRecommendationsDecodingError: Error, CustomStringConvertible {
    let key: String
    let data: Any
    let function: String

    init(key: String, data: Any, function: String = #function) {
        self.key = key
        self.data = data
        self.function = function
    }

    var description: String {
        "Failed to decode \(key) in data: \(data) at \(function)"
    }
}

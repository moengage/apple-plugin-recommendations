//
//  MoEngageRecommendedItems+Encode.swift
//  MoEngagePluginRecommendations
//
//  Created by Rakshitha on 24/09/26.
//

import MoEngageRecommendations

extension MoEngageRecommendedItems {
    enum HybridKeys {
        static let items = MoEngagePluginRecommendationsConstants.items
    }

    /// Item attributes are catalog defined and passed through verbatim.
    func encodeForHybrid() -> [String: Any] {
        return [
            HybridKeys.items: self.items
        ]
    }
}

//
//  MoEngageRecommendationsFetchData.swift
//  MoEngagePluginRecommendations
//
//  Created by Rakshitha on 24/09/26.
//

import Foundation

struct MoEngageRecommendationsFetchData {
    enum HybridKeys {
        static let recommendationId = MoEngagePluginRecommendationsConstants.recommendationId
        static let itemId = MoEngagePluginRecommendationsConstants.itemId
        static let includedFields = MoEngagePluginRecommendationsConstants.includedFields
    }

    let recommendationId: String
    let itemId: String
    let includedFields: Set<String>

    /// Blank values are passed through as-is; the native SDK owns their validation
    /// (a blank `recommendationId` rejects with `invalidRequest`).
    ///
    /// Optional keys default only when absent; a present value of the wrong type throws.
    static func decodeFromHybrid(_ data: [String: Any]) throws -> Self {
        guard let recommendationId = data[HybridKeys.recommendationId] as? String else {
            throw MoEngagePluginRecommendationsDecodingError(key: HybridKeys.recommendationId, data: data)
        }

        let itemId: String = try MoEngagePluginRecommendationsUtil.decodeOptional(HybridKeys.itemId, from: data) ?? ""
        let includedFields: [String] = try MoEngagePluginRecommendationsUtil.decodeOptional(HybridKeys.includedFields, from: data) ?? []
        return self.init(
            recommendationId: recommendationId,
            itemId: itemId,
            includedFields: Set(includedFields)
        )
    }
}

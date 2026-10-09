//
//  MoEngagePluginRecommendationsConstants.swift
//  MoEngagePluginRecommendations
//
//  Created by Rakshitha on 24/09/26.
//

import Foundation

enum MoEngagePluginRecommendationsConstants {
    static let moduleTag = "MoEngagePluginRecommendations"

    static let recommendationId = "recommendationId"
    static let itemId = "itemId"
    static let includedFields = "includedFields"
    static let items = "items"

    // Failure payload keys: `{ accountMeta, data: { reason, message } }`.
    static let reason = "reason"
    static let message = "message"

    /// Recommendations specific failure reasons reported to the hybrid layer. Common reasons
    /// come from `MoEngagePluginConstants.FailureReason`. Values must match
    /// `RecommendationsFailureReason` in the hybrid platform interfaces.
    enum FailureReason {
        static let invalidRequest = "INVALID_REQUEST"
        static let payloadTooLarge = "PAYLOAD_TOO_LARGE"
        static let rateLimitExceeded = "RATE_LIMIT_EXCEEDED"
        static let internalServerError = "INTERNAL_SERVER_ERROR"
    }
}

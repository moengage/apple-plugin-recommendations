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

    // Failure payload keys, matching the personalize plugin's error payload.
    static let error = "error"
    static let code = "code"
    static let message = "message"

    /// Failure reasons reported to the hybrid layer. Values must match
    /// `RecommendationsFailureReason` in the hybrid platform interfaces.
    enum FailureReason {
        static let invalidRequest = "INVALID_REQUEST"
        static let payloadTooLarge = "PAYLOAD_TOO_LARGE"
        static let rateLimitExceeded = "RATE_LIMIT_EXCEEDED"
        static let internalServerError = "INTERNAL_SERVER_ERROR"
        static let featureDisabled = "FEATURE_DISABLED"
        static let sdkState = "SDK_STATE"
        static let networkError = "NETWORK_ERROR"
        static let parseError = "PARSE_ERROR"
        static let unknownError = "UNKNOWN_ERROR"
    }
}

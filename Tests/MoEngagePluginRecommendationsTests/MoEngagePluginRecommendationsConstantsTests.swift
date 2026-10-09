//
//  MoEngagePluginRecommendationsConstantsTests.swift
//  MoEngagePluginRecommendationsTests
//
//  Created by Rakshitha on 01/10/26.
//

import Testing
import MoEngagePluginBase
@testable import MoEngagePluginRecommendations

@Suite("Recommendations constants")
struct MoEngagePluginRecommendationsConstantsTests {

    typealias Constants = MoEngagePluginRecommendationsConstants

    static let failureReasons = [
        Constants.FailureReason.invalidRequest,
        Constants.FailureReason.payloadTooLarge,
        Constants.FailureReason.rateLimitExceeded,
        Constants.FailureReason.internalServerError
    ]

    static let commonFailureReasons = [
        MoEngagePluginConstants.FailureReason.sdkState,
        MoEngagePluginConstants.FailureReason.featureDisabled,
        MoEngagePluginConstants.FailureReason.networkError,
        MoEngagePluginConstants.FailureReason.parseError,
        MoEngagePluginConstants.FailureReason.invalidParameters,
        MoEngagePluginConstants.FailureReason.serverError,
        MoEngagePluginConstants.FailureReason.authenticationFailed,
        MoEngagePluginConstants.FailureReason.unknownError
    ]

    @Test("Payload keys match the hybrid contract")
    func payloadKeys() {
        #expect(Constants.recommendationId == "recommendationId")
        #expect(Constants.itemId == "itemId")
        #expect(Constants.includedFields == "includedFields")
        #expect(Constants.items == "items")
        #expect(Constants.reason == "reason")
        #expect(Constants.message == "message")
    }

    @Test("Failure reasons match the hybrid contract")
    func failureReasonValues() {
        #expect(Constants.FailureReason.invalidRequest == "INVALID_REQUEST")
        #expect(Constants.FailureReason.payloadTooLarge == "PAYLOAD_TOO_LARGE")
        #expect(Constants.FailureReason.rateLimitExceeded == "RATE_LIMIT_EXCEEDED")
        #expect(Constants.FailureReason.internalServerError == "INTERNAL_SERVER_ERROR")
    }

    @Test("Failure reasons are unique and non-empty, and do not clash with the common reasons")
    func failureReasonsUniqueAndNonEmpty() {
        let allReasons = Self.failureReasons + Self.commonFailureReasons
        #expect(Self.failureReasons.allSatisfy { !$0.isEmpty })
        #expect(Set(allReasons).count == allReasons.count)
    }
}

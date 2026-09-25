//
//  MoEngageRecommendationsFailureMappingTests.swift
//  MoEngagePluginRecommendationsTests
//
//  Created by Rakshitha on 25/09/26.
//

import Testing
import MoEngageCore
import MoEngageRecommendations
@testable import MoEngagePluginRecommendations

@Suite("Recommendations failure mapping")
struct MoEngageRecommendationsFailureMappingTests {

    @Test(
        "Module codes map to hybrid reasons",
        arguments: [
            (MoEngageRecommendationsRequestFailureReason.ModuleCode.invalidRequest, "INVALID_REQUEST"),
            (.payloadTooLarge, "PAYLOAD_TOO_LARGE"),
            (.rateLimitExceeded, "RATE_LIMIT_EXCEEDED"),
            (.internalServerError, "INTERNAL_SERVER_ERROR"),
            (.unknownError, "UNKNOWN_ERROR")
        ]
    )
    func moduleCodeMapping(
        moduleCode: MoEngageRecommendationsRequestFailureReason.ModuleCode,
        expectedReason: String
    ) {
        let failure = MoEngageRequestFailure(
            reason: MoEngageRecommendationsRequestFailureReason(moduleCode: moduleCode)
        )
        #expect(failure.toHybridPayload(forIdentifier: "some_id").errorCode == expectedReason)
    }

    @Test(
        "Shared codes map to hybrid reasons",
        arguments: [
            (MoEngageRequestFailureReason.Code.sdkNotInitialized, "SDK_STATE"),
            (.featureDisabled, "FEATURE_DISABLED"),
            (.networkError, "NETWORK_ERROR"),
            (.parseError, "PARSE_ERROR"),
            (.invalidParameters, "INVALID_REQUEST"),
            (.serverError, "UNKNOWN_ERROR"),
            (.authenticationFailed, "UNKNOWN_ERROR"),
            (.requiredPermissionMissing, "UNKNOWN_ERROR"),
            (.cancelled, "UNKNOWN_ERROR"),
            (.unknownError, "UNKNOWN_ERROR")
        ]
    )
    func sharedCodeMapping(code: MoEngageRequestFailureReason.Code, expectedReason: String) {
        let failure = MoEngageRequestFailure(reason: MoEngageRequestFailureReason(code: code))
        #expect(failure.toHybridPayload(forIdentifier: "some_id").errorCode == expectedReason)
    }

    @Test("Module reason without a module code uses the shared mapping")
    func moduleReasonWithSharedCode() {
        let failure = MoEngageRequestFailure(
            reason: MoEngageRecommendationsRequestFailureReason(code: .featureDisabled),
            message: "Recommendations is blocked"
        )
        let payload = failure.toHybridPayload(forIdentifier: "some_id")
        #expect(payload.errorCode == "FEATURE_DISABLED")
        #expect(payload.errorMessage == "Recommendations is blocked")
    }

    @Test("Empty native message falls back to the reason description")
    func emptyMessageFallback() {
        let failure = MoEngageRequestFailure(
            reason: MoEngageRecommendationsRequestFailureReason(moduleCode: .invalidRequest)
        )
        #expect(failure.toHybridPayload(forIdentifier: "some_id").errorMessage?.isEmpty == false)
    }
}

private extension Dictionary where Key == String, Value == Any {
    var errorCode: String? { (self["error"] as? [String: Any])?["code"] as? String }
    var errorMessage: String? { (self["error"] as? [String: Any])?["message"] as? String }
}

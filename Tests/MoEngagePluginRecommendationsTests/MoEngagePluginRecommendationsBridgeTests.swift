//
//  MoEngagePluginRecommendationsBridgeTests.swift
//  MoEngagePluginRecommendationsTests
//
//  Created by Rakshitha on 25/09/26.
//

import Foundation
import Testing
import MoEngageCore
import MoEngageRecommendations
import MoEngagePluginBase
@testable import MoEngagePluginRecommendations

@Suite("Recommendations bridge")
struct MoEngagePluginRecommendationsBridgeTests {

    let appId = "some_id"
    let mockHandler = MockMoEngagePluginRecommendationsBridgeHandler()

    func fetchPayload(_ data: [String: Any]) -> [String: Any] {
        return [
            MoEngagePluginConstants.General.accountMeta: ["appId": appId],
            MoEngagePluginConstants.General.data: data
        ]
    }

    /// Invokes the bridge and returns what the completion handler received.
    /// The mock handler calls back synchronously, so the result is available on return.
    func fetchRecommendations(_ payload: [String: Any]) throws -> [String: Any] {
        var result: [String: Any]?
        var completionCount = 0
        let bridge = MoEngagePluginRecommendationsBridge(handler: mockHandler)
        bridge.fetchRecommendations(payload) { response in
            completionCount += 1
            result = response
        }
        #expect(completionCount == 1, "Completion must be invoked exactly once")
        return try #require(result)
    }

    /// The `error` block of a failure payload: `{ code, message }`.
    func error(in payload: [String: Any]) -> [String: Any]? {
        return payload["error"] as? [String: Any]
    }

    func appId(in payload: [String: Any]) -> String? {
        let accountMeta = payload[MoEngagePluginConstants.General.accountMeta] as? [String: Any]
        return accountMeta?["appId"] as? String
    }

    @Test("Missing account data settles with UNKNOWN_ERROR without calling native")
    func invalidAccountData() throws {
        let result = try fetchRecommendations([:])

        #expect(mockHandler.fetchRecommendationsCallCount == 0)
        #expect(result["accountMeta"] == nil)
        #expect(error(in: result)?["code"] as? String == "UNKNOWN_ERROR")
    }

    @Test("Missing recommendationId settles with INVALID_REQUEST without calling native")
    func missingRecommendationId() throws {
        let result = try fetchRecommendations(fetchPayload(["itemId": "shirts"]))

        #expect(mockHandler.fetchRecommendationsCallCount == 0)
        #expect(error(in: result)?["code"] as? String == "INVALID_REQUEST")
        #expect(appId(in: result) == appId)
    }

    @Test("Missing data block settles with INVALID_REQUEST without calling native")
    func missingData() throws {
        let result = try fetchRecommendations([
            MoEngagePluginConstants.General.accountMeta: ["appId": appId]
        ])

        #expect(mockHandler.fetchRecommendationsCallCount == 0)
        #expect(error(in: result)?["code"] as? String == "INVALID_REQUEST")
    }

    @Test("Input is passed to native with duplicate included fields dropped")
    func passesInputToNative() throws {
        _ = try fetchRecommendations(
            fetchPayload([
                "recommendationId": "clothing",
                "itemId": "shirts",
                "includedFields": ["size", "color", "size"]
            ])
        )

        let input = try #require(mockHandler.lastInput)
        #expect(mockHandler.fetchRecommendationsCallCount == 1)
        #expect(input.recommendationId == "clothing")
        #expect(input.itemId == "shirts")
        #expect(input.includedFields == ["size", "color"])
        #expect(input.workspaceId == appId)
    }

    @Test("Optional input defaults to empty values")
    func defaultsOptionalInput() throws {
        _ = try fetchRecommendations(fetchPayload(["recommendationId": "clothing"]))

        let input = try #require(mockHandler.lastInput)
        #expect(input.recommendationId == "clothing")
        #expect(input.itemId == "")
        #expect(input.includedFields.isEmpty)
    }

    @Test("Blank recommendationId is passed through for native to validate")
    func blankRecommendationIdPassedThrough() throws {
        _ = try fetchRecommendations(fetchPayload(["recommendationId": ""]))

        let input = try #require(mockHandler.lastInput)
        #expect(input.recommendationId == "")
    }

    @Test("Success response follows the nativeToHybrid contract")
    func success() throws {
        mockHandler.result = .success(
            MoEngageRecommendedItems(items: [
                ["product_id": "product_001", "price": NSNumber(value: 199.99)],
                ["product_id": "product_002", "sizes": [Optional<String>.some("M"), nil] as [(any Sendable)?]]
            ])
        )

        let result = try fetchRecommendations(fetchPayload(["recommendationId": "clothing"]))

        #expect(error(in: result) == nil)
        #expect(appId(in: result) == appId)
        let data = try #require(result[MoEngagePluginConstants.General.data] as? [String: Any])
        let items = try #require(data["items"] as? [[String: Any]])
        #expect(items.count == 2)
        #expect(items[0]["product_id"] as? String == "product_001")
        #expect(items[0]["price"] as? Double == 199.99)
        #expect(JSONSerialization.isValidJSONObject(result))
    }

    @Test("Empty items is a success, not a failure")
    func emptySuccess() throws {
        mockHandler.result = .success(MoEngageRecommendedItems(items: []))

        let result = try fetchRecommendations(fetchPayload(["recommendationId": "clothing"]))

        #expect(error(in: result) == nil)
        let data = try #require(result[MoEngagePluginConstants.General.data] as? [String: Any])
        #expect((data["items"] as? [Any])?.isEmpty == true)
    }

    @Test("Native failure is reported as { accountMeta, error: { code, message } }")
    func moduleFailure() throws {
        mockHandler.result = .failure(
            MoEngageRequestFailure(
                reason: MoEngageRecommendationsRequestFailureReason(moduleCode: .rateLimitExceeded),
                message: "Rate limit exceeded"
            )
        )

        let result = try fetchRecommendations(fetchPayload(["recommendationId": "clothing"]))

        #expect(error(in: result)?["code"] as? String == "RATE_LIMIT_EXCEEDED")
        #expect(error(in: result)?["message"] as? String == "Rate limit exceeded")
        #expect(appId(in: result) == appId)
        #expect(result["data"] == nil)
        #expect(JSONSerialization.isValidJSONObject(result))
    }
}

final class MockMoEngagePluginRecommendationsBridgeHandler: MoEngagePluginRecommendationsBridgeHandler {
    struct Input {
        let recommendationId: String
        let itemId: String
        let includedFields: Set<String>
        let workspaceId: String?
    }

    enum Result {
        case success(MoEngageRecommendedItems)
        case failure(MoEngageRequestFailure)
    }

    /// Outcome delivered synchronously to the bridge; `nil` leaves the request pending.
    var result: Result? = .success(MoEngageRecommendedItems(items: []))
    private(set) var fetchRecommendationsCallCount = 0
    private(set) var lastInput: Input?

    func fetchRecommendations(
        recommendationId: String,
        itemId: String,
        includedFields: Set<String>,
        workspaceId: String?,
        onSuccess: @escaping (MoEngageRecommendedItems) -> Void,
        onFailure: @escaping (MoEngageRequestFailure) -> Void
    ) {
        fetchRecommendationsCallCount += 1
        lastInput = Input(
            recommendationId: recommendationId,
            itemId: itemId,
            includedFields: includedFields,
            workspaceId: workspaceId
        )
        switch result {
        case let .success(items):
            onSuccess(items)
        case let .failure(failure):
            onFailure(failure)
        case .none:
            break
        }
    }
}

//
//  MoEngagePluginRecommendationsSDKAdapterTests.swift
//  MoEngagePluginRecommendationsTests
//
//  Created by Rakshitha on 05/10/26.
//

import Foundation
import Testing
import MoEngageCore
import MoEngageRecommendations
@testable import MoEngagePluginRecommendations

/// Exercises the `MoEngageSDKRecommendations` adapter against the real SDK — the bridge tests
/// replace it with a mock. An unregistered workspace makes the SDK reject before any network
/// call, which checks that the adapter calls the SDK and wires `onFailure` to the task.
@Suite("Recommendations SDK adapter")
struct MoEngagePluginRecommendationsSDKAdapterTests {

    enum Outcome {
        case success
        case failure(MoEngageRequestFailure)
    }

    /// Resumes the continuation with the first outcome only, so a duplicate callback cannot
    /// resume it twice.
    final class FirstOutcome: @unchecked Sendable {
        private let lock = NSLock()
        private var continuation: CheckedContinuation<Outcome, Never>?

        init(_ continuation: CheckedContinuation<Outcome, Never>) {
            self.continuation = continuation
        }

        func resume(_ outcome: Outcome) {
            lock.lock()
            let continuation = self.continuation
            self.continuation = nil
            lock.unlock()
            continuation?.resume(returning: outcome)
        }
    }

    @Test("Unregistered workspace rejects through onFailure with sdkNotInitialized")
    func unregisteredWorkspaceFails() async throws {
        MoEngageSDKCore.sharedInstance.disableIntegrationValidator()
        let handler: MoEngagePluginRecommendationsBridgeHandler = MoEngageSDKRecommendations.sharedInstance

        let outcome = await withCheckedContinuation { continuation in
            let first = FirstOutcome(continuation)
            handler.fetchRecommendations(
                recommendationId: "clothing",
                itemId: "shirts",
                includedFields: ["size"],
                workspaceId: "this_workspace_does_not_exist",
                onSuccess: { _ in first.resume(.success) },
                onFailure: { first.resume(.failure($0)) }
            )
        }

        guard case let .failure(failure) = outcome else {
            Issue.record("Expected onFailure, got \(outcome)")
            return
        }
        #expect(failure.reason.code == .sdkNotInitialized)
    }
}

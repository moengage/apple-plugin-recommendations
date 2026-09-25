//
//  MoEngagePluginRecommendationsBridge.swift
//  MoEngagePluginRecommendations
//
//  Created by Rakshitha on 24/09/26.
//

import MoEngagePluginBase
import MoEngageCore
import MoEngageRecommendations

@objc final public class MoEngagePluginRecommendationsBridge: NSObject {
    @objc public static let sharedInstance = MoEngagePluginRecommendationsBridge()

    private let handler: MoEngagePluginRecommendationsBridgeHandler

    internal init(
        handler: MoEngagePluginRecommendationsBridgeHandler = MoEngageSDKRecommendations.sharedInstance
    ) {
        self.handler = handler
    }

    private func logAppIdentifierFetchFailed(
        for payload: [String: Any],
        at function: String = #function
    ) {
        // No app identifier means there is no SDK instance to log against.
        MoEngageLogger.logDefault(
            logLevel: .error,
            message: "Could't find app identifier data for payload: \(payload) at \(function)",
            label: MoEngagePluginRecommendationsConstants.moduleTag
        )
    }

    /// Logs against the SDK instance of the given workspace. Instance lookup is isolated to
    /// `MoEngageGlobalActor`, so the message is built on the caller and logged from there.
    private func log(
        _ message: String,
        logLevel: MoEngageLoggerType = .debug,
        forWorkspaceId workspaceId: String
    ) {
        Task { @MoEngageGlobalActor in
            MoEngageSDKInstanceProvider.getSDKInstance(workspaceId: workspaceId)?.logger.log(
                logLevel: logLevel,
                message: message,
                label: MoEngagePluginRecommendationsConstants.moduleTag
            )
        }
    }

    /// Fetches the recommended items for the recommendation id in the payload.
    ///
    /// The completion handler is always invoked, exactly once. On success the payload follows
    /// `nativeToHybrid/recommendations/fetchRecommendations.json`; on failure it is
    /// `{ accountMeta, error: { code, message } }`, as in the personalize plugin.
    ///
    /// - Parameters:
    ///   - payload: Payload following `hybridToNative/recommendations/fetchRecommendations.json`.
    ///   - completionHandler: Invoked with the success or failure payload.
    @objc public func fetchRecommendations(
        _ payload: [String: Any],
        completionHandler: @escaping ([String: Any]) -> Void
    ) {
        guard
            let identifier = MoEngagePluginUtils.fetchIdentifierFromPayload(attribute: payload)
        else {
            logAppIdentifierFetchFailed(for: payload)
            completionHandler(
                MoEngagePluginRecommendationsUtil.buildHybridErrorPayload(
                    forIdentifier: nil,
                    code: MoEngagePluginRecommendationsConstants.FailureReason.unknownError,
                    message: "Couldn't find app identifier in payload"
                )
            )
            return
        }

        log("Fetch Recommendations - \(payload)", forWorkspaceId: identifier)

        do {
            let data: [String: Any] = try MoEngagePluginRecommendationsUtil.getData(fromHybridPayload: payload)
            let fetchData = try MoEngageRecommendationsFetchData.decodeFromHybrid(data)

            handler.fetchRecommendations(
                recommendationId: fetchData.recommendationId,
                itemId: fetchData.itemId,
                includedFields: fetchData.includedFields,
                workspaceId: identifier,
                onSuccess: { recommendedItems in
                    let result = MoEngagePluginRecommendationsUtil.buildHybridPayload(
                        forIdentifier: identifier,
                        containingData: recommendedItems.encodeForHybrid()
                    )
                    self.log("Fetch Recommendations response - \(result)", forWorkspaceId: identifier)
                    completionHandler(result)
                },
                onFailure: { failure in
                    let result = failure.toHybridPayload(forIdentifier: identifier)
                    self.log(
                        "Fetch Recommendations failed - \(result)",
                        logLevel: .error,
                        forWorkspaceId: identifier
                    )
                    completionHandler(result)
                }
            )
        } catch {
            log("Fetch Recommendations - \(error)", logLevel: .error, forWorkspaceId: identifier)
            completionHandler(
                MoEngagePluginRecommendationsUtil.buildHybridErrorPayload(
                    forIdentifier: identifier,
                    code: MoEngagePluginRecommendationsConstants.FailureReason.invalidRequest,
                    message: "\(error)"
                )
            )
        }
    }
}

protocol MoEngagePluginRecommendationsBridgeHandler {
    func fetchRecommendations(
        recommendationId: String,
        itemId: String,
        includedFields: Set<String>,
        workspaceId: String?,
        onSuccess: @escaping (MoEngageRecommendedItems) -> Void,
        onFailure: @escaping (MoEngageRequestFailure) -> Void
    )
}

extension MoEngageSDKRecommendations: MoEngagePluginRecommendationsBridgeHandler {
    func fetchRecommendations(
        recommendationId: String,
        itemId: String,
        includedFields: Set<String>,
        workspaceId: String?,
        onSuccess: @escaping (MoEngageRecommendedItems) -> Void,
        onFailure: @escaping (MoEngageRequestFailure) -> Void
    ) {
        self.fetchRecommendations(
            recommendationId: recommendationId,
            itemId: itemId,
            includedFields: includedFields,
            workspaceId: workspaceId
        )
        .onSuccess { onSuccess($0) }
        .onFailure { onFailure($0) }
    }
}

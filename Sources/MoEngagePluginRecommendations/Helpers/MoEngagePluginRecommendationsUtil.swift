//
//  MoEngagePluginRecommendationsUtil.swift
//  MoEngagePluginRecommendations
//
//  Created by Rakshitha on 24/09/26.
//

import Foundation
import MoEngagePluginBase

enum MoEngagePluginRecommendationsUtil {

    static func buildHybridPayload(
        forIdentifier identifier: String,
        containingData data: Any
    ) -> [String: Any] {
        let accountMeta = MoEngagePluginUtils.createAccountPayload(identifier: identifier)
        return [
            MoEngagePluginConstants.General.accountMeta: accountMeta,
            MoEngagePluginConstants.General.data: data
        ]
    }

    /// Builds the failure payload: `{ accountMeta, data: { reason, message } }`.
    /// `accountMeta.appId` is empty when the app identifier could not be read.
    static func buildHybridErrorPayload(
        forIdentifier identifier: String?,
        reason: String,
        message: String
    ) -> [String: Any] {
        return buildHybridPayload(
            forIdentifier: identifier ?? "",
            containingData: [
                MoEngagePluginRecommendationsConstants.reason: reason,
                MoEngagePluginRecommendationsConstants.message: message
            ]
        )
    }

    static func getData<T>(
        fromHybridPayload data: [String: Any],
        at function: String = #function
    ) throws -> T {
        guard
            let result = data[MoEngagePluginConstants.General.data] as? T
        else {
            throw MoEngagePluginRecommendationsDecodingError(
                key: MoEngagePluginConstants.General.data,
                data: data,
                function: function
            )
        }
        return result
    }
}

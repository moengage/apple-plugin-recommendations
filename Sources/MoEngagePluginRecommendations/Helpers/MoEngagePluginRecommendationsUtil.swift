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

    /// Builds the failure payload: `{ accountMeta, error: { code, message } }`.
    /// `accountMeta` is omitted when the app identifier could not be read.
    static func buildHybridErrorPayload(
        forIdentifier identifier: String?,
        code: String,
        message: String
    ) -> [String: Any] {
        var payload: [String: Any] = [
            MoEngagePluginRecommendationsConstants.error: [
                MoEngagePluginRecommendationsConstants.code: code,
                MoEngagePluginRecommendationsConstants.message: message
            ]
        ]
        if let identifier {
            payload[MoEngagePluginConstants.General.accountMeta] =
                MoEngagePluginUtils.createAccountPayload(identifier: identifier)
        }
        return payload
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

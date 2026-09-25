//
//  MoEngageRequestFailure+Hybrid.swift
//  MoEngagePluginRecommendations
//
//  Created by Rakshitha on 24/09/26.
//

import MoEngageCore
import MoEngageRecommendations

extension MoEngageRequestFailure {
    /// Builds the hybrid failure payload: `{ accountMeta, error: { code, message } }`.
    ///
    /// Recommendations specific failures carry a `moduleCode`; failures raised before the
    /// module is reached only carry the shared `code`.
    func toHybridPayload(forIdentifier identifier: String) -> [String: Any] {
        return MoEngagePluginRecommendationsUtil.buildHybridErrorPayload(
            forIdentifier: identifier,
            code: Self.hybridReason(for: self.reason),
            message: self.message.isEmpty ? "\(self.reason)" : self.message
        )
    }

    static func hybridReason(for reason: MoEngageRequestFailureReason) -> String {
        if let reason = reason as? MoEngageRecommendationsRequestFailureReason,
           let rawModuleCode = reason.moduleCode?.intValue,
           let moduleCode = MoEngageRecommendationsRequestFailureReason.ModuleCode(rawValue: rawModuleCode) {
            return hybridReason(forModuleCode: moduleCode)
        }
        return hybridReason(forSharedCode: reason.code)
    }

    private static func hybridReason(
        forModuleCode code: MoEngageRecommendationsRequestFailureReason.ModuleCode
    ) -> String {
        typealias FailureReason = MoEngagePluginRecommendationsConstants.FailureReason
        switch code {
        case .invalidRequest:
            return FailureReason.invalidRequest
        case .payloadTooLarge:
            return FailureReason.payloadTooLarge
        case .rateLimitExceeded:
            return FailureReason.rateLimitExceeded
        case .internalServerError:
            return FailureReason.internalServerError
        case .unknownError:
            return FailureReason.unknownError
        @unknown default:
            return FailureReason.unknownError
        }
    }

    private static func hybridReason(forSharedCode code: MoEngageRequestFailureReason.Code) -> String {
        typealias FailureReason = MoEngagePluginRecommendationsConstants.FailureReason
        switch code {
        case .sdkNotInitialized:
            return FailureReason.sdkState
        case .featureDisabled:
            return FailureReason.featureDisabled
        case .networkError:
            return FailureReason.networkError
        case .parseError:
            return FailureReason.parseError
        case .invalidParameters:
            return FailureReason.invalidRequest
        case .serverError, .authenticationFailed, .unknownError, .requiredPermissionMissing, .cancelled:
            return FailureReason.unknownError
        @unknown default:
            return FailureReason.unknownError
        }
    }
}

//
//  NotificationName.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 28.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

private func _withPrefix(_ name: String) -> Notification.Name {
    return Notification.Name("com.sap.ena.\(name)")
}

extension Notification.Name {
    static let isOnboardedDidChange = _withPrefix("isOnboardedDidChange")
    static let dateLastExposureDetectionDidChange = _withPrefix("dateLastExposureDetectionDidChange")
    static let dateOfAcceptedPrivacyNoticeDidChange = _withPrefix("dateOfAcceptedPrivacyNoticeDidChange")
    static let permissionCellularUseDidChange = _withPrefix("allowsCellularUse")
    static let developerSubmissionBaseURLOverrideDidChange = _withPrefix("developerSubmissionBaseURLOverride")
    static let developerDistributionBaseURLOverrideDidChange = _withPrefix("developerDistributionBaseURLOverride")

	// Temporary Notification until implemented by actual transaction flow
	static let didDetectExposureDetectionSummary = _withPrefix("didDetectExposureDetectionSummary")
    static let teleTanDidChange = _withPrefix("teleTanDidChange")
    static let tanDidChange = _withPrefix("tanDidChange")
    static let testGUIDDidChange = _withPrefix("testGUIDDidChange")
    static let devicePairingConsentAcceptDidChange = _withPrefix("devicePairingConsentAcceptDidChange")
    static let devicePairingConsentAcceptTimestampDidChange = _withPrefix("devicePairingConsentAcceptTimestampDidChange")
    static let devicePairingSuccessfulTimestampDidChange = _withPrefix("devicePairingSuccessfulTimestampDidChange")
    static let isAllowedToSubmitDiagnosisKeysDidChange = _withPrefix("isAllowedToSubmitDiagnosisKeysDidChange")
}

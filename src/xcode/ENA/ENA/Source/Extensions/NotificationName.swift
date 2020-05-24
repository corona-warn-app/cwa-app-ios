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
    static let developerVerificationBaseURLOverrideDidChange = _withPrefix("developerVerificationBaseURLOverride")

	// Temporary Notification until implemented by actual transaction flow
	static let didDetectExposureDetectionSummary = _withPrefix("didDetectExposureDetectionSummary")
}

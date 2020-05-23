//
//  Store.swift
//  ENA
//

import Foundation

final class Store {
    @PersistedAndPublished(
        key: "isOnboarded",
        notificationName: Notification.Name.isOnboardedDidChange,
        defaultValue: ((UserDefaults.standard.object(forKey: "isOnboarded") as? String) == "YES")
    )
    var isOnboarded: Bool

    @PersistedAndPublished(
        key: "dateLastExposureDetection",
        notificationName: Notification.Name.dateLastExposureDetectionDidChange,
        defaultValue: nil
    )
    var dateLastExposureDetection: Date?

    @PersistedAndPublished(
        key: "dateOfAcceptedPrivacyNotice",
        notificationName: Notification.Name.dateOfAcceptedPrivacyNoticeDidChange,
        defaultValue: nil
    )
    var dateOfAcceptedPrivacyNotice: Date?

    @PersistedAndPublished(
        key: "allowsCellularUse",
        notificationName: Notification.Name.permissionCellularUseDidChange,
        defaultValue: true
    )
    var allowsCellularUse: Bool

    @PersistedAndPublished(
        key: "developerSubmissionBaseURLOverride",
        notificationName: Notification.Name.developerSubmissionBaseURLOverrideDidChange,
        defaultValue: nil
    )
    var developerSubmissionBaseURLOverride: String?

    @PersistedAndPublished(
        key: "developerDistributionBaseURLOverride",
        notificationName: Notification.Name.developerDistributionBaseURLOverrideDidChange,
        defaultValue: nil
    )
    var developerDistributionBaseURLOverride: String?
}

//
//  Store.swift
//  ENA
//

import Foundation

protocol Store: class {
    var isOnboarded: Bool { get set }
    var dateLastExposureDetection: Date? { get set }
    var dateOfAcceptedPrivacyNotice: Date? { get set }
    var allowsCellularUse: Bool { get set }
    var developerSubmissionBaseURLOverride: String? { get set }
    var developerDistributionBaseURLOverride: String? { get set }
}

/// The `DevelopmentStore` class implements the `Store` protocol that defines all required storage attributes.
/// This class needs to be replaced with an implementation that persists all attributes in an encrypted SQLite databse.
final class DevelopmentStore: Store {
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

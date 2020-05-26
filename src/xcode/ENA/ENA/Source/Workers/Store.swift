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
    var developerVerificationBaseURLOverride: String? { get set }
    var teleTan: String? { get set }
    var tan: String? { get set }
    var testGUID: String? { get set }
    var devicePairingConsentAccept: Bool { get set }
    var devicePairingConsentAcceptTimestamp: Int64? { get set }
    var devicePairingSuccessfulTimestamp: Int64? { get set }
    var isAllowedToSubmitDiagnosisKeys: Bool { get set }
    var registrationToken: String? { get set }
}

/// The `DevelopmentStore` class implements the `Store` protocol that defines all required storage attributes.
/// This class needs to be replaced with an implementation that persists all attributes in an encrypted SQLite database.
final class DevelopmentStore: Store {
    
    /// Manually remove all keys that are saved through the `Store` protocol.
    /// We do not loop here since this may destroys keys that are not managed through this class.
    static func flush() {
        // UserDefaults.standard.removeObject(forKey: "isOnboarded")
        UserDefaults.standard.removeObject(forKey: "dateLastExposureDetection")
        UserDefaults.standard.removeObject(forKey: "dateOfAcceptedPrivacyNotice")
        UserDefaults.standard.removeObject(forKey: "allowsCellularUse")
        // UserDefaults.standard.removeObject(forKey: "developerSubmissionBaseURLOverride")
        // UserDefaults.standard.removeObject(forKey: "developerDistributionBaseURLOverride")
        // UserDefaults.standard.removeObject(forKey: "developerVerificationBaseURLOverride")
        UserDefaults.standard.removeObject(forKey: "teleTan")
        UserDefaults.standard.removeObject(forKey: "testGUID")
        UserDefaults.standard.removeObject(forKey: "devicePairingConsentAccept")
        UserDefaults.standard.removeObject(forKey: "devicePairingConsentAcceptTimestamp")
        UserDefaults.standard.removeObject(forKey: "devicePairingSuccessfulTimestamp")
        UserDefaults.standard.removeObject(forKey: "isAllowedToSubmitDiagnosisKeys")
        UserDefaults.standard.removeObject(forKey: "registrationToken")
        log(message: "Flushed DevelopmentStore", level: .info)
    }
    
    @PersistedAndPublished(
        key: "registrationToken",
        notificationName: Notification.Name.teleTanDidChange,
        defaultValue: ((UserDefaults
                        .standard
                        .object(forKey: "registrationToken") as? String))
    )
    var registrationToken: String?
    
    
    @PersistedAndPublished(
        key: "teleTan",
        notificationName: Notification.Name.teleTanDidChange,
        defaultValue: ((UserDefaults
                        .standard
                        .object(forKey: "teleTan") as? String))
    )
    var teleTan: String?
    
    @PersistedAndPublished(
        key: "tan",
        notificationName: Notification.Name.tanDidChange,
        defaultValue: ((UserDefaults
                        .standard
                        .object(forKey: "tan") as? String))
    )
    var tan: String?
    
    @PersistedAndPublished(
        key: "testGUID",
        notificationName: Notification.Name.testGUIDDidChange,
        defaultValue: ((UserDefaults
                        .standard
                        .object(forKey: "testGUID") as? String))
    )
    var testGUID: String?
    
    @PersistedAndPublished(
        key: "devicePairingConsentAccept",
        notificationName: Notification.Name.devicePairingConsentAcceptDidChange,
        defaultValue: ((UserDefaults
                        .standard
                        .object(forKey: "devicePairingConsentAccept") as? Bool ?? false))
    )
    var devicePairingConsentAccept: Bool
    
    @PersistedAndPublished(
        key: "devicePairingConsentAcceptTimestamp",
        notificationName: Notification.Name.devicePairingConsentAcceptTimestampDidChange,
        defaultValue: ((UserDefaults
                        .standard
                        .object(forKey: "devicePairingConsentAcceptTimestamp") as? Int64))
    )
    var devicePairingConsentAcceptTimestamp: Int64?
    
    @PersistedAndPublished(
        key: "devicePairingSuccessfulTimestamp",
        notificationName: Notification.Name.devicePairingSuccessfulTimestampDidChange,
        defaultValue: ((UserDefaults
                        .standard
                        .object(forKey: "devicePairingSuccessfulTimestamp") as? Int64))
    )
    var devicePairingSuccessfulTimestamp: Int64?
    
    @PersistedAndPublished(
        key: "isAllowedToSubmitDiagnosisKeys",
        notificationName: Notification.Name.isAllowedToSubmitDiagnosisKeysDidChange,
        defaultValue: ((UserDefaults
                        .standard
                        .object(forKey: "isAllowedToSubmitDiagnosisKeys") as? Bool ?? false))
    )
    var isAllowedToSubmitDiagnosisKeys: Bool
    
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
    
    @PersistedAndPublished(
        key: "developerVerificationBaseURLOverride",
        notificationName: Notification.Name.developerVerificationBaseURLOverrideDidChange,
        defaultValue: nil
    )
    var developerVerificationBaseURLOverride: String?
}

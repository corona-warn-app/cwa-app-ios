//
//  Store.swift
//  ENA
//

import Foundation

final class Store {
    @PersistedAndPublished(
        key: "isOnboarded",
        notificationName: Notification.Name.isOnboardedDidChange,
        defaultValue: false
    )
    var isOnboarded: Bool

    @PersistedAndPublished(
        key: "dateLastExposureDetection",
        notificationName: Notification.Name.dateLastExposureDetectionDidChange,
        defaultValue: nil
    )
    var dateLastExposureDetection: Date?

    @PersistedAndPublished(
        key: "allowsCellularUse",
        notificationName: Notification.Name.permissionCellularUseDidChange,
        defaultValue: true
    )
    var allowsCellularUse: Bool
}

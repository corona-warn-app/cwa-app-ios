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
    static let isOnboardedDidChange                 = _withPrefix("isOnboardedDidChange")
    static let dateLastExposureDetectionDidChange   = _withPrefix("dateLastExposureDetectionDidChange")
    static let exposureDetectionSessionDidFail      = _withPrefix("exposureDetectionSessionDidFail")
    static let detectedExposuresDidChange           = _withPrefix("detectedExposuresDidChange")
}

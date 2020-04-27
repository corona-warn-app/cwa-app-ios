//
//  MockENFramework.swift
//  MockENFramework
//
//  Created by Hu, Hao on 26.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

/// A typedef that represents the error codes in the framework
enum ENErrorCode {
    case success
    case unknown
    case badParameter
    case notEntitled
    case notAuthorized
    case unsupported
    case invalidated
    case bluetoothOff
    case insufficientStorage
    case notEnabled
    case apiMisuse
    case internalError
    case insufficientMemory
    
    var localizedDescription: String {
        switch self {
        case .success: return "Operation succeeded"
        case .unknown: return "Unknown"
        case .badParameter: return "Missing or incorrect parameter"
        case .notEntitled: return "Calling process doesn't have the correct entitlement"
        case .notAuthorized: return "User denied this process access to Exposure Notification functionality"
        case .unsupported: return "Operation is not supported"
        case .invalidated: return "Invalidate was called before the operation completed normally"
        case .bluetoothOff: return "Bluetooth was turned off the by user"
        case .insufficientStorage: return "Insufficient storage space to enable exposure notification"
        case .notEnabled: return "Exposure Notification has not been enabled"
        case .apiMisuse: return "API was used incorrectly"
        case .internalError: return "Internal error indicating a bug in this framework."
        case .insufficientMemory: return "Not enough memory to perform an operation"
        }
    }
}

///An enumeration that specifies the app's preference for authorization with Exposure Notification
enum ENAuthorizationMode {
    case defaultMode
    case nonUi
    case ui
}


///An enumeration that indicates the status of authorization for the app
enum ENAuthorizationStatus {
    case unknown
    case restricted
    case notAuthorized
    case authorized
}

typealias ENErrorHandler = ((Error?) -> Void)

/// A protocol for objects that support asynchronous operations and cancellation.
protocol ENActivatable {
    var dispatchQueue: DispatchQueue? { get set }
    var invalidationHandler: (() -> Void)? { get set }
    
    func activateWithCompletion(_ completion: @escaping ENErrorHandler)
    func invalidate()
}



/// A protocol for objects that require authorization from the user before they can be used
protocol ENAuthorizable {
    var authorizationStatus: ENAuthorizationStatus { get }
    var authorizationMode: ENAuthorizationMode { get set }
}


typealias ENMultiState = Bool

/// DescriptionDefines nonmodifiable settings for Exposure Notification
class ENSettings: NSObject {
    let enableState: ENMultiState
    
    init(enableState: ENMultiState) {
        self.enableState = enableState
    }
}


///Defines modifiable settings for Exposure Notification.
class ENMutableSettings: ENSettings {

}



///Requests the current settings for Exposure Notification
class ENSettingsGetRequest {}

///Changes settings for Exposure Notification after authorization by the user.
class ENSettingsChangeRequest {}

///Performs exposure detection based on previously collected proximity data and keys.
class ENExposureDetectionSession {}

///Provides a summary of exposures.
class ENExposureDetectionSummary {
    var daysSinceLastExposure: Int
    var matchedKeyCount: UInt64
}

///Requests the Temporary Exposure Keys used by this device to share with a server
/// This request is intended to be called when a user has received a positive diagnosis
class ENSelfExposureInfoRequest{
    
}

///Deletes all collected exposure data and Temporary Exposure Keys.
class ENSelfExposureResetRequest {}

///Contains information about a single contact incident
class ENExposureInfo{
    var attenuationValue: UInt8
    var date: Date
    var duration: TimeInterval
}


typealias ENIntervalNumber = Int

///The key used to generate Rolling Proximity Identifiers
class ENTemporaryExposureKey {
    var keyData: Data
    var rollingStartNumber: ENIntervalNumber
}

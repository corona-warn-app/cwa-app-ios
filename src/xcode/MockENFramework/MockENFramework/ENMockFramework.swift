/// Modified from TracePrivately project


import Foundation
import UIKit

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
    
    var localizedTitle: String {
        switch self {
        case .success: return "Success"
        case .unknown: return "Unknown"
        case .badParameter: return "Bad Parameter"
        case .notEntitled: return "Not Entitled"
        case .notAuthorized: return "Not Authorized"
        case .unsupported: return "Unsupported"
        case .invalidated: return "Invalidated"
        case .bluetoothOff: return "Bluetooth Off"
        case .insufficientStorage: return "Insufficient Storage"
        case .notEnabled: return "Not Enabled"
        case .apiMisuse: return "API Miuse"
        case .internalError: return "Internal Error"
        case .insufficientMemory: return "Insufficient Memory"
        }
    }
    
    
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

struct ENError: LocalizedError {
    let errorCode: ENErrorCode
    
    var localizedDescription: String {
        return errorCode.localizedTitle
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

/// Defines nonmodifiable settings for Exposure Notification
open class ENSettings: NSObject {
    let enableState: ENMultiState
    
    init(enableState: ENMultiState) {
        self.enableState = enableState
    }
}

///Defines modifiable settings for Exposure Notification.
open class ENMutableSettings: ENSettings {

}

///Requests the current settings for Exposure Notification
open class ENSettingsGetRequest: ENBaseRequest {
    private var _settings: ENSettings? = nil
    
    var settings: ENSettings? {
        get {
            return enQueue.sync {
                return self._settings
            }
        }
        set {
            enQueue.sync {
                self._settings = newValue
            }
        }

    }
    
    override func activate(queue: DispatchQueue, completion: @escaping (Error?) -> Void) {
        queue.async {
            self.settings = ENSettings(enableState: ENInternalState.shared.tracingEnabled)
            completion(nil)
        }
    }
}


///Changes settings for Exposure Notification after authorization by the user.
open class ENSettingsChangeRequest: ENAuthorizableBaseRequest {
    let settings: ENSettings
    
    override var permissionDialogMessage: String? {
        return "Allow this app to detect exposures?"
    }
    
    init(settings: ENSettings) {
        self.settings = settings
    }
    
    override var shouldPrompt: Bool {
        return self.settings.enableState == true
    }
    
    override func activateWithPermission(queue: DispatchQueue, completion: @escaping (Error?) -> Void) {
        queue.async {
            ENInternalState.shared.tracingEnabled = self.settings.enableState
            completion(nil)
        }
    }
}

typealias ENIntervalNumber = Int

///The key used to generate Rolling Proximity Identifiers
open class ENTemporaryExposureKey: NSObject {
    var keyData: Data
    var rollingStartNumber: ENIntervalNumber
}

extension ENTemporaryExposureKey {
    // This is used so we can resolve a date from the key
    var ymd: DateComponents? {
        guard let str = self.stringValue else {
            return nil
        }
        
        let parts = str.components(separatedBy: "_")
        
        guard parts.count == 2 else {
            return nil
        }
        
        let yyyymmdd = parts[1]
        
        guard yyyymmdd.count == 8 else {
            return nil
        }
        
        let y = Int(String(yyyymmdd[0 ... 3]))
        let m = Int(String(yyyymmdd[4 ... 5]))
        let d = Int(String(yyyymmdd[6 ... 7]))
        
        var dc = DateComponents()
        dc.year = y
        dc.month = m
        dc.day = d
        
        return dc
    }

    fileprivate var stringValue: String? {
        return String(data: self.keyData, encoding: .utf8)
    }
}

///Provides a summary of exposures.
open class ENExposureDetectionSummary: NSObject {
    var daysSinceLastExposure: Int
    var matchedKeyCount: UInt64
}

typealias ENExposureDetectionFinishCompletion = ((ENExposureDetectionSummary?, Swift.Error?) -> Void)

typealias ENExposureDetectionGetExposureInfoCompletion = (([ENExposureInfo]?, Bool, Swift.Error?) -> Void)

///Performs exposure detection based on previously collected proximity data and keys.
open class ENExposureDetectionSession: ENBaseRequest {
    var attenuationThreshold: UInt8 = 0
    var durationThreshold: TimeInterval = 0
    var maxKeyCount: Int = 0
    
    private var _infectedKeys: [ENTemporaryExposureKey] = []

    private static let maximumFakeMatches = 1
    
    private var remoteInfectedKeys: [ENTemporaryExposureKey] {
        // Filters out keys for local device for the purposes of better testing
        
        let localDeviceId = ENInternalState.shared.localDeviceId
        
        return self._infectedKeys.filter { key in
            guard let str = key.stringValue else {
                return false
            }
            
            return !str.hasPrefix(localDeviceId)
        }
    }

    func addDiagnosisKeys(inKeys keys: [ENTemporaryExposureKey], completion: @escaping ENErrorHandler) {
        enQueue.sync {
            self._infectedKeys.append(contentsOf: keys)
        }
        
        let queue = self.dispatchQueue ?? .main
        
        queue.asyncAfter(deadline: .now() + 0.5) {
            completion(nil)
        }
    }
    
    func finishedDiagnosisKeysWithCompletion(completion: @escaping ENExposureDetectionFinishCompletion) {
        
        let delay: TimeInterval = 0.5
        
        let queue = self.dispatchQueue ?? .main

        queue.asyncAfter(deadline: .now() + delay) {
            let keys = enQueue.sync { return self.remoteInfectedKeys }
            
            let summary = ENExposureDetectionSummary(
                daysSinceLastExposure: 0,
                matchedKeyCount: UInt64(min(Self.maximumFakeMatches, keys.count))
            )
            
            completion(summary, nil)
        }

    }
    
    func getExposureInfoWithMaxCount(maxCount: UInt32, completion: @escaping ENExposureDetectionGetExposureInfoCompletion) {
        
        let queue: DispatchQueue = self.dispatchQueue ?? .main

        let delay: TimeInterval = 0.5
                
        queue.asyncAfter(deadline: .now() + delay) {
            guard !self.isInvalidated else {
                completion(nil, true, ENError(errorCode: .invalidated))
                return
            }

            // For now this is assuming that every key is infected. Obviously this isn't accurate, just useful for testing.
            let keys: [ENTemporaryExposureKey] = enQueue.sync { self.remoteInfectedKeys }
                    
            let calendar = Calendar(identifier: .gregorian)
            
            let contacts: [ENExposureInfo] = keys.compactMap { key in
                        
                guard var dc = key.ymd else {
                    return nil
                }
                
                dc.hour = 12
                dc.minute = 12
                dc.second = 0
                
                guard let date = calendar.date(from: dc) else {
                    return nil
                }
                
                let duration: TimeInterval = 15 * 60
                return ENExposureInfo(attenuationValue: 0, date: date, duration: duration)
            }
                    
            let numItems = min(Self.maximumFakeMatches, contacts.count)
            
            if numItems == 0 {
                completion([], true, nil)
            }
            else {
                completion(Array(contacts[0 ..< numItems ]), true, nil)
            }
        }
    }
}

open class ENExposureInfo: NSObject {
    var attenuationValue: UInt8
    var date: Date
    var duration: TimeInterval
}

open class ENSelfExposureInfo: NSObject{
    var keys: [ENTemporaryExposureKey]
}

class ENSelfExposureInfoRequest: ENAuthorizableBaseRequest {
    private var _selfExposureInfo: ENSelfExposureInfo?
    
    var selfExposureInfo: ENSelfExposureInfo? {
        get {
            return enQueue.sync {
                return self._selfExposureInfo
            }
        }
        set {
            enQueue.sync {
                self._selfExposureInfo = newValue
            }
        }
    }
    
    override var permissionDialogMessage: String? {
        return "Allow this app to retrieve your anonymous tracing keys?"
    }
    
    override func activateWithPermission(queue: DispatchQueue, completion: @escaping (Error?) -> Void) {
        
        let delay: TimeInterval = 0.5
        
        queue.asyncAfter(deadline: .now() + delay) {
            
            let keys: [ENTemporaryExposureKey] = ENInternalState.shared.dailyKeys.map { ENTemporaryExposureKey(keyData: $0, rollingStartNumber: 0) }
            
            let info = ENSelfExposureInfo(keys: keys)
            self.selfExposureInfo = info
            
            completion(nil)
        }
    }
}

open class ENSelfExposureResetRequest: ENAuthorizableBaseRequest {
    
    override var permissionDialogMessage: String? {
        return "Allow this app to reset your anonymous tracing keys?"
    }

    override func activateWithPermission(queue: DispatchQueue, completion: @escaping (Error?) -> Void) {
        queue.async {
            // Nothing to do since we're generating fake stable keys for the purpose of testing
            completion(nil)
        }
    }
}

class ENAuthorizableBaseRequest: ENBaseRequest, ENAuthorizable {
    var authorizationStatus: ENAuthorizationStatus = .unknown
    var authorizationMode: ENAuthorizationMode = .defaultMode
    
    fileprivate var permissionDialogTitle: String? {
        return nil
    }
    fileprivate var permissionDialogMessage: String? {
        return nil
    }
    
    fileprivate var shouldPrompt: Bool {
        return true
    }
    
    final override func activate(queue: DispatchQueue, completion: @escaping (Error?) -> Void) {
        
        if self.shouldPrompt {
            DispatchQueue.main.async {
                let title = self.permissionDialogTitle ?? "Permission"
                let message = self.permissionDialogMessage ?? "Allow this?"
                
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Deny", style: .cancel, handler: { action in
                    completion(ENError(errorCode: .notAuthorized))
                    return
                }))

                alert.addAction(UIAlertAction(title: "Allow", style: .default, handler: { action in
                    self.activateWithPermission(queue: queue, completion: completion)
                }))
                
                guard let vc = UIApplication.shared.windows.first?.rootViewController else {
                    completion(ENError(errorCode: .unknown))
                    return
                }
                
                if let presented = vc.presentedViewController {
                    presented.present(alert, animated: true, completion: nil)
                }
                else {
                    vc.present(alert, animated: true, completion: nil)
                }
            }
        }
        else {
            let queue = self.dispatchQueue ?? .main
            self.activateWithPermission(queue: queue, completion: completion)
        }
    }
    
    func activateWithPermission(queue: DispatchQueue, completion: @escaping (Error?) -> Void) {
        queue.async {
            print("Should be overridden")
            completion(nil)
        }
    }
}

fileprivate let enQueue = DispatchQueue(label: "TracePrivately", qos: .default, attributes: [])

class ENBaseRequest: ENActivatable, NSObject {
    /// This property holds the the dispatch queue used to invoke handlers on. If this property isn’t set, the framework uses the main queue.
    var dispatchQueue: DispatchQueue?
    
    private var _invalidationHandler: (() -> Void)?
    
    var invalidationHandler: (() -> Void)? {
        get {
            return enQueue.sync {
                return self._invalidationHandler
            }
        }
        set {
            enQueue.sync {
                self._invalidationHandler = newValue
            }
        }
    }
    
    private var _isRunning = false
    fileprivate var isRunning: Bool {
        get {
            return enQueue.sync {
                return self._isRunning
            }
        }
        set {
            enQueue.sync {
                self._isRunning = newValue
            }
        }
    }
    
    private var _isInvalidated = false
    fileprivate var isInvalidated: Bool {
        get {
            return enQueue.sync {
                return self._isInvalidated
            }
        }
        set {
            enQueue.sync {
                self._isInvalidated = newValue
            }
        }
    }

    final func activateWithCompletion(_ completion: @escaping (Swift.Error?) -> Void) {
        let queue: DispatchQueue = self.dispatchQueue ?? .main
        
        self.isRunning = true
        
        self.activate(queue: queue) { error in
            guard !self.isInvalidated else {
                completion(ENError(errorCode: .invalidated))
                return
            }
            
            self.isRunning = false
            completion(error)
        }
    }
    
    fileprivate func activate(queue: DispatchQueue, completion: @escaping (Swift.Error?) -> Void) {
        queue.async {
            print("Should be overridden")
            completion(nil)
        }
    }
    
    func invalidate() {
        self.isInvalidated = true
        
        let queue: DispatchQueue = self.dispatchQueue ?? .main
        
        queue.async {
            self.invalidationHandler?()
            self.invalidationHandler = nil
        }
    }
}

private class ENInternalState {
    
    static let shared = ENInternalState()
    
    private var _tracingEnabled: Bool = false
    
    fileprivate var tracingEnabled: Bool {
        get {
            return enQueue.sync {
                return self._tracingEnabled
            }
        }
        set {
            enQueue.sync {
                self._tracingEnabled = newValue
            }
        }
    }

    private init() {
        
    }
    
    // This is only for testing as it would otherwise be considered identifiable. This class is purely
    // a mock implementation of Apple's framework, so allowances like this are made in order to help
    // develop and test.
    fileprivate lazy var localDeviceId: String = {
        return UIDevice.current.identifierForVendor!.uuidString
    }()
    
    // These keys are stable for this device as they use a device specific ID with an index appended
    var dailyKeys: [Data] {
        return enQueue.sync {
            
            var keys: [String] = []
            
            let deviceId = self.localDeviceId
            
            let calendar = Calendar(identifier: .gregorian)
            
            var todayDc = calendar.dateComponents([ .day, .month, .year ], from: Date())
            todayDc.hour = 12
            todayDc.minute = 0
            todayDc.second = 0
            
            guard let todayMidday = calendar.date(from: todayDc) else {
                return []
            }
            
            for idx in 0 ..< 14 {
                guard let date = calendar.date(byAdding: .day, value: -idx, to: todayMidday, wrappingComponents: false) else {
                    continue
                }

                let dc = calendar.dateComponents([ .day, .month, .year ], from: date)
                
                let dateStr = String(format: "%04d%02d%02d", dc.year!, dc.month!, dc.day!)
                
                let str = deviceId + "_" + dateStr
                keys.append(str)
                
            }
            
            print("Generated keys: \(keys)")
            
            return keys.compactMap { $0.data(using: .utf8) }
        }
    }

}

extension UUID {
    var data: Data {
        return withUnsafePointer(to: self.uuid) {
            Data(bytes: $0, count: MemoryLayout.size(ofValue: self.uuid))
        }
    }
}

extension String {
    subscript (r: CountableClosedRange<Int>) -> String {
        get {
            let startIndex =  self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
            return String(self[startIndex...endIndex])
        }
    }
}

/// Modified from TracePrivately project

import Foundation
import UIKit

public enum ENErrorCode {
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
}

public struct ENError: LocalizedError {
    let errorCode: ENErrorCode
    
    var localizedDescription: String {
        return errorCode.localizedTitle
    }
}

public enum ENAuthorizationMode {
    case defaultMode
    case nonUi
    case ui
}

public enum ENAuthorizationStatus {
    case unknown
    case restricted
    case notAuthorized
    case authorized
}

public typealias ENErrorHandler = ((Error?) -> Void)

public protocol ENActivatable {
    var dispatchQueue: DispatchQueue? { get set }
    var invalidationHandler: (() -> Void)? { get set }
    
    func activateWithCompletion(_ completion: @escaping ENErrorHandler)
    func invalidate()
}

public protocol ENAuthorizable {
    var authorizationStatus: ENAuthorizationStatus { get }
    var authorizationMode: ENAuthorizationMode { get set }
}

public typealias ENMultiState = Bool

public class ENSettings {
    let enableState: ENMultiState
    
    init(enableState: ENMultiState) {
        self.enableState = enableState
    }
}

public class ENMutableSettings: ENSettings {

}

public class ENSettingsGetRequest: ENBaseRequest {
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
    
    override fileprivate func activate(queue: DispatchQueue, completion: @escaping (Error?) -> Void) {
        queue.async {
            self.settings = ENSettings(enableState: ENInternalState.shared.tracingEnabled)
            completion(nil)
        }
    }
}

public class ENSettingsChangeRequest: ENAuthorizableBaseRequest {
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
    
    override fileprivate func activateWithPermission(queue: DispatchQueue, completion: @escaping (Error?) -> Void) {
        queue.async {
            ENInternalState.shared.tracingEnabled = self.settings.enableState
            completion(nil)
        }
    }
}

public typealias ENIntervalNumber = UInt32

public struct ENTemporaryExposureKey {
    let keyData: Data
    let rollingStartNumber: ENIntervalNumber
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

public struct ENExposureDetectionSummary {
    let daysSinceLastExposure: Int
    let matchedKeyCount: UInt64
}

public typealias ENExposureDetectionFinishCompletion = ((ENExposureDetectionSummary?, Swift.Error?) -> Void)

public typealias ENExposureDetectionGetExposureInfoCompletion = (([ENExposureInfo]?, Bool, Swift.Error?) -> Void)

public class ENExposureDetectionSession: ENBaseRequest {
    var attenuationThreshold: UInt8 = 0
    var durationThreshold: TimeInterval = 0
    var maxKeyCount: Int = 10
    
    private var _infectedKeys: [ENTemporaryExposureKey] = []

    private static let maximumFakeMatches = 5
    
    private var remoteInfectedKeys: [ENTemporaryExposureKey] {
        // Filters out keys for local device for the purposes of better testing
        
        let localDeviceId = ENInternalState.shared.localDeviceId.data
        
        return self._infectedKeys.filter { key in
            return key.keyData != localDeviceId
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
    
    private var cursor: Int = 0
    
    func getExposureInfoWithMaxCount(maxCount: UInt32, completion: @escaping ENExposureDetectionGetExposureInfoCompletion) {
        
        let queue: DispatchQueue = self.dispatchQueue ?? .main

        let delay: TimeInterval = 0.5
                
        queue.asyncAfter(deadline: .now() + delay) {
            guard !self.isInvalidated else {
                self.cursor = 0
                completion(nil, true, ENError(errorCode: .invalidated))
                return
            }

            // For now this is assuming that every key is infected. Obviously this isn't accurate, just useful for testing.
            let allKeys: [ENTemporaryExposureKey] = enQueue.sync { self.remoteInfectedKeys }
            
            guard allKeys.count > 0 else {
                completion([], true, nil)
                return
            }
            
            let allMatchedKeys: [ENTemporaryExposureKey] = Array(allKeys[0 ..< min(Self.maximumFakeMatches, allKeys.count)])
            
            let fromIndex = self.cursor
            let toIndex   = min(allMatchedKeys.count, self.cursor + Int(maxCount))
            
            guard fromIndex < toIndex else {
                self.cursor = 0
                completion([], true, nil)
                return
            }
            
            let keys = Array(allMatchedKeys[fromIndex ..< toIndex])
            
            let contacts: [ENExposureInfo] = keys.compactMap { key in

                let date = Date(timeIntervalSince1970: TimeInterval(key.rollingStartNumber * 600))
                let duration: TimeInterval = 15 * 60

                return ENExposureInfo(attenuationValue: 0, date: date, duration: duration)
            }
            
            let inDone = toIndex >= allMatchedKeys.count
            self.cursor = inDone ? 0 : toIndex
            
            completion(contacts, inDone, nil)
        }
    }
}

public struct ENExposureInfo {
    let attenuationValue: UInt8
    let date: Date
    let duration: TimeInterval
}

public struct ENSelfExposureInfo {
    let keys: [ENTemporaryExposureKey]
}

public class ENSelfExposureInfoRequest: ENAuthorizableBaseRequest {
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
    
    override fileprivate func activateWithPermission(queue: DispatchQueue, completion: @escaping (Error?) -> Void) {
        
        let delay: TimeInterval = 0.5
        
        queue.asyncAfter(deadline: .now() + delay) {
            
            let info = ENSelfExposureInfo(keys: ENInternalState.shared.dailyKeys)
            self.selfExposureInfo = info
            
            completion(nil)
        }
    }
}

public class ENSelfExposureResetRequest: ENAuthorizableBaseRequest {
    
    override var permissionDialogMessage: String? {
        return "Allow this app to reset your anonymous tracing keys?"
    }

    override fileprivate func activateWithPermission(queue: DispatchQueue, completion: @escaping (Error?) -> Void) {
        
        print("Resetting keys ...")
        queue.asyncAfter(deadline: .now() + 0.5) {
            print("Finished resetting keys")
            
            // Nothing to do since we're generating fake stable keys for the purpose of testing
            completion(nil)
        }
    }
}

public class ENAuthorizableBaseRequest: ENBaseRequest, ENAuthorizable {
    public var authorizationStatus: ENAuthorizationStatus = .unknown
    public var authorizationMode: ENAuthorizationMode = .defaultMode
    
    fileprivate var permissionDialogTitle: String? {
        return nil
    }
    fileprivate var permissionDialogMessage: String? {
        return nil
    }
    
    fileprivate var shouldPrompt: Bool {
        return true
    }
    
    final override fileprivate func activate(queue: DispatchQueue, completion: @escaping (Error?) -> Void) {
        
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
    
    fileprivate func activateWithPermission(queue: DispatchQueue, completion: @escaping (Error?) -> Void) {
        queue.async {
            print("Should be overridden")
            completion(nil)
        }
    }
}

fileprivate let enQueue = DispatchQueue(label: "TracePrivately", qos: .default, attributes: [])

public class ENBaseRequest: ENActivatable {
    /// This property holds the the dispatch queue used to invoke handlers on. If this property isn’t set, the framework uses the main queue.
    public var dispatchQueue: DispatchQueue?
    
    private var _invalidationHandler: (() -> Void)?
    
    public var invalidationHandler: (() -> Void)? {
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

    final public func activateWithCompletion(_ completion: @escaping (Swift.Error?) -> Void) {
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
    
    public func invalidate() {
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
    
    // This is only for testing as it would otherwise be considered identifiable. This public class is purely
    // a mock implementation of Apple's framework, so allowances like this are made in order to help
    // develop and test.
    fileprivate lazy var localDeviceId: UUID = {
        return UIDevice.current.identifierForVendor!
    }()
    
    // These keys are stable for this device as they use a device specific ID with an index appended
    var dailyKeys: [ENTemporaryExposureKey] {
        return enQueue.sync {
            
            let deviceId = self.localDeviceId
            
            let calendar = Calendar(identifier: .gregorian)
            
            var todayDc = calendar.dateComponents([ .day, .month, .year ], from: Date())
            todayDc.hour = 12
            todayDc.minute = 0
            todayDc.second = 0
            
            guard let todayMidday = calendar.date(from: todayDc) else {
                return []
            }
            
            var keys: [ENTemporaryExposureKey] = []
            
            let keyData = deviceId.data
            
            for idx in 0 ..< 14 {
                guard let date = calendar.date(byAdding: .day, value: -idx, to: todayMidday, wrappingComponents: false) else {
                    continue
                }
                
//                let dc = calendar.dateComponents([ .day, .month, .year ], from: date)
//
//                let dateStr = String(format: "%04d%02d%02d", dc.year!, dc.month!, dc.day!)
//
//                let str = deviceId + "_" + dateStr
//
//                guard let keyData = str.data(using: .utf8) else {
//                    continue
//                }
                
                let intervalNumber = ENIntervalNumber(date.timeIntervalSince1970 / 600)
                let rollingStartNumber = intervalNumber / 144 * 144

                keys.append(ENTemporaryExposureKey(keyData: keyData, rollingStartNumber: rollingStartNumber))
            }
            
            print("Generated keys: \(keys)")

            return keys
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

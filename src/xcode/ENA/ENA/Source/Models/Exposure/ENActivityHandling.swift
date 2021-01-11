//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification

/// Activities that occurred while the app wasn't running.
struct ENActivityFlags: OptionSet {
    let rawValue: UInt32

    /// App launched to perform periodic operations.
    static let periodicRun = ENActivityFlags(rawValue: 1 << 2)
}

/// Invoked after the app is launched to report activities that occurred while the app wasn't running.
typealias ENActivityHandler = (ENActivityFlags) -> Void

extension ENManager {
    
    /// On iOS 12.5 only, this will ensure the app receives 3.5 minutes of background processing
    /// every 4 hours. This function is needed on iOS 12.5 because the BackgroundTask framework, used
    /// for Exposure Notifications background processing in iOS 13.5+ does not exist in iOS 12.
    func setLaunchActivityHandler(activityHandler: @escaping ENActivityHandler) {
        let proxyActivityHandler: @convention(block) (UInt32) -> Void = {integerFlag in
            activityHandler(ENActivityFlags(rawValue: integerFlag))
        }
        
        setValue(proxyActivityHandler, forKey: "activityHandler")
    }
}

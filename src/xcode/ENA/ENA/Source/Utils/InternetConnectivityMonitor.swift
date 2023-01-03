//
// 🦠 Corona-Warn-App
//

import Foundation
import Network

class InternetConnectivityMonitor {
	
	// MARK: - Init

	private init() {
		monitor = NWPathMonitor()
		monitor.pathUpdateHandler = { [weak self] path in
			self?._isDeviceOnline = path.status == .satisfied
		}
		
		monitor.start(queue: DispatchQueue.global(qos: .background))
	}
	
	deinit {
		monitor.cancel()
	}
	
	// MARK: - Internal

	static let shared = InternetConnectivityMonitor()
	
	/// Real device internet connectivity state.
	/// For Simulator purposes use `isDeviceOnlineMock`
	/// - Returns: `true`, if the real device is online
	var isDeviceOnline: Bool {
		#if DEBUG && targetEnvironment(simulator)
		return isDeviceOnlineMock
		#else
		return _isDeviceOnline
		#endif
	}
	
	#if DEBUG
	var isDeviceOnlineMock: Bool = true
	#endif

	// MARK: - Private

	private let monitor: NWPathMonitor
	private var _isDeviceOnline: Bool = true
}

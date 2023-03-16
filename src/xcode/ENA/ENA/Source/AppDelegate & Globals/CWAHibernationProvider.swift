//
// 🦠 Corona-Warn-App
//

import Foundation

class CWAHibernationProvider: RequiresAppDependencies {
	
	// MARK: - Init
	
	/// Use shared instance instead
	private init() {}
	
	#if !RELEASE
	/// For UI/Unit purposes only
	init(customStore: Store) {
		self.customStore = customStore
	}
	#endif
	
	// MARK: Public
	
	static let isHibernationInUnitTest = "isHibernationInUnitTest"

	// MARK: Internal
	
	static let shared = CWAHibernationProvider()

	/// Determines if the CWA is in hibernation state.
	var isHibernationState: Bool {
		#if DEBUG
		if isUITesting {
			return LaunchArguments.endOfLife.isHibernationStateEnabled.boolValue
		}
		// check if we are using unit testing environment then we return an expected value true or false based on the unit test
		if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
			return UserDefaults.standard.bool(forKey: CWAHibernationProvider.isHibernationInUnitTest)
		}
		return secureStore.hibernationComparisonDate >= hibernationStartDate
		#else
		return Date() >= hibernationStartDate
		#endif
	}
	
	/// CWA hibernation threshold date.
	private let hibernationStartDate: Date = {
		var hibernationStartDateComponents = DateComponents()
		hibernationStartDateComponents.year = 2023
		hibernationStartDateComponents.month = 5
		hibernationStartDateComponents.day = 1
		hibernationStartDateComponents.hour = 0
		hibernationStartDateComponents.minute = 0
		hibernationStartDateComponents.second = 0
		
		guard let hibernationStartDate = Calendar.current.date(from: hibernationStartDateComponents) else {
			fatalError("The hibernation start date couldn't be created.")
		}
		
		return hibernationStartDate
	}()
	
	private var secureStore: Store {
		#if RELEASE
		return store
		#else
		return customStore ?? store
		#endif
	}
	
	#if !RELEASE
	/// For UI/Unit Test purposes only
	private var customStore: Store?
	#endif
}

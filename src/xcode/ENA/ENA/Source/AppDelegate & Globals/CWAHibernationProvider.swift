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
	
	// MARK: Internal
	
	static let shared = CWAHibernationProvider()
	
	/// Determines if the CWA is in hibernation state.
	var isHibernationState: Bool {
		#if RELEASE
		return Date() >= hibernationStartDate
		#else
		return secureStore.hibernationComparingDate >= hibernationStartDate
		#endif
	}
	
	/// CWA hibernation 2023 threshold date.
	private let hibernationStartDate: Date = {
		var hibernationStartDateComponents = DateComponents()
		hibernationStartDateComponents.year = 2023
		hibernationStartDateComponents.month = 6
		hibernationStartDateComponents.day = 1
		hibernationStartDateComponents.hour = 0
		hibernationStartDateComponents.minute = 0
		hibernationStartDateComponents.second = 0
		hibernationStartDateComponents.timeZone = .utcTimeZone
		
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

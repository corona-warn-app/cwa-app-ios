//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

class MockCWAHibernationProvider: CWAHibernationProvider {
	
	// MARK: - Init
	
	init(testStore: MockTestStore = MockTestStore()) {
		self.testStore = testStore
		super.init(customStore: testStore)
	}
	
	// MARK: - Overrides
	
	override var isHibernationState: Bool {
		isHibernationStateToReturn
	}
	
	// MARK: - Internal
	
	var isHibernationStateToReturn: Bool = false
	
	let testStore: MockTestStore
}

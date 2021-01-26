////
// 🦠 Corona-Warn-App
//

import Foundation

/// The `NewVersionFeature` struct keeps information about the new feature (`title`) and a detailed `description`.
struct NewVersionFeature {
	
	// MARK: - Init
	
	init(title: String, description: String) {
		self.title = title
		self.description = description
	}
	
	// MARK: - Internal
	
	var title: String
	
	var description: String
}

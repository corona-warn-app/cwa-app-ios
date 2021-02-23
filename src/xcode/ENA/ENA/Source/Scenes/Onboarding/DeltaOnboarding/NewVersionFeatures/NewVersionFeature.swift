////
// 🦠 Corona-Warn-App
//

import Foundation

/// The `NewVersionFeature` struct keeps information about the new feature (`title`) and a detailed `description`.
/// In addition, there might be the need to identify a new feature for purpose. Therefor you can use the `internalId` as an identifier.
struct NewVersionFeature {
	
	// MARK: - Init
	
	init(title: String, description: String, internalId: String? = nil) {
		self.title = title
		self.description = description
		self.internalId = internalId
	}
	
	// MARK: - Internal
	
	var title: String
	
	var description: String
	
	var internalId: String?
}

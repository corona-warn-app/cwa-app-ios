////
// 🦠 Corona-Warn-App
//

import Foundation


// [KGA] Add struct documentation with hint about AppStrings etc.
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

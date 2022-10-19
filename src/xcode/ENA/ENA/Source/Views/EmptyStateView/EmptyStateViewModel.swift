////
// 🦠 Corona-Warn-App
//

import UIKit

protocol EmptyStateViewModel {

	var image: UIImage? { get }
	var imageAccessibilityIdentifier: String? { get }
	var title: String { get }
	var titleAccessibilityIdentifier: String? { get }
	var description: String { get }
	var descriptionAccessibilityIdentifier: String? { get }
	var imageDescription: String { get }

}

extension EmptyStateViewModel {
	var titleAccessibilityIdentifier: String? { nil }
	var descriptionAccessibilityIdentifier: String? { nil }
}

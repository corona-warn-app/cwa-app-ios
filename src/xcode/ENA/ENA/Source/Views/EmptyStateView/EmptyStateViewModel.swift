////
// 🦠 Corona-Warn-App
//

import UIKit

protocol EmptyStateViewModel {

	var image: UIImage? { get }
	var imageAccessibilityIdentifier: String? { get }
	var title: String { get }
	var description: String { get }
	var imageDescription: String { get }

}

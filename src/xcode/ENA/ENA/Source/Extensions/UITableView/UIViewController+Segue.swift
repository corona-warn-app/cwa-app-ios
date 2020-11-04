import Foundation
import UIKit

protocol SegueIdentifiers {
	var rawValue: String { get }

	init?(rawValue: String)
	init?(_ string: String)
	init?(_ segue: UIStoryboardSegue)
}

extension SegueIdentifiers {
	init?(_ string: String) {
		self.init(rawValue: string)
	}

	init?(_ segue: UIStoryboardSegue) {
		if let identifier = segue.identifier {
			self.init(identifier)
		} else {
			return nil
		}
	}
}

extension UIViewController {
	typealias SegueIdentifier = SegueIdentifiers

	func performSegue(withIdentifier identifier: SegueIdentifier, sender: Any?) {
		performSegue(withIdentifier: identifier.rawValue, sender: sender)
	}
}

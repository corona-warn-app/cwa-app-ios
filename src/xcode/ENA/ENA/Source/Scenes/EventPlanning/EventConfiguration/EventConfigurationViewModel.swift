//
// 🦠 Corona-Warn-App
//

import UIKit
import PDFKit

class EventConfigurationViewModel {

	enum Mode {
		case new(EventType)
		case duplicate(Event)
	}

	// MARK: - Init

	init(
		mode: Mode
	) {
		self.mode = mode
	}

	// MARK: - Internal

	func save(completion: @escaping (Bool) -> Void) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
			completion(true)
		}
	}

	// MARK: - Private

	let mode: Mode

}

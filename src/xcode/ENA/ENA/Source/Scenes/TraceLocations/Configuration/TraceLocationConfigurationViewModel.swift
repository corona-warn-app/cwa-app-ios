//
// 🦠 Corona-Warn-App
//

import UIKit
import PDFKit

class TraceLocationConfigurationViewModel {

	enum Mode {
		case new(TraceLocationType)
		case duplicate(TraceLocation)
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

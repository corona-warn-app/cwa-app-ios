//
// 🦠 Corona-Warn-App
//

import UIKit

// Simple View which holds a property that indicates if this view was already drawn
class StatefulView: UIView {

	init() {
		super.init(frame: .zero)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	var wasDrawn: Bool = false
}

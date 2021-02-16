////
// 🦠 Corona-Warn-App
//

import UIKit

class DeselectableSegmentedControl: UISegmentedControl {

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		let previousIndex = selectedSegmentIndex

		super.touchesEnded(touches, with: event)

		if previousIndex == selectedSegmentIndex, let touchLocation = touches.first?.location(in: self), bounds.contains(touchLocation) {
			selectedSegmentIndex = -1
			sendActions(for: .valueChanged)
		}
	}

}

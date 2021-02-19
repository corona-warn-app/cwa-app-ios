////
// 🦠 Corona-Warn-App
//

import UIKit

class DiarySegmentedControl: UISegmentedControl {

	// MARK: - Init

	init() {
		super.init(frame: .zero)

		setUp()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		setUp()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		setUp()
	}

	// MARK: - Overrides

	/// Make segments deselectable
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		let previousIndex = selectedSegmentIndex

		super.touchesEnded(touches, with: event)

		if previousIndex == selectedSegmentIndex, let touchLocation = touches.first?.location(in: self), bounds.contains(touchLocation) {
			selectedSegmentIndex = -1
			sendActions(for: .valueChanged)
		}
	}

	// MARK: - Private

	private func setUp() {
		backgroundColor = .enaColor(for: .darkBackground)

		let image = UIImage(named: "SelectedSegmentBackground")

		setBackgroundImage(image?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)), for: .selected, barMetrics: .default)
		setBackgroundImage(UIImage.with(color: .enaColor(for: .background)), for: .normal, barMetrics: .default)

		setDividerImage(UIImage(named: "DividerLeft")?.resizableImage(withCapInsets: UIEdgeInsets(top: 9, left: 0, bottom: 9, right: 0)), forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
		setDividerImage(UIImage(named: "DividerLeft")?.resizableImage(withCapInsets: UIEdgeInsets(top: 9, left: 0, bottom: 9, right: 0)), forLeftSegmentState: .selected, rightSegmentState: .highlighted, barMetrics: .default)
		setDividerImage(UIImage(named: "DividerRight")?.resizableImage(withCapInsets: UIEdgeInsets(top: 9, left: 0, bottom: 9, right: 0)), forLeftSegmentState: .normal, rightSegmentState: .selected, barMetrics: .default)
		setDividerImage(UIImage(named: "DividerRight")?.resizableImage(withCapInsets: UIEdgeInsets(top: 9, left: 0, bottom: 9, right: 0)), forLeftSegmentState: .highlighted, rightSegmentState: .selected, barMetrics: .default)
		setDividerImage(UIImage(named: "Divider")?.resizableImage(withCapInsets: UIEdgeInsets(top: 9, left: 0, bottom: 9, right: 0)), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

		setContentPositionAdjustment(UIOffset(horizontal: 4.5, vertical: 0), forSegmentType: .left, barMetrics: .default)
		setContentPositionAdjustment(UIOffset(horizontal: -4.5, vertical: 0), forSegmentType: .right, barMetrics: .default)

		heightAnchor.constraint(equalToConstant: 39).isActive = true
	}

}

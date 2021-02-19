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

		let selectedSegmentBackgroundImage = UIImage(named: "SelectedSegmentBackground")?
			.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))

		let dividerInsets = UIEdgeInsets(top: 9, left: 0, bottom: 9, right: 0)
		let leftSelectedDividerImage = UIImage(named: "DividerLeft")?.resizableImage(withCapInsets: dividerInsets)
		let rightSelectedDividerImage = UIImage(named: "DividerRight")?.resizableImage(withCapInsets: dividerInsets)
		let unselectedDividerImage = UIImage(named: "Divider")?.resizableImage(withCapInsets: dividerInsets)

		setBackgroundImage(
			selectedSegmentBackgroundImage,
			for: .selected,
			barMetrics: .default
		)
		setBackgroundImage(
			.with(color: .enaColor(for: .background)),
			for: .normal,
			barMetrics: .default
		)

		setDividerImage(
			leftSelectedDividerImage,
			forLeftSegmentState: .selected,
			rightSegmentState: .normal,
			barMetrics: .default
		)
		setDividerImage(
			leftSelectedDividerImage,
			forLeftSegmentState: .selected,
			rightSegmentState: .highlighted,
			barMetrics: .default
		)
		setDividerImage(
			rightSelectedDividerImage,
			forLeftSegmentState: .normal,
			rightSegmentState: .selected,
			barMetrics: .default
		)
		setDividerImage(
			rightSelectedDividerImage,
			forLeftSegmentState: .highlighted,
			rightSegmentState: .selected,
			barMetrics: .default
		)
		setDividerImage(
			unselectedDividerImage,
			forLeftSegmentState: .normal,
			rightSegmentState: .normal,
			barMetrics: .default
		)

		setContentPositionAdjustment(
			UIOffset(horizontal: 4.5, vertical: 0),
			forSegmentType: .left,
			barMetrics: .default
		)
		setContentPositionAdjustment(
			UIOffset(horizontal: -4.5, vertical: 0),
			forSegmentType: .right,
			barMetrics: .default
		)

		heightAnchor.constraint(equalToConstant: 39).isActive = true
	}

}

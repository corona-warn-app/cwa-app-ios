////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryDayEntryTableViewCell: UITableViewCell {

	// MARK: - Internal

	func configure(cellModel: DiaryDayEntryCellModel) {
		checkboxImageView.image = cellModel.image
		label.text = cellModel.text

		addParameterViews(for: cellModel.entryType)

		parametersContainerStackView.isHidden = cellModel.parametersHidden

		accessibilityTraits = cellModel.accessibilityTraits

		self.cellModel = cellModel

		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
		headerStackView.addGestureRecognizer(tapGestureRecognizer)
		headerStackView.isUserInteractionEnabled = true
	}

	// MARK: - Private

	private var cellModel: DiaryDayEntryCellModel!

	@IBOutlet private weak var label: ENALabel!
	@IBOutlet private weak var checkboxImageView: UIImageView!
	@IBOutlet private weak var headerStackView: UIStackView!
	@IBOutlet private weak var parametersContainerStackView: UIStackView!
	@IBOutlet private weak var parametersStackView: UIStackView!

	@objc
	private func headerTapped() {
		cellModel.toggleSelection()
	}

	private func addParameterViews(for entryType: DiaryEntryType) {
		parametersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		switch entryType {
		case .contactPerson:
			let segmentedControl = DiarySegmentedControl()
			segmentedControl.insertSegment(withTitle: "Test", at: 0, animated: false)
			segmentedControl.insertSegment(withTitle: "2345", at: 1, animated: false)

			parametersStackView.addArrangedSubview(segmentedControl)
		case .location:
			break
		}
	}

}

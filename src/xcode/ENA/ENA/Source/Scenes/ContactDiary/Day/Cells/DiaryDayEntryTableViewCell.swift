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

	lazy var durationSegmentedControl: DiarySegmentedControl = {
		let segmentedControl = DiarySegmentedControl()
		segmentedControl.insertSegment(withTitle: AppStrings.ContactDiary.Day.Encounter.lessThan15Minutes, at: 0, animated: false)
		segmentedControl.insertSegment(withTitle: AppStrings.ContactDiary.Day.Encounter.lessThan15Minutes, at: 1, animated: false)

		return segmentedControl
	}()

	lazy var maskSituationSegmentedControl: DiarySegmentedControl = {
		let segmentedControl = DiarySegmentedControl()
		segmentedControl.insertSegment(withTitle: AppStrings.ContactDiary.Day.Encounter.withMask, at: 0, animated: false)
		segmentedControl.insertSegment(withTitle: AppStrings.ContactDiary.Day.Encounter.withoutMask, at: 1, animated: false)

		return segmentedControl
	}()

	lazy var settingSegmentedControl: DiarySegmentedControl = {
		let segmentedControl = DiarySegmentedControl()
		segmentedControl.insertSegment(withTitle: AppStrings.ContactDiary.Day.Encounter.outside, at: 0, animated: false)
		segmentedControl.insertSegment(withTitle: AppStrings.ContactDiary.Day.Encounter.inside, at: 1, animated: false)

		return segmentedControl
	}()

	lazy var notesTextField: DiaryEntryTextField = {
		let textField = DiaryEntryTextField(frame: .zero)
		textField.backgroundColor = .enaColor(for: .darkBackground)
		textField.clearButtonMode = .whileEditing
		textField.textColor = .enaColor(for: .textPrimary1)
		textField.returnKeyType = .done

		textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 40.0).isActive = true

		return textField
	}()

	lazy var notesInfoButton: UIButton = {
		let button = UIButton(type: .infoLight)
		button.tintColor = .enaColor(for: .tint)

		return button
	}()

	lazy var notesStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.spacing = 8

		stackView.addArrangedSubview(notesTextField)
		stackView.addArrangedSubview(notesInfoButton)

		return stackView
	}()

	lazy var visitDurationStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.spacing = 8

		let label = ENALabel()
		label.text = AppStrings.ContactDiary.Day.Visit.duration

		let durationPicker = UIDatePicker()
		durationPicker.datePickerMode = .time
		durationPicker.minuteInterval = 15
		if #available(iOS 14.0, *) {
			durationPicker.preferredDatePickerStyle = .inline
		} else {
			// Fallback on earlier versions
		}

		stackView.addArrangedSubview(label)
		stackView.addArrangedSubview(durationPicker)

		return stackView
	}()

	@objc
	private func headerTapped() {
		cellModel.toggleSelection()
	}

	private func addParameterViews(for entryType: DiaryEntryType) {
		parametersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		switch entryType {
		case .contactPerson:
			parametersStackView.addArrangedSubview(durationSegmentedControl)
			parametersStackView.addArrangedSubview(maskSituationSegmentedControl)
			parametersStackView.addArrangedSubview(settingSegmentedControl)

			notesTextField.placeholder = AppStrings.ContactDiary.Day.Encounter.notesPlaceholder
		case .location:
			parametersStackView.addArrangedSubview(visitDurationStackView)

			notesTextField.placeholder = AppStrings.ContactDiary.Day.Visit.notesPlaceholder
		}

		parametersStackView.addArrangedSubview(notesStackView)
	}

}

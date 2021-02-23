////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryDayEntryTableViewCell: UITableViewCell {

	// MARK: - Internal

	func configure(
		cellModel: DiaryDayEntryCellModel,
		onInfoButtonTap: @escaping () -> Void
	) {
		self.cellModel = cellModel
		self.onInfoButtonTap = onInfoButtonTap

		checkboxImageView.image = cellModel.image
		label.text = cellModel.text

		addParameterViews(for: cellModel.entryType)

		parametersContainerStackView.isHidden = cellModel.parametersHidden

		accessibilityTraits = cellModel.accessibilityTraits

		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
		headerStackView.addGestureRecognizer(tapGestureRecognizer)
		headerStackView.isUserInteractionEnabled = true
	}

	// MARK: - Private

	private var cellModel: DiaryDayEntryCellModel!
	private var onInfoButtonTap: (() -> Void)!

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
		button.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)

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
		label.style = .body
		label.text = AppStrings.ContactDiary.Day.Visit.duration

		let durationPicker = UIDatePicker()
		durationPicker.addTarget(self, action: #selector(didSelectDuration(datePicker:)), for: .editingDidEnd)
		// German locale ensures 24h format.
		durationPicker.locale = Locale(identifier: "de_DE")
		durationPicker.datePickerMode = .time
		durationPicker.minuteInterval = 15
		durationPicker.date = Date.dateWithMinutes(cellModel.locationVisitDuration) ?? Date()
		if #available(iOS 14.0, *) {
			durationPicker.preferredDatePickerStyle = .inline
		}

		durationPicker.widthAnchor.constraint(lessThanOrEqualToConstant: 100).isActive = true

		stackView.addArrangedSubview(label)
		stackView.addArrangedSubview(durationPicker)

		return stackView
	}()

	@objc
	private func didSelectDuration(datePicker: UIDatePicker) {
		cellModel.updateLocationVisit(durationInMinutes: datePicker.date.todaysMinutes)
	}

	@objc
	private func headerTapped() {
		cellModel.toggleSelection()
	}

	@objc
	private func infoButtonTapped() {
		onInfoButtonTap()
	}

	private func addParameterViews(for entryType: DiaryEntryType) {
		parametersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		switch entryType {
		case .contactPerson:
			parametersStackView.addArrangedSubview(durationSegmentedControl)
			parametersStackView.addArrangedSubview(maskSituationSegmentedControl)
			parametersStackView.addArrangedSubview(settingSegmentedControl)

			parametersStackView.setCustomSpacing(16, after: settingSegmentedControl)

			notesTextField.placeholder = AppStrings.ContactDiary.Day.Encounter.notesPlaceholder
		case .location:
			parametersStackView.addArrangedSubview(visitDurationStackView)

			notesTextField.placeholder = AppStrings.ContactDiary.Day.Visit.notesPlaceholder
		}

		parametersStackView.addArrangedSubview(notesStackView)
	}

}

////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryDayEntryTableViewCell: UITableViewCell, UITextFieldDelegate {

	// MARK: - Protocol UITextFieldDelegate

	func textFieldDidEndEditing(_ textField: UITextField) {
		cellModel.updateCircumstances(textField.text ?? "")
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		endEditing(true)
	}

	// MARK: - Internal

	func configure(
		cellModel: DiaryDayEntryCellModel,
		onInfoButtonTap: @escaping () -> Void
	) {
		self.cellModel = cellModel
		self.onInfoButtonTap = onInfoButtonTap

		checkboxImageView.image = cellModel.image
		label.text = cellModel.text
		label.font = cellModel.font

		addParameterViews()

		parametersContainerStackView.isHidden = cellModel.parametersHidden

		durationSegmentedControl.selectedSegmentIndex = cellModel.selectedDurationSegmentIndex
		maskSituationSegmentedControl.selectedSegmentIndex = cellModel.selectedMaskSituationSegmentIndex
		settingSegmentedControl.selectedSegmentIndex = cellModel.selectedSettingSegmentIndex
		visitDurationPicker.date = Date.dateWithMinutes(cellModel.locationVisitDuration) ?? Date()
		notesTextField.text = cellModel.circumstances

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
		let segmentedControl = DiarySegmentedControl(items: cellModel.durationValues.map { $0.title })
		segmentedControl.addTarget(self, action: #selector(durationValueChanged(sender:)), for: .valueChanged)

		return segmentedControl
	}()

	lazy var maskSituationSegmentedControl: DiarySegmentedControl = {
		let segmentedControl = DiarySegmentedControl(items: cellModel.maskSituationValues.map { $0.title })
		segmentedControl.addTarget(self, action: #selector(maskSituationValueChanged(sender:)), for: .valueChanged)

		return segmentedControl
	}()

	lazy var settingSegmentedControl: DiarySegmentedControl = {
		let segmentedControl = DiarySegmentedControl(items: cellModel.settingValues.map { $0.title })
		segmentedControl.addTarget(self, action: #selector(settingValueChanged(sender:)), for: .valueChanged)

		return segmentedControl
	}()

	lazy var notesTextField: DiaryEntryTextField = {
		let textField = DiaryEntryTextField(frame: .zero)
		textField.backgroundColor = .enaColor(for: .darkBackground)
		textField.clearButtonMode = .whileEditing
		textField.textColor = .enaColor(for: .textPrimary1)
		textField.returnKeyType = .done
		textField.delegate = self

		textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 40.0).isActive = true

		return textField
	}()

	lazy var notesInfoButton: UIButton = {
		let button = UIButton(type: .infoLight)
		button.tintColor = .enaColor(for: .tint)
		button.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
		button.setContentCompressionResistancePriority(.required, for: .horizontal)

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

	lazy var visitDurationPicker: UIDatePicker = {
		let durationPicker = UIDatePicker()
		durationPicker.addTarget(self, action: #selector(didSelectDuration(datePicker:)), for: .editingDidEnd)
		// German locale ensures 24h format.
		durationPicker.locale = Locale(identifier: "de_DE")
		durationPicker.datePickerMode = .time
		durationPicker.minuteInterval = 15

		if #available(iOS 14.0, *) {
			durationPicker.preferredDatePickerStyle = .inline
		}

		durationPicker.widthAnchor.constraint(lessThanOrEqualToConstant: 100).isActive = true

		return durationPicker
	}()

	lazy var visitDurationStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.spacing = 8

		let label = ENALabel()
		label.style = .body
		label.text = AppStrings.ContactDiary.Day.Visit.duration

		stackView.addArrangedSubview(label)
		stackView.addArrangedSubview(visitDurationPicker)

		return stackView
	}()

	private func addParameterViews() {
		parametersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		switch cellModel.entryType {
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

	@objc
	private func didSelectDuration(datePicker: UIDatePicker) {
		cellModel.updateLocationVisit(durationInMinutes: datePicker.date.todaysMinutes)
	}

	@objc
	private func headerTapped() {
		cellModel.toggleSelection()
	}

	@objc
	private func durationValueChanged(sender: UISegmentedControl) {
		cellModel.selectDuration(at: sender.selectedSegmentIndex)
	}

	@objc
	private func maskSituationValueChanged(sender: UISegmentedControl) {
		cellModel.selectMaskSituation(at: sender.selectedSegmentIndex)
	}

	@objc
	private func settingValueChanged(sender: UISegmentedControl) {
		cellModel.selectSetting(at: sender.selectedSegmentIndex)
	}

	@objc
	private func infoButtonTapped() {
		onInfoButtonTap()
	}

}

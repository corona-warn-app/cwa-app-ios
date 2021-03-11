////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryDayEntryTableViewCell: UITableViewCell, UITextFieldDelegate {

	// MARK: - Init
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}

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

		headerView.iconView.image = cellModel.image
		headerView.titleLabel.text = cellModel.text
		headerView.titleLabel.font = cellModel.font

		switch cellModel.entryType {
		case .contactPerson:
			// hide location view
			locationView.isHidden = true
			NSLayoutConstraint.deactivate(locationViewConstraints)
			// update notes placeholder text
			notesView.textField.placeholder = AppStrings.ContactDiary.Day.Encounter.notesPlaceholder
			// setup
			if cellModel.parametersHidden {
				headerView.line.isHidden = true
				contactPersonView.isHidden = true
				notesView.isHidden = true
				NSLayoutConstraint.deactivate(contactPersonViewConstraints)
				NSLayoutConstraint.deactivate(notesViewConstraints)
			} else {
				headerView.line.isHidden = false
				contactPersonView.cellModel = cellModel
				contactPersonView.durationSegmentedControl.selectedSegmentIndex = cellModel.selectedDurationSegmentIndex
				contactPersonView.maskSituationSegmentedControl.selectedSegmentIndex = cellModel.selectedMaskSituationSegmentIndex
				contactPersonView.settingSegmentedControl.selectedSegmentIndex = cellModel.selectedSettingSegmentIndex
				contactPersonView.isHidden = false
				notesView.isHidden = false
				NSLayoutConstraint.activate(contactPersonViewConstraints)
				NSLayoutConstraint.activate(notesViewConstraints)
			}

		case .location:
			// hide contact person view
			contactPersonView.isHidden = true
			NSLayoutConstraint.deactivate(contactPersonViewConstraints)
			// update notes placeholder text
			notesView.textField.placeholder = AppStrings.ContactDiary.Day.Visit.notesPlaceholder
			// setup
			if cellModel.parametersHidden {
				headerView.line.isHidden = true
				locationView.isHidden = true
				notesView.isHidden = true
				NSLayoutConstraint.deactivate(locationViewConstraints)
				NSLayoutConstraint.deactivate(notesViewConstraints)
			} else {
				headerView.line.isHidden = false
				locationView.durationPicker.date = Date.dateWithMinutes(cellModel.locationVisitDuration) ?? Date()
				locationView.isHidden = false
				notesView.isHidden = false
				NSLayoutConstraint.activate(locationViewConstraints)
				NSLayoutConstraint.activate(notesViewConstraints)
			}
		}

		notesView.textField.text = cellModel.circumstances
		accessibilityTraits = cellModel.accessibilityTraits
	}

	// MARK: - Private

	private var cellModel: DiaryDayEntryCellModel!
	private var onInfoButtonTap: (() -> Void)!

	private var headerView: DiaryDayCellHeaderView!
	private var contactPersonView: ContactPersonView!
	private var locationView: LocationView!
	private var notesView: NotesView!
	 
	private var contactPersonViewConstraints: [NSLayoutConstraint]!
	private var locationViewConstraints: [NSLayoutConstraint]!
	private var notesViewConstraints: [NSLayoutConstraint]!
	
	private func setupView() {
		// self
		selectionStyle = .none
		// wrapperView
		let wrapperView = UIView()
		wrapperView.backgroundColor = .enaColor(for: .cellBackground)
		wrapperView.layer.masksToBounds = true
		wrapperView.layer.cornerRadius = 12
		wrapperView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(wrapperView)
		// headerView
		headerView = DiaryDayCellHeaderView()
		wrapperView.addSubview(headerView)
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
		headerView.addGestureRecognizer(tapGestureRecognizer)
		headerView.isUserInteractionEnabled = true
		// notesView
		notesView = NotesView()
		notesView.textField.delegate = self
		notesView.infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
		wrapperView.addSubview(notesView)
		// contactPersonView
		contactPersonView = ContactPersonView()
		contactPersonView.durationSegmentedControl.addTarget(self, action: #selector(durationValueChanged(sender:)), for: .valueChanged)
		contactPersonView.maskSituationSegmentedControl.addTarget(self, action: #selector(maskSituationValueChanged(sender:)), for: .valueChanged)
		contactPersonView.settingSegmentedControl.addTarget(self, action: #selector(settingValueChanged(sender:)), for: .valueChanged)
		wrapperView.addSubview(contactPersonView)
		// locationView
		locationView = LocationView()
		if #available(iOS 14.0, *) {
			// UIDatePickers behave differently on iOS 14+. The .valueChanged event would be called too early and reload the cell before the animation is finished.
			// The .editingDidEnd event is triggered after the animation is finished.
			locationView.durationPicker.addTarget(self, action: #selector(didSelectDuration(datePicker:)), for: .editingDidEnd)
		} else {
			// Before iOS 14 .editingDidEnd was not called at all, therefore we use .valueChanged, which was called after the animation is finished.
			locationView.durationPicker.addTarget(self, action: #selector(didSelectDuration(datePicker:)), for: .valueChanged)
		}
		wrapperView.addSubview(locationView)
		// setup constriants
		contactPersonViewConstraints = [
			contactPersonView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
			contactPersonView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
			contactPersonView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0),
			contactPersonView.bottomAnchor.constraint(equalTo: notesView.topAnchor, constant: 0)
		]
		locationViewConstraints = [
			locationView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
			locationView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
			locationView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0),
			locationView.bottomAnchor.constraint(equalTo: notesView.topAnchor, constant: 0)
		]
		notesViewConstraints = [
			notesView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
			notesView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
			notesView.topAnchor.constraint(greaterThanOrEqualTo: headerView.bottomAnchor, constant: 15),
			notesView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor)
		]
		// activate constrinats
		NSLayoutConstraint.activate([
			// wrapperView
			wrapperView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			wrapperView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			wrapperView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
			wrapperView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
			// headerView
			headerView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
			headerView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
			headerView.topAnchor.constraint(equalTo: wrapperView.topAnchor),
			headerView.bottomAnchor.constraint(lessThanOrEqualTo: wrapperView.bottomAnchor)
		])
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

private final class ContactPersonView: UIView {
	
	// MARK: - Init
	
	convenience init() {
		self.init(frame: .zero)
		// durationSegmentedControl
		durationSegmentedControl = DiarySegmentedControl()
		durationSegmentedControl.accessibilityIdentifier = AccessibilityIdentifiers.ContactDiaryInformation.Day.durationSegmentedContol
		durationSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
		addSubview(durationSegmentedControl)
		// maskSituationSegmentedControl
		maskSituationSegmentedControl = DiarySegmentedControl()
		maskSituationSegmentedControl.accessibilityIdentifier = AccessibilityIdentifiers.ContactDiaryInformation.Day.maskSituationSegmentedControl
		maskSituationSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
		addSubview(maskSituationSegmentedControl)
		// settingSegmentedControl
		settingSegmentedControl = DiarySegmentedControl()
		settingSegmentedControl.accessibilityIdentifier = AccessibilityIdentifiers.ContactDiaryInformation.Day.settingSegmentedControl
		settingSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
		addSubview(settingSegmentedControl)
		// activate constrinats
		NSLayoutConstraint.activate([
			// durationSegmentedControl
			durationSegmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
			durationSegmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
			durationSegmentedControl.topAnchor.constraint(equalTo: topAnchor, constant: 15),
			durationSegmentedControl.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -15),
			// maskSituationSegmentedControl
			maskSituationSegmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
			maskSituationSegmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
			maskSituationSegmentedControl.topAnchor.constraint(equalTo: durationSegmentedControl.bottomAnchor, constant: 10),
			maskSituationSegmentedControl.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -15),
			// settingSegmentedControl
			settingSegmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
			settingSegmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
			settingSegmentedControl.topAnchor.constraint(equalTo: maskSituationSegmentedControl.bottomAnchor, constant: 10),
			settingSegmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
		])
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		// self
		translatesAutoresizingMaskIntoConstraints = false
	}
	
	// MARK: - Internal
	
	var durationSegmentedControl: DiarySegmentedControl!
	var maskSituationSegmentedControl: DiarySegmentedControl!
	var settingSegmentedControl: DiarySegmentedControl!
	
	var cellModel: DiaryDayEntryCellModel? {
		didSet {
			// clear
			durationSegmentedControl.removeAllSegments()
			maskSituationSegmentedControl.removeAllSegments()
			settingSegmentedControl.removeAllSegments()
			// setup
			guard let cellModel = cellModel else {
				return
			}
			cellModel.durationValues.enumerated().forEach { durationSegmentedControl.insertSegment(withTitle: $0.element.title, at: $0.offset, animated: false) }
			cellModel.maskSituationValues.enumerated().forEach { maskSituationSegmentedControl.insertSegment(withTitle: $0.element.title, at: $0.offset, animated: false) }
			cellModel.settingValues.enumerated().forEach { settingSegmentedControl.insertSegment(withTitle: $0.element.title, at: $0.offset, animated: false) }
		}
	}
}

private final class LocationView: UIView {
	
	// MARK: - Init
	
	convenience init() {
		self.init(frame: .zero)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		// self
		translatesAutoresizingMaskIntoConstraints = false
		// label
		let label = ENALabel()
		label.style = .headline
		label.text = AppStrings.ContactDiary.Day.Visit.duration
		label.translatesAutoresizingMaskIntoConstraints = false
		addSubview(label)
		// durationPicker
		durationPicker = UIDatePicker()
		durationPicker.locale = Locale(identifier: "de_DE") // German locale ensures 24h format.
		durationPicker.datePickerMode = .time
		durationPicker.minuteInterval = 15
		durationPicker.tintColor = .enaColor(for: .tint)
		durationPicker.translatesAutoresizingMaskIntoConstraints = false
		if #available(iOS 14.0, *) {
			durationPicker.preferredDatePickerStyle = .inline
		}
		addSubview(durationPicker)
		// activate constrinats
		NSLayoutConstraint.activate([
			// checkboxImageView
			durationPicker.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 15),
			durationPicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
			durationPicker.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 6),
			durationPicker.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -6),
			durationPicker.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
			// label
			label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
			label.trailingAnchor.constraint(lessThanOrEqualTo: durationPicker.leadingAnchor, constant: -8),
			label.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 6),
			label.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -6),
			label.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}
	
	// MARK: - Internal
	
	var durationPicker: UIDatePicker!
}

private final class NotesView: UIView {
	
	// MARK: - Init
	
	convenience init() {
		self.init(frame: .zero)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		// self
		translatesAutoresizingMaskIntoConstraints = false
		// checkboxImageView
		infoButton = UIButton(type: .infoLight)
		infoButton.accessibilityIdentifier = AccessibilityIdentifiers.ContactDiaryInformation.Day.notesInfoButton
		infoButton.tintColor = .enaColor(for: .tint)
		infoButton.setContentCompressionResistancePriority(.required, for: .horizontal)
		infoButton.translatesAutoresizingMaskIntoConstraints = false
		addSubview(infoButton)
		// textField
		textField = DiaryEntryTextField(frame: .zero)
		textField.accessibilityIdentifier = AccessibilityIdentifiers.ContactDiaryInformation.Day.notesTextField
		textField.backgroundColor = .enaColor(for: .darkBackground)
		textField.clearButtonMode = .whileEditing
		textField.textColor = .enaColor(for: .textPrimary1)
		textField.returnKeyType = .done
		textField.layer.borderWidth = 0
		textField.translatesAutoresizingMaskIntoConstraints = false
		addSubview(textField)
		// activate constrinats
		NSLayoutConstraint.activate([
			// infoButton
			infoButton.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 15),
			infoButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
			infoButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
			// textField
			textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
			textField.trailingAnchor.constraint(equalTo: infoButton.leadingAnchor, constant: -15),
			textField.topAnchor.constraint(equalTo: topAnchor),
			textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
			textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 40.0)
		])
	}
	
	// MARK: - Internal
	
	var infoButton: UIButton!
	var textField: DiaryEntryTextField!

}

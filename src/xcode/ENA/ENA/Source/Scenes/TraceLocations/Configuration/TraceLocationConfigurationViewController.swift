//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TraceLocationConfigurationViewController: UIViewController, FooterViewHandling, UITextFieldDelegate {

	// MARK: - Init

	init(
		viewModel: TraceLocationConfigurationViewModel,
		onDismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.onDismiss = onDismiss

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		parent?.navigationItem.title = AppStrings.TraceLocations.Configuration.title
		parent?.navigationItem.rightBarButtonItem = CloseBarButtonItem { [weak self] in
			self?.onDismiss()
		}

		setUpLayout()
		setUpGestureRecognizers()
		setUpBindings()

		let initialDefaultCheckInLength = viewModel.defaultCheckInLengthTimeInterval ?? viewModel.defaultDefaultCheckInLengthTimeInterval

		temporaryDefaultLengthPicker.countDownDuration = initialDefaultCheckInLength
		permanentDefaultLengthPicker.countDownDuration = initialDefaultCheckInLength

		traceLocationTypeLabel.text = viewModel.traceLocationTypeTitle
		temporarySettingsContainerView.isHidden = viewModel.temporarySettingsContainerIsHidden
		permanentSettingsContainerView.isHidden = viewModel.permanentSettingsContainerIsHidden

		descriptionTextField.placeholder = AppStrings.TraceLocations.Configuration.descriptionPlaceholder
		addressTextField.placeholder = AppStrings.TraceLocations.Configuration.addressPlaceholder

		startDateTitleLabel.text = AppStrings.TraceLocations.Configuration.startDateTitle
		endDateTitleLabel.text = AppStrings.TraceLocations.Configuration.endDateTitle

		temporaryDefaultLengthTitleLabel.text = AppStrings.TraceLocations.Configuration.defaultCheckinLengthTitle
		temporaryDefaultLengthFootnoteLabel.text = AppStrings.TraceLocations.Configuration.defaultCheckinLengthFootnote
		permanentDefaultLengthTitleLabel.text = AppStrings.TraceLocations.Configuration.defaultCheckinLengthTitle
		permanentDefaultLengthFootnoteLabel.text = AppStrings.TraceLocations.Configuration.defaultCheckinLengthFootnote

	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		footerView?.setLoadingIndicator(true, disable: true, button: .primary)
		viewModel.save { [weak self] success in
			self?.footerView?.setLoadingIndicator(false, disable: false, button: .primary)
			if success {
				self?.onDismiss()
			}
		}
	}

	// MARK: - Private

	private let viewModel: TraceLocationConfigurationViewModel
	private let onDismiss: () -> Void

	private var subscriptions = Set<AnyCancellable>()

	@IBOutlet private weak var traceLocationTypeLabel: ENALabel!

	@IBOutlet private weak var textFieldContainerView: UIView!
	@IBOutlet private weak var descriptionTextField: ENATextField!
	@IBOutlet private weak var addressTextField: ENATextField!

	// MARK: Temporary Trace Location Settings

	@IBOutlet private weak var temporarySettingsContainerView: UIView!

	@IBOutlet private weak var startDateHeaderContainerView: UIView!
	@IBOutlet private weak var startDateTitleLabel: ENALabel!
	@IBOutlet private weak var startDateValueLabel: ENALabel!

	@IBOutlet private weak var startDatePickerContainerView: UIView!
	@IBOutlet private weak var startDatePicker: UIDatePicker!

	@IBOutlet private weak var endDateHeaderContainerView: UIView!
	@IBOutlet private weak var endDateTitleLabel: ENALabel!
	@IBOutlet private weak var endDateValueLabel: ENALabel!

	@IBOutlet private weak var endDatePickerContainerView: UIView!
	@IBOutlet private weak var endDatePicker: UIDatePicker!

	@IBOutlet private weak var temporaryDefaultLengthHeaderContainerView: UIView!
	@IBOutlet private weak var temporaryDefaultLengthTitleLabel: ENALabel!
	@IBOutlet private weak var temporaryDefaultLengthSwitch: UISwitch!
	@IBOutlet private weak var temporaryDefaultLengthFootnoteLabel: ENALabel!

	@IBOutlet private weak var temporaryDefaultLengthPickerContainerView: UIView!
	@IBOutlet private weak var temporaryDefaultLengthPickerBackgroundView: UIView!
	@IBOutlet private weak var temporaryDefaultLengthPicker: UIDatePicker!

	// MARK: Permanent Trace Location Settings

	@IBOutlet private weak var permanentSettingsContainerView: UIView!

	@IBOutlet private weak var permanentDefaultLengthHeaderContainerView: UIView!
	@IBOutlet private weak var permanentDefaultLengthTitleLabel: ENALabel!
	@IBOutlet private weak var permanentDefaultLengthValueLabel: ENALabel!
	@IBOutlet private weak var permanentDefaultLengthFootnoteLabel: ENALabel!

	@IBOutlet private weak var permanentDefaultLengthPickerContainerView: UIView!
	@IBOutlet private weak var permanentDefaultLengthPickerBackgroundView: UIView!
	@IBOutlet private weak var permanentDefaultLengthPicker: UIDatePicker!

	private func setUpLayout() {
		footerView?.setBackgroundColor(.enaColor(for: .darkBackground))

		textFieldContainerView.layer.cornerRadius = 8
		temporarySettingsContainerView.layer.cornerRadius = 8
		temporaryDefaultLengthPickerBackgroundView.layer.cornerRadius = 14
		permanentSettingsContainerView.layer.cornerRadius = 8
		permanentDefaultLengthPickerBackgroundView.layer.cornerRadius = 14

		if #available(iOS 13.0, *) {
			textFieldContainerView.layer.cornerCurve = .continuous
			temporarySettingsContainerView.layer.cornerCurve = .continuous
			temporaryDefaultLengthPickerBackgroundView.layer.cornerCurve = .continuous
			permanentSettingsContainerView.layer.cornerCurve = .continuous
			permanentDefaultLengthPickerBackgroundView.layer.cornerCurve = .continuous
		}

		temporaryDefaultLengthPickerBackgroundView.layer.borderWidth = 1
		temporaryDefaultLengthPickerBackgroundView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor

		permanentDefaultLengthPickerBackgroundView.layer.borderWidth = 1
		permanentDefaultLengthPickerBackgroundView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor

		descriptionTextField.layer.cornerRadius = 0
		addressTextField.layer.cornerRadius = 0

		if #available(iOS 14.0, *) {
			startDatePicker.preferredDatePickerStyle = .inline
			endDatePicker.preferredDatePickerStyle = .inline
		}
	}

	private func setUpGestureRecognizers() {
		let startDateGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(startDateHeaderTapped))
		startDateHeaderContainerView.addGestureRecognizer(startDateGestureRecognizer)

		let endDateGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endDateHeaderTapped))
		endDateHeaderContainerView.addGestureRecognizer(endDateGestureRecognizer)

		let temporaryDefaultLengthGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(temporaryDefaultLengthHeaderTapped))
		temporaryDefaultLengthHeaderContainerView.addGestureRecognizer(temporaryDefaultLengthGestureRecognizer)

		let permanentDefaultLengthGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(permanentDefaultLengthHeaderTapped))
		permanentDefaultLengthHeaderContainerView.addGestureRecognizer(permanentDefaultLengthGestureRecognizer)
	}

	@objc
	private func startDateHeaderTapped() {
		viewModel.startDateHeaderTapped()
		view.endEditing(true)
	}

	@objc
	private func endDateHeaderTapped() {
		viewModel.endDateHeaderTapped()
		view.endEditing(true)
	}

	@objc
	private func temporaryDefaultLengthHeaderTapped() {
		viewModel.temporaryDefaultLengthHeaderTapped()
		view.endEditing(true)
	}

	@objc
	private func permanentDefaultLengthHeaderTapped() {
		viewModel.permanentDefaultLengthHeaderTapped()
		view.endEditing(true)
	}

	@IBAction func descriptionTextFieldEditingDidBegin() {
		viewModel.collapseAllSections()
	}

	@IBAction func descriptionTextFieldEditingDidEnd(_ sender: ENATextField) {
		viewModel.description = sender.text
	}

	@IBAction func descriptionTextFieldPrimaryActionTriggered() {
		addressTextField.becomeFirstResponder()
	}

	@IBAction func addressTextFieldEditingDidBegin() {
		viewModel.collapseAllSections()
	}

	@IBAction func addressTextFieldEditingDidEnd(_ sender: ENATextField) {
		viewModel.address = sender.text
	}

	@IBAction func addressTextFieldPrimaryActionTriggered() {
		view.endEditing(true)
	}

	@IBAction func defaultCheckinLengthValueChanged(_ sender: UIDatePicker) {
		viewModel.defaultCheckinLengthValueChanged(to: sender.countDownDuration)
	}

	@IBAction private func didSelectDate(datePicker: UIDatePicker) {
		switch datePicker {
		case startDatePicker:
			viewModel.startDate = datePicker.date
		case endDatePicker:
			viewModel.endDate = datePicker.date
		default:
			Log.error("Date picker selection not handled.")
		}
	}

	@IBAction func temporaryDefaultLengthSwitchToggled(_ sender: UISwitch) {
		viewModel.temporaryDefaultLengthSwitchSet(to: sender.isOn)
	}

	private func setUpBindings() {
		viewModel.$description
			.assign(to: \.text, on: descriptionTextField)
			.store(in: &subscriptions)

		viewModel.$address
			.assign(to: \.text, on: addressTextField)
			.store(in: &subscriptions)

		viewModel.$startDate
			.sink { [weak self] in
				self?.startDatePicker.date = $0 ?? Date()
			}
			.store(in: &subscriptions)

		viewModel.$startDate
			.assign(to: \.minimumDate, on: endDatePicker)
			.store(in: &subscriptions)

		viewModel.$endDate
			.sink { [weak self] in
				self?.endDatePicker.date = $0 ?? Date()
			}
			.store(in: &subscriptions)

		viewModel.$formattedStartDate
			.assign(to: \.text, on: startDateValueLabel)
			.store(in: &subscriptions)

		viewModel.$startDateValueTextColor
			.assign(to: \.textColor, on: startDateValueLabel)
			.store(in: &subscriptions)

		viewModel.$formattedEndDate
			.assign(to: \.text, on: endDateValueLabel)
			.store(in: &subscriptions)

		viewModel.$endDateValueTextColor
			.assign(to: \.textColor, on: endDateValueLabel)
			.store(in: &subscriptions)

		viewModel.$startDatePickerIsHidden
			.sink { [weak self] isHidden in
				self?.startDatePickerContainerView.isHidden = isHidden
			}
			.store(in: &subscriptions)

		viewModel.$endDatePickerIsHidden
			.sink { [weak self] isHidden in
				self?.endDatePickerContainerView.isHidden = isHidden
			}
			.store(in: &subscriptions)

		viewModel.$temporaryDefaultLengthPickerIsHidden
			.sink { [weak self] isHidden in
				self?.temporaryDefaultLengthPickerContainerView.isHidden = isHidden
			}
			.store(in: &subscriptions)

		viewModel.$temporaryDefaultLengthSwitchIsOn
			.sink { [weak self] isOn in
				self?.temporaryDefaultLengthSwitch.setOn(isOn, animated: true)
			}
			.store(in: &subscriptions)

		viewModel.$formattedDefaultCheckInLength
			.sink { [weak self] in
				self?.permanentDefaultLengthValueLabel.text = $0
			}
			.store(in: &subscriptions)

		viewModel.$permanentDefaultLengthValueTextColor
			.assign(to: \.textColor, on: permanentDefaultLengthValueLabel)
			.store(in: &subscriptions)

		viewModel.$permanentDefaultLengthPickerIsHidden
			.sink { [weak self] isHidden in
				self?.permanentDefaultLengthPickerContainerView.isHidden = isHidden
			}
			.store(in: &subscriptions)
	}

}

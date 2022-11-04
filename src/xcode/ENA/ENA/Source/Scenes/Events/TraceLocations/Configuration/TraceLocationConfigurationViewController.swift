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

		navigationItem.title = AppStrings.TraceLocations.Configuration.title
		navigationItem.rightBarButtonItem = CloseBarButtonItem { [weak self] in
			self?.onDismiss()
		}

		setUpLayout()
		setUpGestureRecognizers()
		setUpBindings()
		setupAccessibility()

		temporaryDefaultLengthPicker.countDownDuration = TimeInterval(minutes: viewModel.defaultCheckInLengthInMinutes) ?? viewModel.defaultTemporaryCheckInLengthTimeInterval
		permanentDefaultLengthPicker.countDownDuration = TimeInterval(minutes: viewModel.defaultCheckInLengthInMinutes) ?? viewModel.defaultPermanentCheckInLengthTimeInterval

		traceLocationTypeLabel.text = viewModel.traceLocationTypeTitle
		temporarySettingsContainerView.isHidden = viewModel.temporarySettingsContainerIsHidden
		permanentSettingsContainerView.isHidden = viewModel.permanentSettingsContainerIsHidden

		descriptionTextField.placeholder = AppStrings.TraceLocations.Configuration.descriptionPlaceholder
		descriptionTextField.autocapitalizationType = .sentences
		addressTextField.placeholder = AppStrings.TraceLocations.Configuration.addressPlaceholder
		addressTextField.autocapitalizationType = .sentences

		startDateTitleLabel.text = AppStrings.TraceLocations.Configuration.startDateTitle
		endDateTitleLabel.text = AppStrings.TraceLocations.Configuration.endDateTitle

		temporaryDefaultLengthTitleLabel.text = AppStrings.TraceLocations.Configuration.defaultCheckinLengthTitle
		temporaryDefaultLengthFootnoteLabel.text = AppStrings.TraceLocations.Configuration.defaultCheckinLengthFootnote
		permanentDefaultLengthTitleLabel.text = AppStrings.TraceLocations.Configuration.defaultCheckinLengthTitle
		permanentDefaultLengthFootnoteLabel.text = AppStrings.TraceLocations.Configuration.defaultCheckinLengthFootnote

	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		do {
			try viewModel.save()
			onDismiss()
		} catch {
			Log.error("Error saving trace location: \(error.localizedDescription)", log: .traceLocation, error: error)
			showError(error)
		}
	}

	func didShowKeyboard(_ size: CGRect) {
		guard let selectedPickerFrame = currentSelectedDatePicker?.frame else {
			return
		}
		scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: size.height, right: 0.0)
		scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: size.height, right: 0.0)
		scrollView.scrollRectToVisible(selectedPickerFrame, animated: true)
	}

	func didHideKeyboard() {
		scrollView.scrollIndicatorInsets = .zero
	}

	// MARK: - Private

	private let viewModel: TraceLocationConfigurationViewModel
	private let onDismiss: () -> Void

	private var subscriptions = Set<AnyCancellable>()
	private var currentSelectedDatePicker: UIDatePicker?

	@IBOutlet private weak var scrollView: UIScrollView!
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
		footerView?.setBackgroundColor(.enaColor(for: .background))
		textFieldContainerView.backgroundColor = .enaColor(for: .cellBackground)
		permanentSettingsContainerView.backgroundColor = .enaColor(for: .cellBackground)
		temporarySettingsContainerView.backgroundColor = .enaColor(for: .cellBackground)
		temporaryDefaultLengthPickerBackgroundView.backgroundColor = .enaColor(for: .cellBackground)
		temporaryDefaultLengthPickerContainerView.backgroundColor = .enaColor(for: .cellBackground)

		scrollView.backgroundColor = .enaColor(for: .background)
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

		if #available(iOS 15.0, *) {
			startDatePicker.preferredDatePickerStyle = .inline
			endDatePicker.preferredDatePickerStyle = .inline
		} else if #available(iOS 13.4, *) {
			startDatePicker.preferredDatePickerStyle = .wheels
			endDatePicker.preferredDatePickerStyle = .wheels
		}

		startDatePicker.addTarget(self, action: #selector(selectDatePicker(sender:)), for: .editingDidBegin)
		endDatePicker.addTarget(self, action: #selector(selectDatePicker(sender:)), for: .editingDidBegin)

		startDatePicker.addTarget(self, action: #selector(deselectDatePicker(sender:)), for: .editingDidEnd)
		endDatePicker.addTarget(self, action: #selector(deselectDatePicker(sender:)), for: .editingDidEnd)
	}

	@objc
	private func selectDatePicker(sender: UIDatePicker) {
		currentSelectedDatePicker = sender
	}

	@objc
	private func deselectDatePicker(sender: UIDatePicker) {
		currentSelectedDatePicker = nil
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

	@IBAction private func descriptionTextFieldEditingDidBegin() {
		viewModel.collapseAllSections()
	}

	@IBAction private func descriptionTextFieldEditingChanged(_ sender: ENATextField) {
		viewModel.update(description: sender.text ?? "")
	}

	@IBAction private func descriptionTextFieldPrimaryActionTriggered() {
		addressTextField.becomeFirstResponder()
	}

	@IBAction private func addressTextFieldEditingDidBegin() {
		viewModel.collapseAllSections()
	}

	@IBAction private func addressTextFieldEditingChanged(_ sender: ENATextField) {
		viewModel.update(address: sender.text ?? "")
	}

	@IBAction private func addressTextFieldPrimaryActionTriggered() {
		view.endEditing(true)
	}

	@IBAction private func defaultCheckinLengthValueChanged(_ sender: UIDatePicker) {
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

	@IBAction private func temporaryDefaultLengthSwitchToggled(_ sender: UISwitch) {
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
				guard let self = self, self.temporaryDefaultLengthPickerContainerView.isHidden != isHidden else {
					return
				}

				self.temporaryDefaultLengthPickerContainerView.isHidden = isHidden

				// Need to set the countDownDuration after unhiding, otherwise the first valueChanged event is not triggered
				if !isHidden {
					self.temporaryDefaultLengthPicker.countDownDuration = TimeInterval(minutes: self.viewModel.defaultCheckInLengthInMinutes) ?? self.viewModel.defaultTemporaryCheckInLengthTimeInterval
				}
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
				guard let self = self, self.permanentDefaultLengthPickerContainerView.isHidden != isHidden else {
					return
				}

				self.permanentDefaultLengthPickerContainerView.isHidden = isHidden

				// Need to set the countDownDuration after unhiding, otherwise the first valueChanged event is not triggered
				if !isHidden {
					self.permanentDefaultLengthPicker.countDownDuration = TimeInterval(minutes: self.viewModel.defaultCheckInLengthInMinutes) ?? self.viewModel.defaultPermanentCheckInLengthTimeInterval
				}
			}
			.store(in: &subscriptions)

		viewModel.$primaryButtonIsEnabled
			.sink { [weak self] in
				self?.footerView?.setEnabled($0, button: .primary)
			}
			.store(in: &subscriptions)
	}
	
	private func setupAccessibility() {
		traceLocationTypeLabel.accessibilityTraits = .header
		traceLocationTypeLabel.accessibilityIdentifier = AccessibilityIdentifiers.TraceLocation.Configuration.traceLocationTypeLabel
		descriptionTextField.accessibilityIdentifier = AccessibilityIdentifiers.TraceLocation.Configuration.descriptionPlaceholder
		addressTextField.accessibilityIdentifier = AccessibilityIdentifiers.TraceLocation.Configuration.addressPlaceholder
		temporaryDefaultLengthTitleLabel.accessibilityIdentifier = AccessibilityIdentifiers.TraceLocation.Configuration.temporaryDefaultLengthTitleLabel
		temporaryDefaultLengthFootnoteLabel.accessibilityIdentifier = AccessibilityIdentifiers.TraceLocation.Configuration.temporaryDefaultLengthFootnoteLabel
		permanentDefaultLengthTitleLabel.accessibilityIdentifier = AccessibilityIdentifiers.TraceLocation.Configuration.permanentDefaultLengthTitleLabel
		permanentDefaultLengthValueLabel.accessibilityIdentifier = AccessibilityIdentifiers.TraceLocation.Configuration.permanentDefaultLengthValueLabel
		permanentDefaultLengthFootnoteLabel.accessibilityIdentifier = AccessibilityIdentifiers.TraceLocation.Configuration.permanentDefaultLengthFootnoteLabel
	}

	private func showError(_ error: Error) {
		let alert = UIAlertController(
			title: String(
				format: AppStrings.TraceLocations.Configuration.savingErrorMessage,
				String(describing: error)
			),
			message: nil,
			preferredStyle: .alert
		)

		alert.addAction(
			UIAlertAction(
				title: AppStrings.Common.alertActionOk,
				style: .default
			)
		)

		present(alert, animated: true)
	}

}

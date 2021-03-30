////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TraceLocationDetailViewController: UIViewController {

	// MARK: - Init

	init(
		_ viewModel: TraceLocationDetailViewModel,
		dismiss: @escaping () -> Void
	) {
		self.dismiss = dismiss
		self.viewModel = viewModel
		
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupView()
	}
	
	// MARK: - Private
	
	@IBOutlet private weak var bottomCardView: UIView!
	@IBOutlet private weak var descriptionView: UIView!
	@IBOutlet private weak var logoImageView: UIImageView!
	@IBOutlet private weak var checkInForLabel: ENALabel!
	@IBOutlet private weak var activityLabel: ENALabel!
	@IBOutlet private weak var descriptionLabel: ENALabel!
	@IBOutlet private weak var addressLabel: ENALabel!
	@IBOutlet private weak var saveToDiaryLabel: ENALabel!
	@IBOutlet private weak var automaticCheckOutLabel: ENALabel!
	@IBOutlet private weak var pickerButton: ENAButton!
	@IBOutlet private weak var pickerContainerView: UIView!
	@IBOutlet private weak var pickerSeparator: UIView!
	@IBOutlet private weak var datePickerView: UIDatePicker!
	@IBOutlet private weak var additionalInfoView: UIView!
	@IBOutlet private weak var additionalInfoLabel: ENALabel!
	@IBOutlet private weak var pickerSwitch: ENASwitch!
		
	private let viewModel: TraceLocationDetailViewModel
	private let dismiss: () -> Void
	private var subscriptions = Set<AnyCancellable>()
	private var isInitialSetup = true

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)
		pickerButton.setTitleColor(.enaColor(for: .textPrimary1), for: .normal)
		logoImageView.image = logoImageView.image?.withRenderingMode(.alwaysTemplate)
		logoImageView.tintColor = .enaColor(for: .textContrast)
		pickerSwitch.setOn(viewModel.shouldSaveToContactJournal, animated: false)
		addBorderAndColorToView(descriptionView, color: .enaColor(for: .hairline))
		addBorderAndColorToView(bottomCardView, color: .enaColor(for: .hairline))
		addBorderAndColorToView(additionalInfoView, color: .enaColor(for: .hairline))
		
		setupLabels()
		setupPicker()
		setupAdditionalInfoView()
		viewModel.pickerView(didSelectRow: viewModel.selectedDurationInMinutes)
		
		viewModel.$pickerButtonTitle
			.sink { [weak self] hour in
				if let hour = hour {
					self?.pickerButton.setTitle(hour, for: .normal)
				}
			}
			.store(in: &subscriptions)
	}
	
	private func setupLabels() {
		checkInForLabel.text = AppStrings.Checkins.Details.checkinFor
		activityLabel.text = AppStrings.Checkins.Details.activity
		saveToDiaryLabel.text = AppStrings.Checkins.Details.saveToDiary
		automaticCheckOutLabel.text = AppStrings.Checkins.Details.automaticCheckout
		descriptionLabel.text = viewModel.locationDescription
		addressLabel.text = viewModel.locationAddress
	}
	
	private func setupAdditionalInfoView() {
		let status = viewModel.traceLocationStatus
		switch status {
		case .notStarted:
			additionalInfoView.isHidden = false
			additionalInfoLabel.text = String(
				format: AppStrings.Checkins.Details.eventNotStartedYet,
				viewModel.formattedStartDateString,
				viewModel.formattedStartTimeString
			)
		case .ended:
			additionalInfoView.isHidden = false
			additionalInfoLabel.text = AppStrings.Checkins.Details.eventEnded
		case .inProgress:
			additionalInfoView.isHidden = true
		case .none:
			additionalInfoView.isHidden = true
		}
	}
	
	private func setupPicker() {
		datePickerView.locale = Locale(identifier: "de_DE")
		datePickerView.datePickerMode = .countDownTimer
		datePickerView.minuteInterval = 15
		datePickerView.addTarget(self, action: #selector(didSelectDuration(datePicker:)), for: .valueChanged)
	}
	
	@objc
	private func didSelectDuration(datePicker: UIDatePicker) {
		viewModel.pickerView(didSelectRow: Int(datePicker.countDownDuration / 60))
	}

	private func addBorderAndColorToView(_ view: UIView, color: UIColor) {
		view.layer.borderColor = color.cgColor
		view.layer.borderWidth = 1
	}
	
	@IBAction private func checkInPressed(_ sender: Any) {
		viewModel.saveCheckinToDatabase()
		dismiss()
	}
	
	@IBAction private func cancelButtonPressed(_ sender: Any) {
		dismiss()
	}
	
	@IBAction private func switchViewTapped(_ sender: Any) {
		pickerSwitch.setOn(!pickerSwitch.isOn, animated: true)
		switchValueChanged(sender)
	}
	
	@IBAction private func switchValueChanged(_ sender: Any) {
		viewModel.shouldSaveToContactJournal = pickerSwitch.isOn
	}

	@IBAction private func pickerViewTapped(_ sender: Any) {
		showPickerButton(sender)
	}
	
	@IBAction private func showPickerButton(_ sender: Any) {
		self.pickerContainerView.isHidden = !self.pickerContainerView.isHidden
		self.pickerSeparator.isHidden = self.pickerContainerView.isHidden
		
		let color: UIColor = pickerContainerView.isHidden ? .enaColor(for: .textPrimary1) : .enaColor(for: .textTint)
		pickerButton.setTitleColor(color, for: .normal)
		
		if !pickerContainerView.isHidden && isInitialSetup {
			isInitialSetup = false
			let components = viewModel.selectedDurationInMinutes.quotientAndRemainder(dividingBy: 60)
			let date = DateComponents(calendar: Calendar.current, hour: components.quotient, minute: components.remainder).date ?? Date()
			datePickerView.setDate(date, animated: true)
		}
	}
}

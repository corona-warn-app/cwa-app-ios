////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TraceLocationDetailViewController: UIViewController {

	// MARK: - Init

	init(
		_ traceLocation: TraceLocation,
		dismiss: @escaping () -> Void,
		presentCheckins: @escaping () -> Void
	) {
		self.dismiss = dismiss
		self.presentCheckins = presentCheckins
		self.viewModel = CheckinDetailViewModel(traceLocation)
		
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
		
	private let viewModel: CheckinDetailViewModel
	private let dismiss: () -> Void
	private let presentCheckins: () -> Void
	private var subscriptions = Set<AnyCancellable>()
	private var selectedDuration: Int?
	private var isInitialSetup = true

	private func setupView() {
		viewModel.setupView()

		view.backgroundColor = .enaColor(for: .background)
		checkInForLabel.text = AppStrings.Checkins.Details.checkinFor
		activityLabel.text = AppStrings.Checkins.Details.activity
		saveToDiaryLabel.text = AppStrings.Checkins.Details.saveToDiary
		automaticCheckOutLabel.text = AppStrings.Checkins.Details.automaticCheckout
		pickerButton.setTitleColor(.enaColor(for: .textPrimary1), for: .normal)
		logoImageView.image = logoImageView.image?.withRenderingMode(.alwaysTemplate)
		logoImageView.tintColor = .enaColor(for: .textContrast)
		addBorderAndColorToView(descriptionView, color: .enaColor(for: .hairline))
		addBorderAndColorToView(bottomCardView, color: .enaColor(for: .hairline))
		addBorderAndColorToView(additionalInfoView, color: .enaColor(for: .hairline))

		setupAdditionalInfoView()
		
		viewModel.$descriptionLabelTitle
			.sink { [weak self] description in
				self?.descriptionLabel.text = description
			}
			.store(in: &subscriptions)
		
		viewModel.$addressLabelTitle
			.sink { [weak self] address in
				self?.addressLabel.text = address
			}
			.store(in: &subscriptions)
		
		viewModel.$initialDuration
			.sink { [weak self] duration in
				self?.selectedDuration = duration
				self?.setupPicker(with: duration ?? 0)

			}
			.store(in: &subscriptions)
		
		viewModel.$pickerButtonTitle
			.sink { [weak self] hour in
				if let hour = hour {
					self?.pickerButton.setTitle(hour, for: .normal)
				}
			}
			.store(in: &subscriptions)
	}
	
	private func setupAdditionalInfoView() {
		
		additionalInfoView.isHidden = false
		additionalInfoLabel.text = String(
			format: AppStrings.Checkins.Details.eventNotStartedYet,
			viewModel.getFormattedString(for: .day) ?? "",
			viewModel.getFormattedString(for: .hour) ?? ""
		)
//
//		let status = viewModel.getTraceLocationStatus()
//		switch status {
//		case .notStarted:
//			additionalInfoView.isHidden = false
//			additionalInfoLabel.text = String(
//				format: AppStrings.Checkins.Details.eventNotStartedYet,
//				viewModel.getFormattedString(for: .day) ?? "",
//				viewModel.getFormattedString(for: .hour) ?? ""
//			)
//		case .ended:
//			additionalInfoView.isHidden = false
//			additionalInfoLabel.text = AppStrings.Checkins.Details.eventEnded
//		case .inProgress:
//			additionalInfoView.isHidden = true
//		case .none:
//			additionalInfoView.isHidden = true
//		}
	}
	
	private func setupPicker(with duration: Int) {
		datePickerView.locale = Locale(identifier: "de_DE")
		datePickerView.datePickerMode = .countDownTimer
		datePickerView.minuteInterval = 15
		datePickerView.addTarget(self, action: #selector(didSelectDuration(datePicker:)), for: .valueChanged)
	}
	
	@objc
	private func didSelectDuration(datePicker: UIDatePicker) {
		viewModel.pickerView(didSelectRow: datePicker.date.todaysMinutes)
	}

	private func addBorderAndColorToView(_ view: UIView, color: UIColor) {
		view.layer.borderColor = color.cgColor
		view.layer.borderWidth = 1
	}

	
	@IBAction private func checkInPressed(_ sender: Any) {
		viewModel.saveCheckinToDatabase()
		presentCheckins()
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
		UIView.animate(withDuration: 0.5) {
			self.pickerContainerView.isHidden = !self.pickerContainerView.isHidden
			self.pickerSeparator.isHidden = self.pickerContainerView.isHidden
		}
		let color: UIColor = pickerContainerView.isHidden ? .enaColor(for: .textPrimary1) : .enaColor(for: .buttonPrimary)
		pickerButton.setTitleColor(color, for: .normal)

		if !pickerContainerView.isHidden && isInitialSetup {
			isInitialSetup = false
			let components = selectedDuration?.quotientAndRemainder(dividingBy: 60)
			let date = DateComponents(calendar: Calendar.current, hour: components?.quotient, minute: components?.remainder).date ?? Date()
			datePickerView.setDate(date, animated: true)
		}
	}
}

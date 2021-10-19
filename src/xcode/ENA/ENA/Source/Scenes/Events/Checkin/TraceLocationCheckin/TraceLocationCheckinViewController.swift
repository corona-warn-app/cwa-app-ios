////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TraceLocationCheckinViewController: UIViewController, DismissHandling {

	// MARK: - Init

	init(
		_ viewModel: TraceLocationCheckinViewModel,
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
		setupGradientView()
		setupLabels()
		setupPicker()
		setupAdditionalInfoView()
		setupViewModel()
		setupNavigationBar()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		updateGradientViewLayout()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateBorderWidths()
		updateGradientViewLayout()
	}
	
	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}

	// MARK: - Private

	private let viewModel: TraceLocationCheckinViewModel
	private let dismiss: () -> Void

	private var backgroundView: GradientBackgroundView!
	private var contentOffsetObserver: NSKeyValueObservation!
	private var subscriptions = Set<AnyCancellable>()

	@IBOutlet private weak var scrollView: UIScrollView!
	@IBOutlet private weak var bottomCardView: UIView!
	@IBOutlet private weak var descriptionView: UIView!
	@IBOutlet private weak var switchView: UIView!
	@IBOutlet private weak var checkOutView: UIView!
	@IBOutlet private weak var checkInForLabel: ENALabel!
	@IBOutlet private weak var activityLabel: ENALabel!
	@IBOutlet private weak var descriptionLabel: ENALabel!
	@IBOutlet private weak var addressLabel: ENALabel!
	@IBOutlet private weak var saveToDiaryLabel: ENALabel!
	@IBOutlet private weak var automaticCheckOutLabel: ENALabel!
	@IBOutlet private weak var pickerButton: ENAButton!
	@IBOutlet private weak var pickerContainerView: UIView!
	@IBOutlet private weak var pickerSeparator: UIView!
	@IBOutlet private weak var countDownDatePicker: UIDatePicker!
	@IBOutlet private weak var additionalInfoView: UIView!
	@IBOutlet private weak var additionalInfoLabel: ENALabel!
	@IBOutlet private weak var pickerSwitch: ENASwitch!
	@IBOutlet private weak var checkInButton: ENAButton!
	
	private func setupViewModel() {
		viewModel.$duration
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] _ in
				guard let self = self else { return }
				self.pickerButton.setTitle(self.viewModel.pickerButtonTitle, for: .normal)
				
				self.checkOutView.accessibilityLabel = "\(AppStrings.Checkins.Details.automaticCheckout)\(self.viewModel.pickerButtonAccessibilityLabel)"
			}
			.store(in: &subscriptions)
	}
	
	private func setupNavigationBar() {
		let logoImage = UIImage(imageLiteralResourceName: "Corona-Warn-App-Small").withRenderingMode(.alwaysTemplate)
		let logoImageView = UIImageView(image: logoImage)
		logoImageView.tintColor = .enaColor(for: .textContrast)
		
		navigationController?.navigationBar.tintColor = .white
		navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoImageView)

		let closeButton = dismissHandlingCloseBarButton(.contrast)
		closeButton.accessibilityLabel = AppStrings.AccessibilityLabel.close
		closeButton.accessibilityIdentifier = AccessibilityIdentifiers.AccessibilityLabel.close
		navigationItem.rightBarButtonItem = closeButton
		navigationItem.hidesBackButton = true

		(navigationController as? DismissHandlingNavigationController)?.setupTransparentNavigationBar()
	}

	private func setupView() {
		view.backgroundColor = .enaColor(for: .backgroundLightGray)

		pickerButton.setTitleColor(.enaColor(for: .textPrimary1), for: .normal)
		pickerSwitch.setOn(viewModel.shouldSaveToContactJournal, animated: false)

		let borderColor = UIColor.enaColor(for: .hairline).cgColor
		descriptionView.layer.borderColor = borderColor
		bottomCardView.layer.borderColor = borderColor
		additionalInfoView.layer.borderColor = borderColor
		updateBorderWidths()

		checkInButton.setTitle(AppStrings.Checkins.Details.checkInButton, for: .normal)
		checkInButton.accessibilityIdentifier = AccessibilityIdentifiers.TraceLocation.Details.checkInButton

	}
	
	private func setupGradientView() {
		backgroundView = GradientBackgroundView()
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		view.insertSubview(backgroundView, at: 0)
		
		NSLayoutConstraint.activate([
			backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
			backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
		
		contentOffsetObserver = scrollView.observe(\.contentOffset, options: .new) { [weak self] scrollView, change in
			guard let self = self,
				  let yOffset = change.newValue?.y else {
				return
			}
			let offsetLimit = scrollView.frame.origin.y
			self.backgroundView.updatedTopLayout(with: yOffset, limit: offsetLimit)
		}
	}
	
	private func updateGradientViewLayout() {
		backgroundView.updatedTopLayout(with: scrollView.contentOffset.y, limit: scrollView.frame.origin.y)

		view.layoutIfNeeded()
		backgroundView.gradientHeightConstraint.constant = scrollView.frame.origin.y + descriptionView.convert(descriptionView.frame, to: scrollView).midY
	}
	
	private func setupLabels() {
		checkInForLabel.text = AppStrings.Checkins.Details.checkinFor
		checkInForLabel.accessibilityIdentifier = AccessibilityIdentifiers.Checkin.Details.checkinFor
		saveToDiaryLabel.text = AppStrings.Checkins.Details.saveToDiary
		saveToDiaryLabel.accessibilityIdentifier = AccessibilityIdentifiers.Checkin.Details.saveToDiary
		automaticCheckOutLabel.text = AppStrings.Checkins.Details.automaticCheckout
		automaticCheckOutLabel.accessibilityIdentifier = AccessibilityIdentifiers.Checkin.Details.automaticCheckout

		switchView.accessibilityLabel = "\(AppStrings.Checkins.Details.saveToDiary) \(AppStrings.Checkins.Details.saveSwitch) \(pickerSwitch.isOn ? AppStrings.Checkins.Details.saveSwitchOn : AppStrings.Checkins.Details.saveSwitchOff)"

		activityLabel.text = viewModel.locationType
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

	private var observer: NSKeyValueObservation!
	
	private func setupPicker() {
		countDownDatePicker.datePickerMode = .countDownTimer
		countDownDatePicker.minuteInterval = 15
		countDownDatePicker.addTarget(self, action: #selector(didSelectDuration(datePicker:)), for: .valueChanged)
	}
	
	@objc
	private func didSelectDuration(datePicker: UIDatePicker) {
		let duration = datePicker.countDownDuration
		viewModel.duration = duration
	}
	
	@IBAction private func checkInPressed(_ sender: Any) {
		viewModel.saveCheckinToDatabase()
		dismiss()
	}
	
	@IBAction private func switchViewTapped(_ sender: Any) {
		pickerSwitch.setOn(!pickerSwitch.isOn, animated: true)
		switchValueChanged(sender)
	}
	
	@IBAction private func switchValueChanged(_ sender: Any) {
		viewModel.shouldSaveToContactJournal = pickerSwitch.isOn
		
		switchView.accessibilityLabel = "\(AppStrings.Checkins.Details.saveToDiary) \(AppStrings.Checkins.Details.saveSwitch) \(pickerSwitch.isOn ? AppStrings.Checkins.Details.saveSwitchOn : AppStrings.Checkins.Details.saveSwitchOff)"
	}

	@IBAction private func togglePickerButtonVisibility(_ sender: Any) {
		let isHidden = !pickerContainerView.isHidden
		
		UIView.animate(withDuration: 0.15) { [weak self] in
			guard let self = self else {
				Log.debug("Failed to unwrap self")
				return
			}
			
			self.pickerContainerView.alpha = isHidden ? 0 : 1
			self.pickerContainerView.isHidden = isHidden
			self.pickerSeparator.isHidden = isHidden
			
			let color: UIColor = isHidden ? .enaColor(for: .textPrimary1) : .enaColor(for: .textTint)
			self.pickerButton.setTitleColor(color, for: .normal)

		} completion: { _ in
			if !isHidden {
				self.countDownDatePicker.removeTarget(self, action: nil, for: .allEvents)
				self.setupPicker()
				
				// scroll to date picker
				let rect = self.countDownDatePicker.convert(self.countDownDatePicker.frame, to: self.scrollView)
				self.scrollView.scrollRectToVisible(rect, animated: true)

				// the dispatch to the main queue is require because of an iOS issue
				// UIDatePicker won't call action .valueChang on first change
				// workaround is to set countDownDuration && date with a bit of delay on the main queue
				//
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: { [weak self] in
					guard let self = self else {
						Log.debug("Failed to unwrap self")
						return
					}
					let durationInMinutes = Int(self.viewModel.duration / 60)
					let components = durationInMinutes.quotientAndRemainder(dividingBy: 60)
					let date = DateComponents(calendar: Calendar.current, hour: components.quotient, minute: components.remainder).date ?? Date()

					self.countDownDatePicker.countDownDuration = self.viewModel.duration
					self.countDownDatePicker.setDate(date, animated: true)
				})
			}
		}
	}

	private func updateBorderWidths() {
		let borderWidth: CGFloat = traitCollection.userInterfaceStyle == .dark ? 0 : 1

		descriptionView.layer.borderWidth = borderWidth
		bottomCardView.layer.borderWidth = borderWidth
		additionalInfoView.layer.borderWidth = borderWidth

	}

}

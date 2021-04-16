////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TraceLocationDetailViewController: UIViewController, UIScrollViewDelegate {

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
		setupBannerView()
		setupLabels()
		setupPicker()
		setupAdditionalInfoView()
		setupViewModel()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		scrollView.scrollIndicatorInsets.top = bannerView.bounds.height
	}

	// MARK: - Protocol UIScrollViewDelegate

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		bannerView.adjustBlur(for: scrollView)
	}
	
	// MARK: - Private

	private let viewModel: TraceLocationDetailViewModel
	private let dismiss: () -> Void

	private var bannerView: GradientBlurBannerView!
	private var subscriptions = Set<AnyCancellable>()

	@IBOutlet private weak var scrollView: UIScrollView!
	@IBOutlet private weak var bottomCardView: UIView!
	@IBOutlet private weak var descriptionView: UIView!
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
			}
			.store(in: &subscriptions)
	}
	
	private func setupBannerView() {
		bannerView = GradientBlurBannerView(didTapCloseButton: { [weak self] in
			self?.dismiss()
		})
		view.addSubview(bannerView)
		NSLayoutConstraint.activate([
			bannerView.topAnchor.constraint(equalTo: view.topAnchor),
			bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			bannerView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
		])
	}

	private func setupView() {
		view.backgroundColor = .enaColor(for: .backgroundLightGray)
		scrollView.delegate = self
		pickerButton.setTitleColor(.enaColor(for: .textPrimary1), for: .normal)
		pickerSwitch.setOn(viewModel.shouldSaveToContactJournal, animated: false)
		addBorderAndColorToView(descriptionView, color: .enaColor(for: .hairline))
		addBorderAndColorToView(bottomCardView, color: .enaColor(for: .hairline))
		addBorderAndColorToView(additionalInfoView, color: .enaColor(for: .hairline))
		checkInButton.setTitle(AppStrings.Checkins.Details.checkInButton, for: .normal)
		checkInButton.accessibilityIdentifier = AccessibilityIdentifiers.TraceLocation.Details.checkInButton
	}
	
	private func setupLabels() {
		checkInForLabel.text = AppStrings.Checkins.Details.checkinFor
		checkInForLabel.accessibilityIdentifier = AccessibilityIdentifiers.Checkin.Details.checkinFor
		saveToDiaryLabel.text = AppStrings.Checkins.Details.saveToDiary
		saveToDiaryLabel.accessibilityIdentifier = AccessibilityIdentifiers.Checkin.Details.saveToDiary
		automaticCheckOutLabel.text = AppStrings.Checkins.Details.automaticCheckout
		automaticCheckOutLabel.accessibilityIdentifier = AccessibilityIdentifiers.Checkin.Details.automaticCheckout

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

	private func addBorderAndColorToView(_ view: UIView, color: UIColor) {
		view.layer.borderColor = color.cgColor
		view.layer.borderWidth = 1
	}
	
	@IBAction private func checkInPressed(_ sender: Any) {
		viewModel.saveCheckinToDatabase()
		dismiss()
	}
	
	@objc
	private func cancelButtonPressed(_ sender: Any) {
		dismiss()
	}
	
	@IBAction private func switchViewTapped(_ sender: Any) {
		pickerSwitch.setOn(!pickerSwitch.isOn, animated: true)
		switchValueChanged(sender)
	}
	
	@IBAction private func switchValueChanged(_ sender: Any) {
		viewModel.shouldSaveToContactJournal = pickerSwitch.isOn
	}

	@IBAction private func togglePickerButtonVisibility(_ sender: Any) {
		let isHidden = !pickerContainerView.isHidden
		pickerContainerView.isHidden = isHidden
		pickerSeparator.isHidden = isHidden
		
		let color: UIColor = isHidden ? .enaColor(for: .textPrimary1) : .enaColor(for: .textTint)
		pickerButton.setTitleColor(color, for: .normal)

		if !isHidden {
			countDownDatePicker.removeTarget(self, action: nil, for: .allEvents)
			setupPicker()

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

class GradientBlurBannerView: UIView {
	
	// MARK: - Init
	
	init(didTapCloseButton: @escaping () -> Void) {
		self.didTapCloseButton = didTapCloseButton
		super.init(frame: .zero)
		
		translatesAutoresizingMaskIntoConstraints = false
		
		let blurEffect = UIBlurEffect(style: .regular)
		blurView = UIVisualEffectView(effect: blurEffect)
		blurView.alpha = 0
		blurView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(blurView)
		
		let gradientView = GradientView()
		gradientView.isTilted = false
		gradientView.alpha = 0.6
		gradientView.translatesAutoresizingMaskIntoConstraints = false
		blurView.contentView.addSubview(gradientView)
		
		let gradientNavigationView = GradientNavigationView(didTapCloseButton: didTapCloseButton)
		gradientNavigationView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(gradientNavigationView)
		
		NSLayoutConstraint.activate([
			
			blurView.topAnchor.constraint(equalTo: topAnchor),
			blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
			blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
			blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			gradientView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
			gradientView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
			gradientView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
			gradientView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor),
			
			gradientNavigationView.topAnchor.constraint(equalTo: topAnchor, constant: 24.0),
			gradientNavigationView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
			gradientNavigationView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
			gradientNavigationView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.0)
		])
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Internal
		
	func adjustBlur(for scrollView: UIScrollView) {
		let alpha = (scrollView.adjustedContentInset.top + scrollView.contentOffset.y) / (bounds.height / 2)
		blurView.alpha = max(0, min(alpha, 1)) / 1
	}
	
	// MARK: - Private
	
	private let didTapCloseButton: () -> Void
	private var blurView: UIVisualEffectView!
}

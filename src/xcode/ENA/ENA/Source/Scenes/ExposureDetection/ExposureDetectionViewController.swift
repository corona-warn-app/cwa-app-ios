//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import Foundation
import UIKit

final class ExposureDetectionViewController: DynamicTableViewController, CountdownTimerDelegate, RequiresAppDependencies {

	// MARK: - Init

	init(
		state: State,
		store: Store,
		delegate: ExposureDetectionViewControllerDelegate
	) {
		self.state = state
        self.store = store
        self.delegate = delegate

		super.init(nibName: "ExposureDetectionViewController", bundle: .main)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}

	deinit {
		riskProvider.removeRisk(consumer)
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		titleLabel.accessibilityTraits = .header

		closeButton.isAccessibilityElement = true
		closeButton.accessibilityTraits = .button
		closeButton.accessibilityLabel = AppStrings.AccessibilityLabel.close
		closeButton.accessibilityIdentifier = AccessibilityIdentifiers.AccessibilityLabel.close

		registerCells()

		consumer.didCalculateRisk = { [weak self] risk in
			self?.state.riskState = .risk(risk)
			self?.updateUI()
		}

		consumer.didFailCalculateRisk = { [weak self] error in
			// Ignore already running errors.
			guard !error.isAlreadyRunningError else {
				Log.info("[ExposureDetectionViewController] Ignore already running error.", log: .riskDetection)
				return
			}

			guard error.shouldBeDisplayedToUser else {
				Log.info("[ExposureDetectionViewController] Don't show error to user: \(error).", log: .riskDetection)
				return
			}

			switch error {
			case .inactive:
				self?.state.riskState = .inactive
			default:
				self?.state.riskState = .detectionFailed
			}

			self?.updateUI()
		}

		consumer.didChangeActivityState = { [weak self] activityState in
			self?.state.activityState = activityState
		}

		riskProvider.observeRisk(consumer)
		updateUI()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateUI()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		if footerView.isHidden {
			tableView.contentInset.bottom = 0
			tableView.verticalScrollIndicatorInsets.bottom = 0
		} else {
			tableView.contentInset.bottom = footerView.frame.height - tableView.safeAreaInsets.bottom
			tableView.verticalScrollIndicatorInsets.bottom = tableView.contentInset.bottom
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)

		(cell as? DynamicTypeTableViewCell)?.backgroundColor = .clear

		if cell.backgroundView == nil {
			cell.backgroundView = UIView()
		}

		if cell.backgroundColor == nil || cell.backgroundColor == .clear {
			cell.backgroundView?.backgroundColor = .enaColor(for: .background)
		}

		return cell
	}

	// MARK: - Protocol CountdownTimerDelegate

	func countdownTimer(_ timer: CountdownTimer, didUpdate time: String) {
		self.updateCheckButton(time)
	}

	func countdownTimer(_ timer: CountdownTimer, didEnd done: Bool) {
		self.updateCheckButton()
	}

	// MARK: - Internal

	enum ReusableCellIdentifier: String, TableViewCellReuseIdentifiers {
		case risk = "riskCell"
		case riskText = "riskTextCell"
		case riskRefresh = "riskRefreshCell"
		case riskLoading = "riskLoadingCell"
		case header = "headerCell"
		case guide = "guideCell"
		case longGuide = "longGuideCell"
		case link = "linkCell"
		case hotline = "hotlineCell"
	}
    
    let store: Store

	var state: State {
		didSet {
			updateUI()
		}
	}

	func updateUI() {
		dynamicTableViewModel = dynamicTableViewModel(for: state.riskLevel, riskDetectionFailed: state.riskDetectionFailed, isTracingEnabled: state.isTracingEnabled)

		updateCloseButton()
		updateHeader()
		updateTableView()
		updateCheckButton()

		view.setNeedsLayout()
	}

	// MARK: - Private

	@IBOutlet private var closeButton: UIButton!
	@IBOutlet private var headerView: UIView!
	@IBOutlet private var titleViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet private var titleLabel: UILabel!
	@IBOutlet private var footerView: UIView!
	@IBOutlet private var checkButton: ENAButton!

	private var countdown: CountdownTimer?
	private weak var delegate: ExposureDetectionViewControllerDelegate?
	private let consumer = RiskConsumer()

	@IBAction private func tappedClose() {
		dismiss(animated: true)
	}

	@IBAction private func tappedBottomButton() {
		guard state.isTracingEnabled else {
			delegate?.exposureDetectionViewController(self, setExposureManagerEnabled: true) { error in
				if let error = error {
					self.alertError(message: error.localizedDescription, title: AppStrings.Common.alertTitleGeneral)
				}
			}
			return
		}
		riskProvider.requestRisk(userInitiated: true)
	}

	private func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let offset = scrollView.contentOffset.y

		if offset > 0 {
			titleViewBottomConstraint.constant = 0
		} else {
			titleViewBottomConstraint.constant = -offset
		}
	}

	private func registerCells() {
		tableView.register(
			UINib(nibName: String(describing: ExposureDetectionHeaderCell.self), bundle: nil),
			forCellReuseIdentifier: ReusableCellIdentifier.header.rawValue
		)

		tableView.register(
			UINib(nibName: String(describing: ExposureDetectionRiskCell.self), bundle: nil),
			forCellReuseIdentifier: ReusableCellIdentifier.risk.rawValue
		)

		tableView.register(
			UINib(nibName: String(describing: ExposureDetectionLongGuideCell.self), bundle: nil),
			forCellReuseIdentifier: ReusableCellIdentifier.longGuide.rawValue
		)

		tableView.register(
			UINib(nibName: String(describing: ExposureDetectionLoadingCell.self), bundle: nil),
			forCellReuseIdentifier: ReusableCellIdentifier.riskLoading.rawValue
		)

		tableView.register(
			UINib(nibName: String(describing: ExposureDetectionHotlineCell.self), bundle: nil),
			forCellReuseIdentifier: ReusableCellIdentifier.hotline.rawValue
		)

		tableView.register(
			UINib(nibName: "ExposureDetectionRiskRefreshCell", bundle: nil),
			forCellReuseIdentifier: ReusableCellIdentifier.riskRefresh.rawValue
		)

		tableView.register(
			UINib(nibName: "ExposureDetectionRiskTextCell", bundle: nil),
			forCellReuseIdentifier: ReusableCellIdentifier.riskText.rawValue
		)

		tableView.register(
			UINib(nibName: "ExposureDetectionGuideCell", bundle: nil),
			forCellReuseIdentifier: ReusableCellIdentifier.guide.rawValue
		)

		tableView.register(
			UINib(nibName: "ExposureDetectionLinkCell", bundle: nil),
			forCellReuseIdentifier: ReusableCellIdentifier.link.rawValue
		)
	}

	private func updateCloseButton() {
		if case .risk = state.riskState, state.isTracingEnabled {
			closeButton.setImage(UIImage(named: "Icons - Close - Contrast"), for: .normal)
			closeButton.setImage(UIImage(named: "Icons - Close - Tap - Contrast"), for: .highlighted)
		} else {
			closeButton.setImage(UIImage(named: "Icons - Close"), for: .normal)
			closeButton.setImage(UIImage(named: "Icons - Close - Tap"), for: .highlighted)
		}
	}

	private func updateHeader() {
		headerView.backgroundColor = state.riskBackgroundColor
		titleLabel.text = state.titleText
		titleLabel.textColor = state.titleTextColor
	}

	private func updateTableView() {
		tableView.reloadData()
	}

	/// This methods configures the update button to either allow the direct update of the current risk score
	/// or to display a countdown and deactivate the button until it is possible to update again.
	/// - Parameters:
	///   - time: formatted time string <hh:mm:ss>  that is displayed as remaining time.
	private func updateCheckButton(_ time: String? = nil) {
		if !state.isTracingEnabled || state.riskDetectionFailed {
			footerView.isHidden = false
			checkButton.isEnabled = true

			if !state.isTracingEnabled {
				checkButton.setTitle(AppStrings.ExposureDetection.buttonEnable, for: .normal)
			} else if state.riskDetectionFailed {
				checkButton.setTitle(AppStrings.ExposureDetection.buttonTitleRestart, for: .normal)
			}

			return
		}

		switch state.detectionMode {
		// Automatic mode does not require additional logic, this is often the default configuration.
		case .automatic:
			footerView.isHidden = true
			checkButton.isEnabled = true

		// In manual mode we show a countdown when the button cannot be clicked.
		case .manual:
			footerView.isHidden = false

			let nextRefresh = riskProvider.nextExposureDetectionDate
			let now = Date()

			// If there is not countdown and the next possible refresh date is in the future,
			// we schedule a new timer.
			if nextRefresh > now, countdown == nil {
				scheduleCountdownTimer(to: nextRefresh)

			// Make sure to schedule new countdown if the next refresh time has changed.
			} else if let countdown = countdown, countdown.end != nextRefresh {
				scheduleCountdownTimer(to: nextRefresh)

			// Update time label as long as the next possible refresh date is in the future.
			} else if nextRefresh - 1 > now {
				showCountdownButton(with: time)

			// By default, we show the active refresh button. This should always be the
			// case when the countdown reaches zero and .done() is called or when we were
			// allowed to update the risk from the very beginning.
			} else {
				showActiveRefreshButton()
			}
		}
	}

	private func scheduleCountdownTimer(to end: Date) {
		countdown?.invalidate()
		countdown = CountdownTimer(countdownTo: end)
		countdown?.delegate = self
		countdown?.start()
	}

	private func showActiveRefreshButton() {
		self.checkButton.setTitle(AppStrings.ExposureDetection.buttonRefresh, for: .normal)
		// Double check that the risk provider allows updating to not expose an enable checkButton by accident.
		self.checkButton.isEnabled = riskProvider.manualExposureDetectionState == .possible
	}

	private func showCountdownButton(with time: String? = nil) {
		guard let time = time else { return }
		UIView.performWithoutAnimation {
			self.checkButton.setTitle(String(format: AppStrings.ExposureDetection.refreshIn, time), for: .normal)
			self.checkButton.isEnabled = false
		}
	}
	
}

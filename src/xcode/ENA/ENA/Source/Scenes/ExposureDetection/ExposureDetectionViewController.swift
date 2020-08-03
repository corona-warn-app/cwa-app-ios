// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ExposureNotification
import Foundation
import UIKit

final class ExposureDetectionViewController: DynamicTableViewController, RequiresAppDependencies {
	// MARK: - Properties.

	private var countdown: CountdownTimer?

	// MARK: - IB Outlets.

	@IBOutlet var closeButton: UIButton!
	@IBOutlet var headerView: UIView!
	@IBOutlet var titleViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var footerView: UIView!
	@IBOutlet var checkButton: ENAButton!

	var state: State {
		didSet {
			updateUI()
		}
	}
	private weak var delegate: ExposureDetectionViewControllerDelegate?

	private let consumer = RiskConsumer()

	// MARK: - Creating an Exposure Detection View Controller.

	init?(
		coder: NSCoder,
		state: State,
		delegate: ExposureDetectionViewControllerDelegate
	) {
		self.delegate = delegate
		self.state = state
		super.init(coder: coder)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}

	deinit {
		riskProvider.removeRisk(consumer)
	}
}

extension ExposureDetectionViewController {
	override func viewDidLoad() {
		super.viewDidLoad()

		titleLabel.accessibilityTraits = .header

		closeButton.isAccessibilityElement = true
		closeButton.accessibilityTraits = .button
		closeButton.accessibilityLabel = AppStrings.AccessibilityLabel.close
		closeButton.accessibilityIdentifier = AccessibilityIdentifiers.AccessibilityLabel.close

		consumer.didCalculateRisk = { [weak self] risk in
			self?.state.risk = risk
			self?.updateUI()
		}
		consumer.didChangeLoadingStatus = { [weak self] isLoading in
			self?.state.isLoading = isLoading
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
}

extension ExposureDetectionViewController {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let offset = scrollView.contentOffset.y

		if offset > 0 {
			titleViewBottomConstraint.constant = 0
		} else {
			titleViewBottomConstraint.constant = -offset
		}
	}
}

private extension ExposureDetectionViewController {
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
}

extension ExposureDetectionViewController: ExposureStateUpdating {
	func updateExposureState(_ exposureManagerState: ExposureManagerState) {
		state.exposureManagerState = exposureManagerState
		updateUI()
	}
}

extension ExposureDetectionViewController {
	func updateUI() {
		dynamicTableViewModel = dynamicTableViewModel(for: state.riskLevel, isTracingEnabled: state.isTracingEnabled)

		updateCloseButton()
		updateHeader()
		updateTableView()
		updateCheckButton()

		view.setNeedsLayout()
	}

	private func updateCloseButton() {
		if state.isTracingEnabled && state.riskLevel != .inactive {
			closeButton.setImage(UIImage(named: "Icons - Close - Contrast"), for: .normal)
			closeButton.setImage(UIImage(named: "Icons - Close - Tap - Contrast"), for: .highlighted)
		} else {
			closeButton.setImage(UIImage(named: "Icons - Close"), for: .normal)
			closeButton.setImage(UIImage(named: "Icons - Close - Tap"), for: .highlighted)
		}
	}

	private func updateHeader() {
		headerView.backgroundColor = state.riskBackgroundColor
		titleLabel.text = state.riskText
		titleLabel.textColor = state.riskContrastTextColor
	}

	private func updateTableView() {
		tableView.reloadData()
	}

	/// This methods configures the update button to either allow the direct update of the current risk score
	/// or to display a countdown and deactivate the button until it is possible to update again.
	/// - Parameters:
	///   - time: formatted time string <hh:mm:ss>  that is displayed as remaining time.
	private func updateCheckButton(_ time: String? = nil) {
		if !state.isTracingEnabled {
			footerView.isHidden = false
			checkButton.isEnabled = true
			checkButton.setTitle(AppStrings.ExposureDetection.buttonEnable, for: .normal)
			return
		}

		var mode = state.detectionMode
		if .unknownOutdated == state.risk?.level { mode = .manual }

		switch mode {

		// Automatic mode does not requred additional logic, this is often the default configuration.
		case .automatic:
			footerView.isHidden = true
			checkButton.isEnabled = true

		// In manual mode we show a countdown when the button cannot be clicked.
		case .manual:
			footerView.isHidden = false

			let nextRefresh = riskProvider.nextExposureDetectionDate()
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

// MARK: - CountdownTimerDelegate methods.

extension ExposureDetectionViewController: CountdownTimerDelegate {

	func countdownTimer(_ timer: CountdownTimer, didUpdate time: String) {
		self.updateCheckButton(time)
	}

	func countdownTimer(_ timer: CountdownTimer, didEnd done: Bool) {
		self.updateCheckButton()
	}
}

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

final class ExposureDetectionViewController: DynamicTableViewController {
	// MARK: Properties

	@IBOutlet var closeImage: UIImageView!
	@IBOutlet var headerView: UIView!
	@IBOutlet var titleViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var footerView: UIView!
	@IBOutlet var checkButton: UIButton!

	var state: State
	private weak var delegate: ExposureDetectionViewControllerDelegate?
	private weak var refreshTimer: Timer?

	// MARK: Creating an Exposure Detection View Controller

	init?(
		coder: NSCoder,
		state: State,
		delegate: ExposureDetectionViewControllerDelegate
	) {
		self.delegate = delegate
		self.state = state
		super.init(coder: coder)
	}

	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}
}

extension ExposureDetectionViewController {
	override func viewDidLoad() {
		super.viewDidLoad()

		updateUI()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		updateUI()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		refreshTimer?.invalidate()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		switch state.mode {
		case .automatic:
			tableView.contentInset.bottom = 0
		case .manual:
			tableView.contentInset.bottom = footerView.frame.height
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)

		(cell as? DynamicTypeTableViewCell)?.backgroundColor = .clear

		if cell.backgroundView == nil {
			cell.backgroundView = UIView()
		}

		if cell.backgroundColor == nil || cell.backgroundColor == .clear {
			cell.backgroundView?.backgroundColor = .preferredColor(for: .backgroundPrimary)
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
		log(message: "Starting exposure detection ...")

		if state.isTracingEnabled {
			delegate?.exposureDetectionViewControllerStartTransaction(self)
		} else {
			delegate?.exposureDetectionViewController(self, setExposureManagerEnabled: true) { error in
				self.alertError(message: error?.localizedDescription, title: AppStrings.Common.alertTitleGeneral)
				// TODO: handle error
			}
		}
	}
}

extension ExposureDetectionViewController: ExposureStateUpdating {
	func updateExposureState(_ emState: ExposureManagerState) {
		state.exposureManagerState = emState
		updateUI()
	}
}

extension ExposureDetectionViewController {
	func updateUI() {
		let areAnimationEnabled = UIView.areAnimationsEnabled
		UIView.setAnimationsEnabled(false)

		dynamicTableViewModel = dynamicTableViewModel(for: state.riskLevel, isTracingEnabled: state.isTracingEnabled)

		updateCloseButton()
		updateHeader()
		updateTableView()
		updateCheckButton()

		updateTimer()

		view.setNeedsLayout()

		UIView.setAnimationsEnabled(areAnimationEnabled)
	}

	private func updateCloseButton() {
		if state.isTracingEnabled {
			closeImage.image = UIImage(named: "exposure-detection-close-contrast")
		} else {
			closeImage.image = UIImage(named: "exposure-detection-close")
		}
	}

	private func updateHeader() {
		headerView.backgroundColor = state.riskTintColor
		titleLabel.text = state.riskText
		titleLabel.textColor = state.riskContrastColor
	}

	private func updateTableView() {
		tableView.backgroundColor = state.riskTintColor
		tableView.reloadData()
	}

	private func updateRefreshCell() {
		let indexPath = IndexPath(row: 0, section: 1)
		if let cell = tableView.cellForRow(at: indexPath) {
			dynamicTableViewModel.cell(at: indexPath).configure(cell: cell, at: indexPath, for: self)
			cell.setNeedsLayout()
		}
	}

	private func updateCheckButton() {
		if !state.isTracingEnabled {
			footerView.isHidden = false
			checkButton.isEnabled = true
			checkButton.setTitle(AppStrings.ExposureDetection.buttonRefresh, for: .normal)
			checkButton.setTitleColor(.white, for: .normal)
			checkButton.backgroundColor = .preferredColor(for: .tint)
		}

		switch state.mode {
		case .automatic:
			footerView.isHidden = true
			checkButton.isEnabled = true

		case .manual:
			footerView.isHidden = false

			if let nextRefresh = state.nextRefresh {
				UIView.performWithoutAnimation {
					let components = Calendar.current.dateComponents([.minute, .second], from: Date(), to: nextRefresh)
					checkButton.setTitle(String(format: AppStrings.ExposureDetection.buttonRefreshingIn, components.minute ?? 0, components.second ?? 0), for: .disabled)
					checkButton.isEnabled = false
					checkButton.layoutIfNeeded()
				}
			} else {
				checkButton.setTitle(AppStrings.ExposureDetection.buttonRefresh, for: .normal)
				checkButton.isEnabled = !state.isLoading
			}
		}
	}

	private func updateTimer() {
		refreshTimer?.invalidate()

		guard state.nextRefresh != nil else { return }

		refreshTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
			guard let self = self else { timer.invalidate(); return }
			self.timerUpdateUI()
		}

		if tableView.window != nil {
			refreshTimer?.fire()
		}
	}

	private func timerUpdateUI() {
		switch state.mode {
		case .automatic:
			updateRefreshCell()

		case .manual:
			updateCheckButton()
		}
	}
}

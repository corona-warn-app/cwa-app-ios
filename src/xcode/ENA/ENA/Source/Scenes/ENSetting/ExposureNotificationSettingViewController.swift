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
import Reachability
import UIKit

protocol ExposureNotificationSettingViewControllerDelegate: AnyObject {
	typealias Completion = (ExposureNotificationError?) -> Void

	func exposureNotificationSettingViewController(
		_ controller: ExposureNotificationSettingViewController,
		setExposureManagerEnabled enabled: Bool,
		then completion: @escaping Completion
	)
}

final class ExposureNotificationSettingViewController: UITableViewController {
	private weak var delegate: ExposureNotificationSettingViewControllerDelegate?

	var currentState: RiskDetectionState {
		stateHandler.getState()
	}

	var stateHandler: ENStateHandler {
		didSet {
			tableView.reloadData()
		}
	}

	let model = ENSettingModel(content: [.banner, .actionCell, .actionDetailCell, .descriptionCell])
	let numberRiskContacts = 10

	init?(
		coder: NSCoder,
		stateHandler: ENStateHandler,
		delegate: ExposureNotificationSettingViewControllerDelegate
	) {
		self.stateHandler = stateHandler
		self.delegate = delegate
		super.init(coder: coder)
	}

	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.largeTitleDisplayMode = .always
		setUIText()
		tableView.sectionFooterHeight = 0.0
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}

	private func setExposureManagerEnabled(
		_ enabled: Bool,
		then _: ExposureNotificationSettingViewControllerDelegate.Completion
	) {
		delegate?.exposureNotificationSettingViewController(
			self,
			setExposureManagerEnabled: enabled,
			then: handleErrorIfNeed
		)
	}
}

extension ExposureNotificationSettingViewController {
	private func setUIText() {
		title = AppStrings.ExposureNotificationSetting.title
	}

	private func handleEnableError(_ error: ExposureNotificationError) {
		switch error {
		case .exposureNotificationAuthorization:
			logError(message: "Failed to enable exposureNotificationAuthorization")
			alertError(message: "Failed to enable: exposureNotificationAuthorization", title: "Error")
		case .exposureNotificationRequired:
			logError(message: "Failed to enable")
			alertError(message: "exposureNotificationAuthorization", title: "Error")
		case .exposureNotificationUnavailable:
			logError(message: "Failed to enable")
			alertError(message: "ExposureNotification is not availabe due to the sytem policy", title: "Error")
		case .apiMisuse:
			// This error should not happen as we toggle the enabled status on off - we can not enable without disabling first
			alertError(message: "ExposureNotification is already enabled", title: "Note")
		}
		tableView.reloadData()
	}

	private func handleErrorIfNeed(_ error: ExposureNotificationError?) {
		if let error = error {
			handleEnableError(error)
		} else {
			tableView.reloadData()
		}
	}
}

extension ExposureNotificationSettingViewController: ExposureStateUpdating {
	func updateExposureState(_: ExposureManagerState) {
		tableView.reloadData()
	}
}

extension ExposureNotificationSettingViewController {
	override func numberOfSections(in _: UITableView) -> Int {
		model.content.count
	}

	override func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
		0
	}

	override func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		switch model.content[section] {
		case .actionCell:
			return 40
		default:
			return 0
		}
	}

	override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch model.content[section] {
		case .actionCell:
			return AppStrings.ExposureNotificationSetting.actionCellHeader
		default:
			return nil
		}
	}

	override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = indexPath.section

		let content = model.content[section]

		if let cell = tableView.dequeueReusableCell(withIdentifier: content.cellType.rawValue, for: indexPath) as? ConfigurableENSettingCell {
			switch content {
			case .banner:
				cell.configure(for: currentState)
			case .actionCell:
				if let cell = cell as? ActionCell {
					cell.configure(for: currentState, delegate: self)
				}
			case .tracingCell, .actionDetailCell:
				switch currentState {
				case .enabled, .disabled:
					let tracingCell = tableView.dequeueReusableCell(withIdentifier: ENSettingModel.Content.tracingCell.cellType.rawValue, for: indexPath)
					if let tracingCell = tracingCell as? TracingHistoryTableViewCell {
						let colorConfig: (UIColor, UIColor) = (currentState == .enabled) ?
							(UIColor.preferredColor(for: .tint), UIColor.preferredColor(for: .textPrimary3)) :
							(UIColor.preferredColor(for: .textPrimary2), UIColor.preferredColor(for: .textPrimary3))
						tracingCell.configure(
							progress: CGFloat(numberRiskContacts),
							text: String(format: AppStrings.ExposureNotificationSetting.tracingHistoryDescription, numberRiskContacts),
							colorConfigurationTuple: colorConfig
						)
						return tracingCell
					}
				case .bluetoothOff, .internetOff, .restricted:
					cell.configure(for: currentState)
				}
			case .descriptionCell:
				cell.configure(for: currentState)
			}
			return cell
		} else {
			return UITableViewCell()
		}
	}
}

extension ExposureNotificationSettingViewController: ActionTableViewCellDelegate {
	func performAction(enable: Bool) {
		setExposureManagerEnabled(enable, then: handleErrorIfNeed)
	}
}

extension ExposureNotificationSettingViewController {
	func stateDidChange(to _: RiskDetectionState) {
		tableView.reloadData()
	}
}

extension ExposureNotificationSettingViewController {
	fileprivate enum ReusableCellIdentifier: String {
		case banner
		case actionCell
		case tracingCell
		case actionDetailCell
		case descriptionCell
	}
}

private extension ENSettingModel.Content {
	var cellType: ExposureNotificationSettingViewController.ReusableCellIdentifier {
		switch self {
		case .banner:
			return .banner
		case .actionCell:
			return .actionCell
		case .tracingCell:
			return .tracingCell
		case .actionDetailCell:
			return .actionDetailCell
		case .descriptionCell:
			return .descriptionCell
		}
	}
}

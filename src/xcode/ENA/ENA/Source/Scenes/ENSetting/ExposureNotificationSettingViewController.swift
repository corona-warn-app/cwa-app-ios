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

	private var lastActionCell: ActionCell?

	let model = ENSettingModel(content: [.banner, .actionCell, .actionDetailCell, .descriptionCell])
	let store: Store
	var enState: ENStateHandler.State

	init?(
		coder: NSCoder,
		initialEnState: ENStateHandler.State,
		store: Store,
		delegate: ExposureNotificationSettingViewControllerDelegate
	) {
		self.delegate = delegate
		self.store = store
		enState = initialEnState
		super.init(coder: coder)
	}

	@available(*, unavailable)
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
		then completion: @escaping ExposureNotificationSettingViewControllerDelegate.Completion
	) {
		delegate?.exposureNotificationSettingViewController(
			self,
			setExposureManagerEnabled: enabled,
			then: completion
		)
	}
}

extension ExposureNotificationSettingViewController {
	private func setUIText() {
		title = AppStrings.ExposureNotificationSetting.title
	}

	private func handleEnableError(_ error: ExposureNotificationError, alert: Bool) {
		switch error {
		case .exposureNotificationAuthorization:
			logError(message: "Failed to enable exposureNotificationAuthorization")
			if alert {
				alertError(message: "Failed to enable: exposureNotificationAuthorization", title: AppStrings.ExposureSubmission.generalErrorTitle)
			}
		case .exposureNotificationRequired:
			logError(message: "Failed to enable")
			if alert {
				alertError(message: "exposureNotificationAuthorization", title: AppStrings.ExposureSubmission.generalErrorTitle)
			}
		case .exposureNotificationUnavailable:
			logError(message: "Failed to enable")
			if alert {
				alertError(message: "ExposureNotification is not available due to the system policy", title: AppStrings.ExposureSubmission.generalErrorTitle)
			}
		case .apiMisuse:
			logError(message: "APIMisuse")
			// This error should not happen as we toggle the enabled status on off - we can not enable without disabling first
			if alert {
				alertError(message: "ExposureNotification is already enabled", title: "Note")
			}
		case .unknown(let message):
			logError(message: "unknown")
			if alert {
				alertError(message: "Cannot enable the notification. The reason is \(message)", title: AppStrings.ExposureSubmission.generalErrorTitle)
			}

		}
		if let mySceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
			mySceneDelegate.requestUpdatedExposureState()
		}
		tableView.reloadData()
	}

	private func handleErrorIfNeed(_ error: ExposureNotificationError?) {
		if let error = error {
			handleEnableError(error, alert: true)
		} else {
			tableView.reloadData()
		}
	}

	private func silentErrorIfNeed(_ error: ExposureNotificationError?) {
		if let error = error {
			handleEnableError(error, alert: false)
		} else {
			tableView.reloadData()
		}
	}

	private func askConsentToUser() {
		let alert = UIAlertController(
			title: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_panelTitle,
			message: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_panelBody,
			preferredStyle: .alert
		)
		let completionHandler: (UIAlertAction) -> Void = { action in
			switch action.style {
			case .default:
				self.persistForDPP(accepted: true)
				self.setExposureManagerEnabled(true, then: self.silentErrorIfNeed)
			case .cancel, .destructive:
				self.lastActionCell?.configure(for: self.enState, delegate: self)
				self.tableView.reloadData()
			@unknown default:
				fatalError("Not all cases of actions covered when handling the bluetooth")
			}
		}
		alert.addAction(UIAlertAction(title: AppStrings.ExposureNotificationSetting.privacyConsentActivateAction, style: .default, handler: { action in completionHandler(action) }))
		alert.addAction(UIAlertAction(title: AppStrings.ExposureNotificationSetting.privacyConsentDismissAction, style: .cancel, handler: { action in completionHandler(action) }))
		self.present(alert, animated: true, completion: nil)
	}

	func persistForDPP(accepted: Bool) {
		self.store.exposureActivationConsentAccept = accepted
		self.store.exposureActivationConsentAcceptTimestamp = Int64(Date().timeIntervalSince1970)
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
			if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
				return UITableView.automaticDimension
			}
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

	override func tableView(
		_ tableView: UITableView,
		cellForRowAt indexPath: IndexPath
	) -> UITableViewCell {
		let section = indexPath.section
		let content = model.content[section]
		if let cell = tableView.dequeueReusableCell(withIdentifier: content.cellType.rawValue, for: indexPath) as? ConfigurableENSettingCell {
			switch content {
			case .banner:
				cell.configure(for: enState)
			case .actionCell:
				if let lastActionCell = lastActionCell {
					return lastActionCell
				}
				if let cell = cell as? ActionCell {
					cell.configure(for: enState, delegate: self)
					lastActionCell = cell
				}
			case .tracingCell, .actionDetailCell:
				switch enState {
				case .enabled, .disabled:
					let tracingCell = tableView.dequeueReusableCell(withIdentifier: ENSettingModel.Content.tracingCell.cellType.rawValue, for: indexPath)
					if let tracingCell = tracingCell as? TracingHistoryTableViewCell {
						let colorConfig: (UIColor, UIColor) = (self.enState == .enabled) ?
							(UIColor.enaColor(for: .tint), UIColor.enaColor(for: .hairline)) :
							(UIColor.enaColor(for: .textPrimary2), UIColor.enaColor(for: .hairline))

						let numberOfDaysWithActiveTracing = store.tracingStatusHistory.activeTracing().inDays
						tracingCell.configure(
							progress: CGFloat(numberOfDaysWithActiveTracing),
							text: String(format: AppStrings.ExposureNotificationSetting.tracingHistoryDescription, numberOfDaysWithActiveTracing),
							colorConfigurationTuple: colorConfig
						)
						return tracingCell
					}
				case .bluetoothOff, .internetOff, .restricted, .notAuthorized, .unknown:
					if let cell = cell as? ActionCell {
						cell.configure(for: enState, delegate: self)
					}
				}
			case .descriptionCell:
				cell.configure(for: enState)
			}
			return cell
		} else {
			return UITableViewCell()
		}
	}
}

extension ExposureNotificationSettingViewController: ActionTableViewCellDelegate {
	func performAction(action: SettingAction) {
		switch action {
		case .enable(true):
			setExposureManagerEnabled(true, then: handleErrorIfNeed)
		case .enable(false):
			setExposureManagerEnabled(false, then: handleErrorIfNeed)
		case .askConsent:
			askConsentToUser()
		}
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

// MARK: ENStateHandler Updating
extension ExposureNotificationSettingViewController: ENStateHandlerUpdating {
	func updateEnState(_ enState: ENStateHandler.State) {
		log(message: "Get the new state: \(enState)")
		self.enState = enState
		lastActionCell?.configure(for: enState, delegate: self)
		self.tableView.reloadData()
	}
}

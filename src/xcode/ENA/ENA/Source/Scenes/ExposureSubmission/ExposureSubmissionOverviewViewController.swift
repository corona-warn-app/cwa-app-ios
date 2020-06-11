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

import AVFoundation
import Foundation
import UIKit


class ExposureSubmissionOverviewViewController: DynamicTableViewController, SpinnerInjectable {

	// MARK: - Attributes.

	@IBAction func unwindToExposureSubmissionIntro(_: UIStoryboardSegue) {}
	var service: ExposureSubmissionService?
	var spinner: UIActivityIndicatorView?

	// MARK: - Initializers.

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	// MARK: - View lifecycle methods.

	override func viewDidLoad() {
		super.viewDidLoad()
		dynamicTableViewModel = dynamicTableData()
		setupView()

		// Grab ExposureSubmissionService from the navigation controller
		// (which is the entry point for the storyboard, and in which
		// this controller is embedded.)
		if let navC = navigationController as? ExposureSubmissionNavigationController {
			service = navC.getExposureSubmissionService()
		}
	}

	private func setupView() {
		tableView.register(
			UINib(
				nibName: String(describing: ExposureSubmissionTestResultHeaderView.self),
				bundle: nil
			),
			forHeaderFooterViewReuseIdentifier: "test"
		)
		tableView.register(UINib(nibName: String(describing: ExposureSubmissionImageCardCell.self), bundle: nil), forCellReuseIdentifier: CustomCellReuseIdentifiers.imageCard.rawValue)
		title = AppStrings.ExposureSubmissionDispatch.title
	}

	// MARK: - Segue handling.

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destination = segue.destination
		switch Segue(segue) {
		case .tanInput:
			let viewCtrl = destination as? ExposureSubmissionTanInputViewController
			viewCtrl?.initialTan = sender as? String
			viewCtrl?.exposureSubmissionService = service
		case .qrScanner:
			let viewCtrl = destination as? ExposureSubmissionQRScannerNavigationController
			viewCtrl?.scannerViewController?.delegate = self
			viewCtrl?.exposureSubmissionService = service
		case .labResult:
			let viewCtrl = destination as? ExposureSubmissionTestResultViewController
			viewCtrl?.exposureSubmissionService = service
			viewCtrl?.testResult = sender as? TestResult
		default:
			break
		}
	}

	// MARK: - Helpers.

	private func fetchResult() {
		startSpinner()
		service?.getTestResult { result in
			self.stopSpinner()
			switch result {
			case let .failure(error):
				logError(message: "An error occurred during result fetching: \(error)", level: .error)
				let alert = ExposureSubmissionViewUtils.setupErrorAlert(error)
				self.present(alert, animated: true, completion: nil)
			case let .success(testResult):
				self.performSegue(withIdentifier: Segue.labResult, sender: testResult)
			}
		}
	}

	/// Shows the data privacy disclaimer and only lets the
	/// user scan a QR code after accepting.
	func showDisclaimer() {
		let alert = UIAlertController(
			title: AppStrings.ExposureSubmission.dataPrivacyTitle,
			message: AppStrings.ExposureSubmission.dataPrivacyDisclaimer,
			preferredStyle: .alert
		)
		let acceptAction = UIAlertAction(title: AppStrings.ExposureSubmission.dataPrivacyAcceptTitle, style: .default, handler: { _ in
											self.service?.acceptPairing()
											self.performSegue(
												withIdentifier: Segue.qrScanner,
												sender: self
											)
		})
		alert.addAction(acceptAction)

		alert.addAction(.init(title: AppStrings.ExposureSubmission.dataPrivacyDontAcceptTitle,
							  style: .cancel,
							  handler: { _ in
								alert.dismiss(animated: true, completion: nil) }
			))
		alert.preferredAction = acceptAction
		present(alert, animated: true, completion: nil)
	}
}

// MARK: - Segue extension.

extension ExposureSubmissionOverviewViewController {
	enum Segue: String, SegueIdentifiers {
		case tanInput = "tanInputSegue"
		case qrScanner = "qrScannerSegue"
		case testDetails = "testDetailsSegue"
		case hotline = "hotlineSegue"
		case labResult = "labResultSegue"
	}
}

// MARK: - ExposureSubmissionQRScannerDelegate methods.

extension ExposureSubmissionOverviewViewController: ExposureSubmissionQRScannerDelegate {
	func qrScanner(_ viewController: QRScannerViewController, error: QRScannerError) {
		switch error {
		case .cameraPermissionDenied:

			// The error handler could have been invoked on a non-main thread which causes
			// issues (crash) when updating the UI.
			DispatchQueue.main.async {
				let alert = ExposureSubmissionViewUtils.setupErrorAlert(error) {
					self.dismissQRCodeScannerView(viewController, completion: nil)
				}
				viewController.present(alert, animated: true, completion: nil)
			}
		default:
			logError(message: "QRScannerError.other occurred.", level: .error)
		}
	}

	func qrScanner(_ viewCtrl: QRScannerViewController, didScan code: String) {
		guard let guid = sanitizeAndExtractGuid(code) else {
			viewCtrl.delegate = nil
			let alert = ExposureSubmissionViewUtils.setupAlert(
				title: AppStrings.ExposureSubmissionQRScanner.alertCodeNotFoundTitle,
				message: AppStrings.ExposureSubmissionQRScanner.alertCodeNotFoundText,
				okTitle: AppStrings.Common.alertActionCancel,
				retry: true,
				action: {
					self.dismissQRCodeScannerView(viewCtrl, completion: nil)
				},
				retryActionHandler: { viewCtrl.delegate = self }
			)
			viewCtrl.present(alert, animated: true, completion: nil)
			return
		}

		// Found QR Code, deactivate scanning.
		dismissQRCodeScannerView(viewCtrl, completion: {
			self.startSpinner()
			self.getRegistrationToken(forKey: .guid(guid))
		})
	}

	private func getRegistrationToken(forKey: DeviceRegistrationKey) {
		service?.getRegistrationToken(forKey: forKey, completion: { result in
			self.stopSpinner()
			switch result {
			case let .failure(error):

				// Note: In the case the QR Code was already used, retrying will result
				// in an endless loop.
				if case .qRAlreadyUsed = error {
					let alert = ExposureSubmissionViewUtils.setupErrorAlert(error, completion: nil)
					self.present(alert, animated: true, completion: nil)
					return
				}

				logError(message: "Error while getting registration token: \(error)", level: .error)
				let alert = ExposureSubmissionViewUtils.setupErrorAlert(error, retry: true, retryActionHandler: {
					self.startSpinner()
					self.getRegistrationToken(forKey: forKey)
				})
				self.present(alert, animated: true, completion: nil)

			case let .success(token):
				log(
					message: "Received registration token: \(token)",
					file: #file,
					line: #line,
					function: #function
				)
				self.fetchResult()
			}
        })
	}

	/// Sanitize the input string and assert that:
	/// - length is smaller than 128 characters
	/// - starts with https://
	/// - contains only alphanumeric characters
	/// - is not empty
	func sanitizeAndExtractGuid(_ input: String) -> String? {
		guard input.count <= 150 else { return nil }
		guard let regex = try? NSRegularExpression(pattern: "^.*\\?(?<GUID>[A-Z,a-z,0-9,-]*)") else { return nil }
		guard let match = regex.firstMatch(in: input, options: [], range: NSRange(location: 0, length: input.utf8.count)) else { return nil }
		let nsRange = match.range(withName: "GUID")
		guard let range = Range(nsRange, in: input) else { return nil }
		let candidate = String(input[range])
		guard !candidate.isEmpty, candidate.count <= 80 else { return nil }
		return candidate
	}

	private func dismissQRCodeScannerView(_ viewCtrl: QRScannerViewController, completion: (() -> Void)?) {
		viewCtrl.delegate = nil
		viewCtrl.dismiss(animated: true, completion: completion)
	}
}

// MARK: Data extension for DynamicTableView.

private extension DynamicCell {
	static func imageCard(
		title: String,
		description: String? = nil,
		attributedDescription: NSAttributedString? = nil,
		image: UIImage?,
		action: DynamicAction,
		accessibilityIdentifier: String? = nil) -> Self {
		.identifier(ExposureSubmissionOverviewViewController.CustomCellReuseIdentifiers.imageCard, action: action) { _, cell, _ in
			guard let cell = cell as? ExposureSubmissionImageCardCell else { return }
			cell.configure(
				title: title,
				description: description ?? "",
				attributedDescription: attributedDescription,
				image: image,
				accessibilityIdentifier: accessibilityIdentifier)
		}
	}
}

private extension ExposureSubmissionOverviewViewController {
	func dynamicTableData() -> DynamicTableViewModel {
		var data = DynamicTableViewModel([])

		let header = DynamicHeader.blank

		data.add(
			.section(
				header: header,
				separators: false,
				cells: [
					.body(
						text: AppStrings.ExposureSubmissionDispatch.description,
						accessibilityIdentifier: "AppStrings.ExposureSubmissionDispatch.description")
				]
			)
		)

		data.add(DynamicSection.section(cells: [
			.imageCard(
				title: AppStrings.ExposureSubmissionDispatch.qrCodeButtonTitle,
				description: AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription,
				image: UIImage(named: "Illu_Submission_QRCode"),
				action: .execute(block: { _ in self.showDisclaimer() }),
				accessibilityIdentifier: "AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription"
			),
			.imageCard(
				title: AppStrings.ExposureSubmissionDispatch.tanButtonTitle,
				description: AppStrings.ExposureSubmissionDispatch.tanButtonDescription,
				image: UIImage(named: "Illu_Submission_TAN"),
				action: .perform(segue: Segue.tanInput),
				accessibilityIdentifier: "AppStrings.ExposureSubmissionDispatch.tanButtonDescription"
			),
			.imageCard(
				title: AppStrings.ExposureSubmissionDispatch.hotlineButtonTitle,
				attributedDescription: applyFont(style: .headline, to: AppStrings.ExposureSubmissionDispatch.hotlineButtonDescription, with: AppStrings.ExposureSubmissionDispatch.positiveWord),
				image: UIImage(named: "Illu_Submission_Anruf"),
				action: .perform(segue: Segue.hotline),
				accessibilityIdentifier: "AppStrings.ExposureSubmissionDispatch.hotlineButtonDescription"
			)
		]))

		return data
	}

	private func applyFont(style: ENAFont, to text: String, with content: String) -> NSAttributedString {
		return NSMutableAttributedString.generateAttributedString(normalText: text, attributedText: [
			NSAttributedString(string: content, attributes: [
				NSAttributedString.Key.font: UIFont.enaFont(for: style)
			])
		])
	}
}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionOverviewViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case imageCard = "imageCardCell"
	}
}

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

struct ExposureSubmissionTestResult {
	let isPositive: Bool
	let receivedDate: Date
	let transmittedDate: Date?
}

class ExposureSubmissionOverviewViewController: DynamicTableViewController, SpinnerInjectable {
	// MARK: - Attributes.

	@IBAction func unwindToExposureSubmissionIntro(_: UIStoryboardSegue) {}
	private var exposureSubmissionService: ExposureSubmissionService?
	var spinner: UIActivityIndicatorView?

	private var testResults: [ExposureSubmissionTestResult] = [ExposureSubmissionTestResult(isPositive: true, receivedDate: Date(), transmittedDate: Date())]
	private var mostRecentTestResult: ExposureSubmissionTestResult? { testResults.last }

	// MARK: - Initializers.

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	// MARK: - View lifecycle methods.

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if exposureSubmissionService?.hasRegistrationToken() ?? false {
			fetchResult()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		dynamicTableViewModel = dynamicTableData()
		setupView()

		// Grab ExposureSubmissionService from the navigation controller
		// (which is the entry point for the storyboard, and in which
		// this controller is embedded.)
		if let navC = navigationController as? ExposureSubmissionNavigationController {
			exposureSubmissionService = navC.getExposureSubmissionService()
		}
	}

	private func setupView() {
		tableView.register(UINib(nibName: String(describing: ExposureSubmissionTestResultHeaderView.self),
								 bundle: nil),
						   forHeaderFooterViewReuseIdentifier: "test")
		tableView.register(DynamicTableViewImageCardCell.self, forCellReuseIdentifier: CustomCellReuseIdentifiers.imageCard.rawValue)
		title = AppStrings.ExposureSubmissionDispatch.title
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch Segue(segue) {
		case .tanInput:
			let destination = segue.destination as? ExposureSubmissionTanInputViewController
			destination?.initialTan = sender as? String
			destination?.exposureSubmissionService = exposureSubmissionService
		case .qrScanner:
			let destination = segue.destination as? ExposureSubmissionQRScannerNavigationController
			destination?.scannerViewController?.delegate = self
			destination?.exposureSubmissionService = exposureSubmissionService
		case .labResult:
			let destination = segue.destination as? ExposureSubmissionTestResultViewController
			destination?.exposureSubmissionService = exposureSubmissionService
			destination?.testResult = sender as? TestResult
		default:
			break
		}
	}

	// MARK: - Helpers.

	private func fetchResult() {
		startSpinner()
		exposureSubmissionService?.getTestResult { result in
			self.stopSpinner()
			switch result {
			case let .failure(error):
				logError(message: "An error occured during result fetching: \(error)", level: .error)
				let alert = ExposureSubmissionViewUtils.setupErrorAlert(error)
				self.present(alert, animated: true, completion: nil)
			case let .success(testResult):
				switch testResult {
				case .pending:
					let alert = ExposureSubmissionViewUtils.setupAlert(message: "Test Result is pending.")
					self.present(alert, animated: true, completion: nil)
				default:
					self.performSegue(withIdentifier: Segue.labResult, sender: testResult)
				}
			}
		}
	}
}

extension ExposureSubmissionOverviewViewController {
	enum Segue: String, SegueIdentifiers {
		case tanInput = "tanInputSegue"
		case qrScanner = "qrScannerSegue"
		case testDetails = "testDetailsSegue"
		case hotline = "hotlineSegue"
		case labResult = "labResultSegue"
	}
}

extension ExposureSubmissionOverviewViewController {
	enum HeaderReuseIdentifier: String, TableViewHeaderFooterReuseIdentifiers {
		case test
	}
}

// MARK: - ExposureSubmissionQRScannerDelegate methods.

extension ExposureSubmissionOverviewViewController: ExposureSubmissionQRScannerDelegate {
	func qrScanner(_ viewController: ExposureSubmissionQRScannerViewController, error: QRScannerError) {
		dismissQRCodeScannerView(viewController)
		switch error {
		case .cameraPermissionDenied:
			let alert = ExposureSubmissionViewUtils.setupAlert(message: "You need to allow camera access.")
			present(alert, animated: true, completion: nil)
		default:
			logError(message: "QRScannerError.other occured.", level: .error)
		}
	}

	func qrScanner(_ vc: ExposureSubmissionQRScannerViewController, didScan code: String) {
		guard let guid = sanitizeAndExtractGuid(code) else {
			dismissQRCodeScannerView(vc)
			let alert = ExposureSubmissionViewUtils.setupAlert(message: "The provided QR code was invalid.")
			present(alert, animated: true, completion: nil)
			return
		}

		// Found QR Code, deactivate scanning.
		dismissQRCodeScannerView(vc)
		startSpinner()

		exposureSubmissionService?.getRegistrationToken(forKey: .guid(guid), completion: { result in
			switch result {
			case let .failure(error):
				self.stopSpinner()
				logError(message: "Error while getting registration token: \(error)", level: .error)
				let alert = ExposureSubmissionViewUtils.setupConfirmationAlert {
					self.dismissQRCodeScannerView(vc)
				}

				self.present(alert, animated: true, completion: nil)
			case let .success(token):
				print("Received registration token: \(token)")
				self.fetchResult()
			}
        })
	}

	/// Sanitize the input string and assert that:
	/// - length is smaller than 128 characters
	/// - starts with https://
	/// - contains only alphanumeric characters
	/// - is not empty
	private func sanitizeAndExtractGuid(_ input: String) -> String? {
		guard input.count < 128 else { return nil }
		guard let regex = try? NSRegularExpression(pattern: "^https:\\/\\/.*\\?(?<GUID>[A-Z,a-z,0-9,-]*)") else { return nil }
		guard let match = regex.firstMatch(in: input, options: [], range: NSRange(location: 0, length: input.utf8.count)) else { return nil }
		let nsRange = match.range(withName: "GUID")
		guard let range = Range(nsRange, in: input) else { return nil }
		let candidate = String(input[range])
		guard !candidate.isEmpty else { return nil }
		return candidate
	}

	private func dismissQRCodeScannerView(_ vc: ExposureSubmissionQRScannerViewController) {
		vc.delegate = nil
		vc.dismiss(animated: true, completion: nil)
	}
}

extension DynamicTableViewModel {
	mutating func addHelpSection() {
		add(
			.section(
				header: .text("Hilfe"),
				cells: [
					.phone(text: "Hotline anrufen", number: "0123456789")
				]
			)
		)
	}

	mutating func addNextStepsSection() {
		add(
			.section(
				header: .text("Nächste Schritte"),
				cells:
				[
					.icon(
						action: .perform(segue: ExposureSubmissionOverviewViewController.Segue.tanInput),
						DynamicIcon(
							text: "TeleTan eingeben",
							image: UIImage(systemName: "doc.text"),
							backgroundColor: .preferredColor(for: .brandBlue),
							tintColor: .black
						)
					),
					.icon(
						action: .perform(segue: ExposureSubmissionOverviewViewController.Segue.qrScanner),
						DynamicIcon(
							text: "QR-Code scannen",
							image: UIImage(systemName: "doc.text"),
							backgroundColor: .preferredColor(for: .brandBlue),
							tintColor: .black
						)
					)
				]
			)
		)
	}

	mutating func addWhatIfSection() {
		let header = DynamicHeader.image(UIImage(named: "app-information-people"))

		add(
			.section(
				header: header,
				separators: false,
				cells: [
					.semibold(text: "Wenn Sie einen Covid-19 Test gemacht haben, können Sie sich hier das Testergebnis anzeigen lassen."),
					.regular(text: "Sollte das Testergebnis positiv sein, haben Sie zusätzlich die Möglichkeit Ihren Befund anonym zu melden, damit Kontaktpersonen informiert werden können.")
				]
			)
		)
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
					.semibold(text: AppStrings.ExposureSubmissionDispatch.description)
				]
			)
		)

		data.add(DynamicSection.section(cells: [
			.identifier(
				CustomCellReuseIdentifiers.imageCard,
				action: .perform(segue: Segue.qrScanner),
				configure: { _, cell, _ in
					guard let cell = cell as? DynamicTableViewImageCardCell else { return }
					cell.configure(
						title: AppStrings.ExposureSubmissionDispatch.qrCodeButtonTitle,
						image: UIImage(named: "Illu_Submission_QRCode"),
						body: AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription
					)
				}
			),
			.identifier(
				CustomCellReuseIdentifiers.imageCard,
				action: .perform(segue: Segue.tanInput),
				configure: { _, cell, _ in
					guard let cell = cell as? DynamicTableViewImageCardCell else { return }
					cell.configure(
						title: AppStrings.ExposureSubmissionDispatch.tanButtonTitle,
						image: UIImage(named: "Illu_Submission_TAN"),
						body: AppStrings.ExposureSubmissionDispatch.tanButtonDescription
					)
				}
			),
			.identifier(
				CustomCellReuseIdentifiers.imageCard,
				action: .perform(segue: Segue.hotline),
				configure: { _, cell, _ in
					guard let cell = cell as? DynamicTableViewImageCardCell else { return }
					cell.configure(
						title: AppStrings.ExposureSubmissionDispatch.hotlineButtonTitle,
						image: UIImage(named: "Illu_Submission_Anruf"),
						body: AppStrings.ExposureSubmissionDispatch.hotlineButtonDescription
					)
				}
			)
		]))

		return data
	}

	private func transitionToQRScanner(_: UIViewController) {
		// Make sure we are allowed to use the camera.
		switch AVCaptureDevice.authorizationStatus(for: .video) {
		case .authorized, .notDetermined:
			performSegue(withIdentifier: Segue.qrScanner, sender: self)
		case .denied:
			let alert = ExposureSubmissionViewUtils.setupAlert(message: "You need to allow camera usage")
			present(alert, animated: true, completion: nil)
		case .restricted:
			let alert = ExposureSubmissionViewUtils.setupAlert(message: "Your camera usage is restricted.")
			present(alert, animated: true, completion: nil)
        @unknown default:
			log(message: "Unhandled  AVCaptureDevice state.")
		}
	}
}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionOverviewViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case imageCard = "imageCardCell"
	}
}

private extension DynamicCell {
	static func phone(text: String, number: String) -> DynamicCell {
		.icon(
			action: .call(number: number),
			DynamicIcon(
				text: text,
				image: UIImage(systemName: "phone.fill"),
				backgroundColor: .preferredColor(for: .brandMagenta),
				tintColor: .white
			)
		)
	}
}

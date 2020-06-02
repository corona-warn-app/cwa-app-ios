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

/// The root view controller of the developer menu.
final class DMViewController: UITableViewController {
	// MARK: Creating a developer menu view controller

	init(
		client: Client,
		store: Store,
		exposureManager: ExposureManager
	) {
		self.client = client
		self.store = store
		self.exposureManager = exposureManager
		super.init(style: .plain)
		title = "Developer Menu"
	}

	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Properties

	private let client: Client
	private let store: Store
	private let exposureManager: ExposureManager
	private var keys = [SAP_TemporaryExposureKey]() {
		didSet {
			keys = self.keys.sorted()
		}
	}

	// MARK: UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.register(KeyCell.self, forCellReuseIdentifier: KeyCell.reuseIdentifier)

		navigationItem.leftBarButtonItems = [
			UIBarButtonItem(
				barButtonSystemItem: .refresh,
				target: self,
				action: #selector(refreshKeys)
			),
			UIBarButtonItem(
				image: UIImage(systemName: "gear"),
				style: .plain,
				target: self,
				action: #selector(showConfiguration)
			),
			UIBarButtonItem(
				image: UIImage(systemName: "trash"),
				style: .plain,
				target: self,
				action: #selector(clearRegToken)
			)
		]

		navigationItem.rightBarButtonItems = [
			UIBarButtonItem(
				barButtonSystemItem: .action,
				target: self,
				action: #selector(generateTestKeys)
			),
			UIBarButtonItem(
				title: "State Check",
				style: .plain,
				target: self,
				action: #selector(showCheckSubmissionState)
			)
		]
	}

	// MARK: Configuration

	@objc
	private func showConfiguration() {
		let viewController = DMConfigurationViewController(
			distributionURL: store.developerDistributionBaseURLOverride,
			submissionURL: store.developerSubmissionBaseURLOverride,
			verificationURL: store.developerVerificationBaseURLOverride
		)
		navigationController?.pushViewController(viewController, animated: true)
	}
	// MARK: Clear Registration Token of Submission
	@objc
	private func clearRegToken() {
		store.registrationToken = nil
		let alert = UIAlertController(title: "Reg Token", message: "Reg Token deleted", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel))
		self.present(alert, animated: true, completion: nil)
	}

	// MARK: Fetching Keys

	@objc
	private func refreshKeys() {
		resetAndFetchKeys()
	}

	private func resetAndFetchKeys() {
		keys = []
		tableView.reloadData()
		exposureManager.accessDiagnosisKeys { keys, _ in
			guard let keys = keys else {
				logError(message: "No keys retrieved in developer menu")
				return
			}
			self.keys = keys.map { $0.sapKey }
			self.tableView.reloadData()
		}
	}

	// MARK: Checking the State of my Submission

	@objc
	private func showCheckSubmissionState() {
		navigationController?.pushViewController(
			DMSubmissionStateViewController(
				client: client,
				delegate: self
			),
			animated: true
		)
	}

	// MARK: QR Code related

	@objc
	private func showScanner() {
		present(DMQRCodeScanViewController(delegate: self), animated: true)
	}

	// MARK: Test Keys

	// This method generates test keys and submits them to the backend.
	// Later we may split that up in two different actions:
	// 1. generate the keys
	// 2. let the tester manually submit those keys using the API
	// For now we simply submit automatically.
	@objc
	private func generateTestKeys() {
		exposureManager.getTestDiagnosisKeys { [weak self] keys, error in
			guard let self = self else {
				return
			}
			if let error = error {
				logError(message: "Failed to generate test keys due to: \(error)")
				return
			}
			let _keys = keys ?? []
			// The tan is hardcoded and should work on int. It you get a HTTP 403 response
			// it may be required to change the tan to something else.
			self.client.submit(
				keys: _keys,
				tan: "235b56ff-fd57-465a-8203-31456e58f06f"
			) { submitError in
				print("submitError: \(submitError?.localizedDescription ?? "")")
				return
			}
			log(message: "Got diagnosis keys: \(_keys)", level: .info)
			self.resetAndFetchKeys()
		}
	}

	// MARK: UITableView

	override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		keys.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "KeyCell", for: indexPath)
		let key = keys[indexPath.row]

		cell.textLabel?.text = key.keyData.base64EncodedString()
		cell.detailTextLabel?.text = "Rolling Start Date: \(key.formattedRollingStartNumberDate)"
		return cell
	}

	override func tableView(_: UITableView, didSelectRowAt _: IndexPath) {}
}

extension DMViewController: DMQRCodeScanViewControllerDelegate {
	func debugCodeScanViewController(_: DMQRCodeScanViewController, didScan diagnosisKey: SAP_TemporaryExposureKey) {
		client.submit(
			keys: [diagnosisKey.temporaryExposureKey],
			tan: "not needed"
		) { [weak self] _ in
			guard let self = self else { return }
			self.resetAndFetchKeys()
		}
	}
}

private extension DateFormatter {
	class func rollingPeriodDateFormatter() -> DateFormatter {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .medium
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		return formatter
	}
}

private extension SAP_TemporaryExposureKey {
	private static let dateFormatter: DateFormatter = .rollingPeriodDateFormatter()

	var rollingStartNumberDate: Date {
		Date(timeIntervalSince1970: Double(rollingStartIntervalNumber * 600))
	}

	var formattedRollingStartNumberDate: String {
		type(of: self).dateFormatter.string(from: rollingStartNumberDate)
	}

	var temporaryExposureKey: ENTemporaryExposureKey {
		let key = ENTemporaryExposureKey()
		key.keyData = keyData
		key.rollingStartNumber = UInt32(rollingStartIntervalNumber)
		key.transmissionRiskLevel = UInt8(transmissionRiskLevel)
		return key
	}
}

extension SAP_TemporaryExposureKey: Comparable {
	static func < (lhs: SAP_TemporaryExposureKey, rhs: SAP_TemporaryExposureKey) -> Bool {
		lhs.rollingStartIntervalNumber > rhs.rollingStartIntervalNumber
	}
}

private extension FetchedDaysAndHours {
	var allBuckets: [SAPDownloadedPackage] {
		Array(days.bucketsByDay.values) + Array(hours.bucketsByHour.values)
	}
}

private class KeyCell: UITableViewCell {
	static var reuseIdentifier = "KeyCell"
	override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
	}

	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension DMViewController: DMSubmissionStateViewControllerDelegate {
	func submissionStateViewController(
		_: DMSubmissionStateViewController,
		getDiagnosisKeys completionHandler: @escaping ENGetDiagnosisKeysHandler
	) {
		exposureManager.getTestDiagnosisKeys(completionHandler: completionHandler)
	}
}

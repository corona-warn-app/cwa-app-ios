//
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
//
#if !RELEASE

import ExposureNotification
import UIKit

/// The root view controller of the developer menu.
final class DMKeysViewController: UITableViewController {
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
		title = "🔑 Diagnosis Keys 🔑"
	}

	@available(*, unavailable)
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

	override func viewWillAppear(_ animated: Bool) {
		navigationController?.setToolbarHidden(false, animated: animated)
		setToolbarItems(
			[
				UIBarButtonItem(
					title: "Diag. Keys",
					style: .plain,
					target: self,
					action: #selector(refreshKeys)
				),
				UIBarButtonItem(
					barButtonSystemItem: .flexibleSpace,
					target: nil,
					action: nil
				),
				UIBarButtonItem(
					title: "Test Keys",
					style: .plain,
					target: self,
					action: #selector(generateTestKeysAndRefresh)
				),
				UIBarButtonItem(
					barButtonSystemItem: .flexibleSpace,
					target: nil,
					action: nil
				),
				UIBarButtonItem(
					title: "Export",
					style: .plain,
					target: self,
					action: #selector(exportKeys)
				)
			],
			animated: animated
		)
		super.viewWillAppear(animated)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(DMKeyCell.self, forCellReuseIdentifier: DMKeyCell.reuseIdentifier)
	}

	// MARK: Working with the Keys
	@objc
	private func refreshKeys() {
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

	@objc
	private func exportKeys() {
		let exportableKeys = keys.map {
			DMExportableKey(
				keyData: Array($0.keyData),
				rollingStartIntervalNumber: $0.rollingStartIntervalNumber,
				transmissionRiskLevel: $0.transmissionRiskLevel
			)
		}
		let encoder = JSONEncoder()
		guard let data = try? encoder.encode(exportableKeys) else {
			fatalError("Unable to encode keys.")
		}

		let json = String(decoding: data, as: UTF8.self)
		let activityViewController = UIActivityViewController(activityItems: [json], applicationActivities: nil)
		activityViewController.modalTransitionStyle = .coverVertical
		present(activityViewController, animated: true, completion: nil)
	}

	@objc
	private func generateTestKeysAndRefresh() {
		exposureManager.getTestDiagnosisKeys { keys, error in
			if let error = error {
				let alert = UIAlertController(
					title: "getTestDiagnosisKeys(…) failed",
					message: error.localizedDescription,
					preferredStyle: .alert
				)
				self.present(alert, animated: true, completion: nil)
				return
			}
			self.keys = (keys ?? []).map { $0.sapKey }
			self.tableView.reloadData()
		}
	}

	// MARK: UITableView

	override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		keys.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "DMKeyCell", for: indexPath)
		let key = keys[indexPath.row]
		
		cell.textLabel?.text = key.keyData.base64EncodedString()
		cell.detailTextLabel?.text = "Rolling Start Date: \(key.formattedRollingStartNumberDate)"
		return cell
	}

	override func tableView(_: UITableView, didSelectRowAt _: IndexPath) {}
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

struct DMExportableKey: Codable {
	let keyData: [UInt8]
	let rollingStartIntervalNumber: Int32
	let transmissionRiskLevel: Int32
}

#endif

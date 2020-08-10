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

#if !RELEASE

import ExposureNotification
import UIKit

protocol DMSubmissionStateViewControllerDelegate: AnyObject {
	func submissionStateViewController(
		_ controller: DMSubmissionStateViewController,
		getDiagnosisKeys completionHandler: @escaping ENGetDiagnosisKeysHandler
	)
}

/// This controller allows you to check if a previous submission of keys successfully ended up in the backend.
final class DMSubmissionStateViewController: UITableViewController {
	// MARK: Creating a submission state view controller
	init(
		client: Client,
		delegate: DMSubmissionStateViewControllerDelegate
	) {
		self.client = client
		self.delegate = delegate
		super.init(style: .plain)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: UIViewController
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.registerKeyCell()
	}

	override func viewWillAppear(_ animated: Bool) {
		navigationController?.setToolbarHidden(false, animated: animated)
		setToolbarItems(
			[
				UIBarButtonItem(
					barButtonSystemItem: .flexibleSpace,
					target: nil,
					action: nil
				),
				UIBarButtonItem(
					title: "Start Test",
					style: .plain,
					target: self,
					action: #selector(performCheck)
				),
				UIBarButtonItem(
					barButtonSystemItem: .flexibleSpace,
					target: nil,
					action: nil
				)
			],
			animated: animated
		)
		super.viewWillAppear(animated)
	}

	// MARK: Properties
	private weak var delegate: DMSubmissionStateViewControllerDelegate?
	private let client: Client
	private var checkResult = DMSubmittedKeysCheckResult(missingKeys: [], foundKeys: [])

	// MARK: UIViewController
	@objc
	func performCheck() {
		delegate?.submissionStateViewController(self, getDiagnosisKeys: { localKeys, error in
			if let error = error {
				fatalError("unable to get DiagnosisKeys: \(error.localizedDescription)")
			}
			guard let localKeys = localKeys else {
				fatalError("unable to get local diagnosis keys")
			}
			self.client.fetchAllKeys { downloadedPackages in
				let allPackages = downloadedPackages.allKeyPackages
				let allRemoteKeys = Array(allPackages
					.compactMap { try? $0.keys() }
					.joined()
				)

				var foundKeys = [ENTemporaryExposureKey]()
				var missingKeys = [ENTemporaryExposureKey]()


				for localKey in localKeys {
					let found = allRemoteKeys.containsKey(localKey)
					if found {
						foundKeys.append(localKey)
					} else {
						missingKeys.append(localKey)
					}
				}
				self.checkResult = .init(
					missingKeys: missingKeys,
					foundKeys: foundKeys
				)
				self.tableView.reloadData()
			}
		})
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		2
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "Missing Keys \(checkResult.missingKeys.count)"
		case 1:
			return "Found Keys \(checkResult.foundKeys.count)"
		default: fatalError("invalid state")
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return checkResult.missingKeys.count
		case 1:
			return checkResult.foundKeys.count
		default: fatalError("invalid state")
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableKeyCell(for: indexPath)
		let key: ENTemporaryExposureKey
		let row = indexPath.row
		switch indexPath.section {
		case 0:
			key = checkResult.missingKeys[row]
		case 1:
			key = checkResult.foundKeys[row]
		default: fatalError("invalid state")
		}

		cell.configure(
			with: DMKeyCell.Model(
				keyData: key.keyData,
				rollingStartIntervalNumber: Int32(key.rollingStartNumber),
				transmissionRiskLevel: Int32(key.transmissionRiskLevel)
			)
		)
		return cell
	}
}

private extension Data {
	static let binHeader = Data("EK Export v1    ".utf8)
	var withoutBinHeader: Data {
		let headerRange = startIndex ..< Data.binHeader.count

		guard subdata(in: headerRange) == Data.binHeader else {
			return self
		}
		return subdata(in: headerRange.endIndex ..< endIndex)
	}
}

private extension SAPDownloadedPackage {
	var binProtobufData: Data {
		bin.withoutBinHeader
	}

	func keys() throws -> [Apple_TemporaryExposureKey] {
		let data = binProtobufData
		let export = try Apple_TemporaryExposureKeyExport(serializedData: data)
		return export.keys
	}
}

private extension Array where Element == Apple_TemporaryExposureKey {
	func containsKey(_ key: ENTemporaryExposureKey) -> Bool {
		contains { appleKey in
			appleKey.keyData == key.keyData
		}
	}
}

private extension Client {
	typealias AvailableDaysAndHoursCompletion = (DaysAndHours) -> Void
	func availableDaysAndHours(
		completion completeWith: @escaping AvailableDaysAndHoursCompletion
	) {
		let group = DispatchGroup()

		var daysAndHours: DaysAndHours = .none

		group.enter()
		availableDays { result in
			if case let .success(days) = result {
				daysAndHours.days = days
			}
			group.leave()
		}

		group.enter()
		availableHours(day: .formattedToday()) { result in
			if case let .success(hours) = result {
				daysAndHours.hours = hours
			}
			group.leave()
		}

		group.notify(queue: .main) {
			completeWith(daysAndHours)
		}
	}

	func fetchAllKeys(
		completion completeWith: @escaping DaysAndHoursCompletionHandler
	) {
		availableDaysAndHours { daysAndHours in
			self.fetchDays(
				daysAndHours.days,
				hours: daysAndHours.hours,
				of: .formattedToday(),
				completion: completeWith
			)
		}
	}
}

private struct DMSubmittedKeysCheckResult {
	let missingKeys: [ENTemporaryExposureKey]
	let foundKeys: [ENTemporaryExposureKey]
}

#endif

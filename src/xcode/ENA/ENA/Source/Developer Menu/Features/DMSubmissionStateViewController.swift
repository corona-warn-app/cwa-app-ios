//
// 🦠 Corona-Warn-App
//

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

	// MARK: - Init

	init(
		client: Client,
		restService: RestServiceProviding,
		delegate: DMSubmissionStateViewControllerDelegate
	) {
		self.client = client
		self.restService = restService
		self.delegate = delegate
		self.fetchHoursServiceHelper = FetchHoursServiceHelper(restService: restService)
		super.init(style: .plain)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

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

	// MARK: - Protocol UITableViewDatasource

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

	// MARK: - Public

	// MARK: - Internal

	typealias AvailableDaysAndHoursCompletion = (DaysAndHours) -> Void

	// MARK: - Private

	private let client: Client
	private let restService: RestServiceProviding
	private let fetchHoursServiceHelper: FetchHoursServiceHelper

	private var checkResult = DMSubmittedKeysCheckResult(missingKeys: [], foundKeys: [])
	private weak var delegate: DMSubmissionStateViewControllerDelegate?

	@objc
	private func performCheck() {
		delegate?.submissionStateViewController(self, getDiagnosisKeys: { localKeys, error in
			if let error = error {
				fatalError("unable to get DiagnosisKeys: \(error.localizedDescription)")
			}
			guard let localKeys = localKeys else {
				fatalError("unable to get local diagnosis keys")
			}
			self.fetchAllKeys { downloadedPackages in
				let allPackages = downloadedPackages.allKeyPackages
				let allRemoteKeys = Array(allPackages.compactMap { try? $0.package?.keys() }.joined())

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

	private func availableDaysAndHours(
		completion completeWith: @escaping AvailableDaysAndHoursCompletion
	) {
		let group = DispatchGroup()

		var daysAndHours: DaysAndHours = .none

		group.enter()
		let daysResource = AvailableDaysResource(country: "DE")
		self.restService.load(daysResource) { result in
			defer {
				group.leave()
			}
			if case let .success(days) = result {
				daysAndHours.days = days
			}
		}

		group.enter()
		let hoursResource = AvailableHoursResource(day: .formattedToday(), country: "DE")
		self.restService.load(hoursResource) { result in
			defer {
				group.leave()
			}
			if case let .success(hours) = result {
				daysAndHours.hours = hours
			}
		}

		group.notify(queue: .main) {
			completeWith(daysAndHours)
		}
	}

	private func fetchAllKeys(
		completion completeWith: @escaping (FetchedDaysAndHours) -> Void
	) {
		availableDaysAndHours(
			completion: { daysAndHours in
				self.client.fetchDays(daysAndHours.days, forCountry: "DE") { daysResult in
					self.fetchHoursServiceHelper.fetchHours(daysAndHours.hours, day: .formattedToday(), country: "DE") { hoursResult in
						completeWith(FetchedDaysAndHours(hours: hoursResult, days: daysResult))
					}
				}
			}
		)
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

	func keys() throws -> [SAP_External_Exposurenotification_TemporaryExposureKey] {
		let data = binProtobufData
		let export = try SAP_External_Exposurenotification_TemporaryExposureKeyExport(serializedData: data)
		return export.keys
	}
}

private extension Array where Element == SAP_External_Exposurenotification_TemporaryExposureKey {
	func containsKey(_ key: ENTemporaryExposureKey) -> Bool {
		contains { appleKey in
			appleKey.keyData == key.keyData
		}
	}
}

private struct DMSubmittedKeysCheckResult {
	let missingKeys: [ENTemporaryExposureKey]
	let foundKeys: [ENTemporaryExposureKey]
}

#endif

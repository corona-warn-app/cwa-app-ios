import UIKit
import ExposureNotification

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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Properties
    private let client: Client
    private let store: Store
    private let exposureManager: ExposureManager
    private var keys = [Sap_TemporaryExposureKey]() {
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
            )
        ]

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                barButtonSystemItem: .action,
                target: self,
                action: #selector(generateTestKeys)
            ),
            UIBarButtonItem(
                image: UIImage(systemName: "qrcode.viewfinder"),
                style: .plain,
                target: self,
                action: #selector(showScanner)
            )
        ]
    }

    // MARK: Configuration
    @objc
    private func showConfiguration() {
        let viewController = DMConfigurationViewController(
            distributionURL: store.developerDistributionBaseURLOverride,
            submissionURL: store.developerSubmissionBaseURLOverride
        )
        navigationController?.pushViewController(viewController, animated: true)
    }

    // MARK: Fetching Keys
    @objc
    private func refreshKeys() {
        resetAndFetchKeys()
    }
    
    private func resetAndFetchKeys() {
        keys = []
        tableView.reloadData()
        self.client.fetch { [weak self] keys in
            guard let self = self else { return }
            fatalError("Implement")
            self.tableView.reloadData()
        }
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
            log(message: "Got diagnosis keys: \(_keys)", level: .info)
            self.client.submit(
                keys: _keys,
                tan: "TAN 123456"
            ) { [weak self] submitError in
                if let submitError = submitError {
                    logError(message: "Failed to submit test keys due to: \(submitError)")
                    return
                }
                self?.resetAndFetchKeys()
            }
        }
    }

    // MARK: UITableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        keys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KeyCell", for: indexPath)
        let key = keys[indexPath.row]

        cell.textLabel?.text = key.keyData.base64EncodedString()
        cell.detailTextLabel?.text = "Rolling Start Date: \(key.formattedRollingStartNumberDate)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = keys[indexPath.row]
        navigationController?.pushViewController(DMQRCodeViewController(key: key), animated: true)
    }
}

extension DMViewController: DMQRCodeScanViewControllerDelegate {
    func debugCodeScanViewController(_ viewController: DMQRCodeScanViewController, didScan diagnosisKey: Sap_TemporaryExposureKey) {
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

fileprivate extension Sap_TemporaryExposureKey {
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

extension Sap_TemporaryExposureKey: Comparable {
    static func < (lhs: Sap_TemporaryExposureKey, rhs: Sap_TemporaryExposureKey) -> Bool {
        lhs.rollingStartIntervalNumber > rhs.rollingStartIntervalNumber
    }
}

private extension FetchedDaysAndHours {
    var allBuckets: [SAPKeyPackage] {
        Array(days.bucketsByDay.values) + Array(hours.bucketsByHour.values)
    }
}

private extension Client {
    typealias FetchCompletion = ([SAPKeyPackage]) -> Void
    func fetch(completion: @escaping FetchCompletion) {
        availableDaysAndHoursUpUntil(.formattedToday()) { result in
            switch result {
            case .success(let daysAndHours):
                self.fetchDays(
                    daysAndHours.days,
                    hours: daysAndHours.hours,
                    of: .formattedToday()
                ) { daysAndHours in
                    completion(daysAndHours.allBuckets)
                }
            case .failure(let error):
                logError(message: "message: Failed to fetch all keys: \(error)")
            }
        }
    }
}

private class KeyCell: UITableViewCell {
    static var reuseIdentifier = "KeyCell"
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

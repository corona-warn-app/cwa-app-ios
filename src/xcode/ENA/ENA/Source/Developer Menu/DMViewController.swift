import UIKit
import ExposureNotification
import UserNotifications

private class KeyCell: UITableViewCell {
    static var reuseIdentifier = "KeyCell"
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The root view controller of the developer menu.
final class DMViewController: UITableViewController {
    // MARK: Creating a developer menu view controller
    init(client: Client) {
        self.client = client
        super.init(style: .plain)
        self.title = "Developer Menu"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Properties
    private let client: Client
    private var urls = [URL]()
    private var keys = [Apple_Key]()

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(KeyCell.self, forCellReuseIdentifier: KeyCell.reuseIdentifier)

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(generateTestKeys)),
            UIBarButtonItem(image: UIImage(systemName: "qrcode.viewfinder"), style: .plain, target: self, action: #selector(showScanner))
        ]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        resetAndFetchKeys()
    }

    // MARK: Fetching Keys
    private func resetAndFetchKeys() {
        urls = []
        keys = []
        client.fetch { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let urls):
                self.urls = urls
                self.urls.forEach { url in
                    self.extractKeys(from: url)
                }
            case .failure:
                self.urls = []
            }
            self.tableView.reloadData()
        }
    }

    private func extractKeys(from url: URL) {
        guard let data = try? Data(contentsOf: url) else {
            // This can happen initially if the user never submitted keys using the client.
            // In that case the url does not exist.
            // We do not check for existence of `url` prior to calling `contentsOf:` in order
            // to avoid race conditions.
            return
        }
        guard let file = try? Apple_File(serializedData: data) else {
            // swiftlint:disable:next line_length
            fatalError("-serializedData: (Apple_Key) failed. This probably happens because the Protocol Buffer schema changed. Try reinstalling the app. If that does not help consider creating an issue.")
        }
        keys += file.key
        // Newer keys come before older keys
        keys.sort { lhKey, rhKey -> Bool in
            return lhKey.rollingStartNumber > rhKey.rollingStartNumber
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
        let manager = ExposureManager()
        manager.activate { activationError in
            if let activationError = activationError {
                logError(message: "Failed to generate test keys because exposure manager could not be activated due to: \(activationError)")
                return
            }
            manager.enable { enableError in
                if let enableError = enableError {
                    logError(message: "Failed to generate test keys because exposure manager could not be enabled due to: \(enableError)")
                    return
                }
                manager.getTestDiagnosisKeys { [weak self] keys, error in
                    guard let self = self else {
                        return
                    }
                    if let error = error {
                        logError(message: "Failed to generate test keys due to: \(error)")
                        return
                    }
                    let _keys = keys ?? []
                    log(message: "Got diagnosis keys: \(_keys)", level: .info)
                    self.client.submit(keys: keys ?? [], tan: "not needed here") { [weak self] submitError in
                        if let submitError = submitError {
                            logError(message: "Failed to submit test keys due to: \(submitError)")
                            return
                        }
                        self?.resetAndFetchKeys()
                    }
                }
            }
        }
    }

    // MARK: UITableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
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
    func debugCodeScanViewController(_ viewController: DMQRCodeScanViewController, didScan diagnosisKey: Apple_Key) {
        client.submit(
            keys: [diagnosisKey.temporaryExposureKey],
            tan: "not needed"
        ) { [weak self] _ in
            guard let self = self else { return }
            self.client.fetch { [weak self] result in
                switch result {
                case .success(let urls):
                    self?.urls = urls
                case .failure:
                    self?.urls = []
                }
                self?.tableView.reloadData()
            }
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

fileprivate extension Apple_Key {
    private static let dateFormatter: DateFormatter = .rollingPeriodDateFormatter()

    var rollingStartNumberDate: Date {
        return Date(timeIntervalSince1970: Double(rollingStartNumber * 600))
    }

    var formattedRollingStartNumberDate: String {
        type(of: self).dateFormatter.string(from: rollingStartNumberDate)
    }

    var temporaryExposureKey: ENTemporaryExposureKey {
        let key = ENTemporaryExposureKey()
        key.keyData = keyData
        key.rollingStartNumber = rollingStartNumber
        key.transmissionRiskLevel = UInt8(transmissionRiskLevel)
        return key
    }
}

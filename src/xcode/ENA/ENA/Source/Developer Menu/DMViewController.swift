import UIKit
import ExposureNotification
import UserNotifications

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
    private var keys = [ENTemporaryExposureKey]()

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "KeyCell")

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "qrcode.viewfinder"), style: .plain, target: self, action: #selector(showScanner))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        client.fetch() { result in
            switch result {
            case .success(let keys):
                self.keys = keys
            case .failure(_):
                self.keys = []
            }
            self.tableView.reloadData()
        }
    }

    // MARK: QR Code related
    @objc
    private func showScanner() {
        present(DMViewController(client: client), animated: true)
    }

    // MARK: UITableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KeyCell", for: indexPath)
        let key = keys[indexPath.row]
        cell.textLabel?.text = (key.keyData.base64EncodedString())
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = DMCodableDiagnosisKey(temporaryKey: keys[indexPath.row])
        navigationController?.pushViewController(DMQRCodeViewController(key: key), animated: true)
    }
}

extension DMViewController: DMQRCodeScanViewControllerDelegate {
    func debugCodeScanViewController(_ viewController: DMQRCodeScanViewController, didScan diagnosisKey: DMCodableDiagnosisKey) {
        client.submit(
            keys: [diagnosisKey.temporaryExposureKey],
            tan: "not needed") {
                error in
                self.client.fetch() { [weak self] result in
                    switch result {
                    case .success(let keys):
                        self?.keys = keys
                    case .failure(_):
                        self?.keys = []
                    }
                    self?.tableView.reloadData()
                }
        }
    }
}

/// Helper to convert an `DMCodableDiagnosisKey` to and from `ENTemporaryExposureKey`.
fileprivate extension DMCodableDiagnosisKey {
    init(temporaryKey key: ENTemporaryExposureKey) {
        self.init(keyData: key.keyData, rollingPeriod: key.rollingPeriod, rollingStartNumber: key.rollingStartNumber, transmissionRiskLevel: key.transmissionRiskLevel)
    }

    var temporaryExposureKey: ENTemporaryExposureKey {
        let key = ENTemporaryExposureKey()
        key.keyData = keyData
        key.rollingStartNumber = rollingStartNumber
        key.transmissionRiskLevel = transmissionRiskLevel
        return key
    }
}

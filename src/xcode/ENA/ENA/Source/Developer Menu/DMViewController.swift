import UIKit
import ExposureNotification
import UserNotifications

fileprivate extension CodableDiagnosisKey {
    init(temporaryKey key: ENTemporaryExposureKey) {
        self.init(keyData: key.keyData, rollingStartNumber: key.rollingStartNumber, transmissionRiskLevel: key.transmissionRiskLevel.rawValue)
    }
    var temporaryExposureKey: ENTemporaryExposureKey {
        let key = ENTemporaryExposureKey()
        key.keyData = keyData
        key.rollingStartNumber = rollingStartNumber
        if let riskLevel = ENRiskLevel(rawValue: transmissionRiskLevel) {
            key.transmissionRiskLevel = riskLevel
        }
        return key
    }
}

final class DeveloperMenuViewController: UITableViewController {
    private let client: Client
    private var keys = [ENTemporaryExposureKey]()

    init(client: Client) {
        self.client = client
        super.init(style: .plain)
        self.title = "Developer Menu"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "KeyCell")

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "qrcode.viewfinder"), style: .plain, target: self, action: #selector(showScanner))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    // MARK: QR Code
    @objc
    private func showScanner() {
        print("scan")
        present(DebugCodeScanViewController(delegate: self), animated: true)
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
        let key = CodableDiagnosisKey(temporaryKey: keys[indexPath.row])
        navigationController?.pushViewController(DMQRCodeViewController(key: key), animated: true)
    }
}

extension DeveloperMenuViewController: DebugCodeScanViewControllerDelegate {
    func debugCodeScanViewController(_ viewController: DebugCodeScanViewController, didScan diagnosisKey: CodableDiagnosisKey) {
        print("scan done")
        client.submit(keys: [diagnosisKey.temporaryExposureKey], tan: "not needed") { error in
            print("done")
        }
    }
}

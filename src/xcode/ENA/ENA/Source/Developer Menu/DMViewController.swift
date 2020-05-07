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
    private var urls = [URL]()
    private var keys = [Key]()

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
                self.urls = keys
                self.urls.forEach { url in
                    self.extractKeys(from: url)
                }
            case .failure(_):
                self.urls = []
            }
            self.tableView.reloadData()
        }
    }
    

    private func extractKeys(from url: URL) {
        guard let data = try? Data(contentsOf: url) else {
            fatalError("never")
        }
        guard let file = try? File(serializedData: data) else {
            fatalError("never never ever")
        }
        keys = file.key
    }

    // MARK: QR Code related
    @objc
    private func showScanner() {
        present(DMQRCodeScanViewController(delegate: self), animated: true)
    }

    // MARK: UITableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KeyCell", for: indexPath)
        let key = keys[indexPath.row]
        cell.textLabel?.text = key.keyData.base64EncodedString()
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = keys[indexPath.row]
        navigationController?.pushViewController(DMQRCodeViewController(key: key), animated: true)
    }
}

extension DMViewController: DMQRCodeScanViewControllerDelegate {
    func debugCodeScanViewController(_ viewController: DMQRCodeScanViewController, didScan diagnosisKey: Key) {
        client.submit(
            keys: [diagnosisKey.temporaryExposureKey],
            tan: "not needed") {
                error in
                self.client.fetch() { [weak self] result in
                    switch result {
                    case .success(let urls):
                        self?.urls = urls
                    case .failure(_):
                        self?.urls = []
                    }
                    self?.tableView.reloadData()
                }
        }
    }
}

fileprivate extension Key {
    var temporaryExposureKey: ENTemporaryExposureKey {
        let key = ENTemporaryExposureKey()
        key.keyData = keyData
        key.rollingStartNumber = rollingStartNumber
        key.transmissionRiskLevel = UInt8(transmissionRiskLevel)
        return key
    }
}

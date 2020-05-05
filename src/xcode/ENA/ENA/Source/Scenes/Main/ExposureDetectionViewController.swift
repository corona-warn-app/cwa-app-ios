//
//  ExposureDetectionViewController.swift
//  ENA
//
//  Created by Bormeth, Marc on 30.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit
import ExposureNotification

class ExposureDetectionViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var contactTitleLabel: UILabel!
    @IBOutlet weak var lastContactLabel: UILabel!

    @IBOutlet weak var lastSyncLabel: UILabel!
    @IBOutlet weak var syncButton: UIButton!
    @IBOutlet weak var nextSyncLabel: UILabel!

    @IBOutlet weak var infoTitleLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!

    var exposureDetectionService: ExposureDetectionService?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateLastSyncLabel),
                                               name: .dateLastExposureDetectionDidChange,
                                               object: nil)

        setupView()
    }

    private func setupView() {
        contactTitleLabel.text = .lastContactTitle
        let lastContactStringFormat = NSLocalizedString("lastDays", comment: "")
        lastContactLabel.text = String.localizedStringWithFormat(lastContactStringFormat, 3)

        updateLastSyncLabel()
        updateNextSyncLabel()

        syncButton.setTitle(.synchronize, for: .normal)
        infoTitleLabel.text = .info
        infoTextView.text = .infoText
    }

    @objc func updateLastSyncLabel() {

        let lastContactStringFormat = NSLocalizedString("lastHours", comment: "")
        guard let lastSync = PersistenceManager.shared.dateLastExposureDetection else {
            self.lastSyncLabel.text = NSLocalizedString("unknown_time", comment: "")
            return
        }
        let hours = Calendar.current.component(.hour, from: lastSync)
        self.lastSyncLabel.text =  String.localizedStringWithFormat(lastContactStringFormat, hours)
    }

    private func updateNextSyncLabel() {
        let stringFormat = NSLocalizedString("nextSync", comment: "")
        nextSyncLabel.text = String.localizedStringWithFormat(stringFormat, 18)
    }


    @IBAction func refresh(_ sender: UIButton) {
        exposureDetectionService?.detectExposureIfNeeded()
    }
}

fileprivate extension String {

    static let lastContactTitle = NSLocalizedString("ExposureDetection_lastContactTitle", comment: "")
    static let synchronize = NSLocalizedString("ExposureDetection_synchronize", comment: "")

    static let info = NSLocalizedString("ExposureDetection_info", comment: "")
    static let infoText = NSLocalizedString("ExposureDetection_infoText", comment: "")

}

extension ExposureDetectionViewController : ExposureDetectionServiceDelegate {
    func exposureDetectionServiceDidStart(_ service: ExposureDetectionService) {
        activityIndicator.startAnimating()
    }

    func exposureDetectionServiceDidFinish(_ service: ExposureDetectionService, summary: ENExposureDetectionSummary) {
        activityIndicator.stopAnimating()
        infoTextView.text = summary.pretty
    }

    func exposureDetectionServiceDidFail(_ service: ExposureDetectionService, error: Error) {
        activityIndicator.stopAnimating()
    }
}

fileprivate extension ENExposureDetectionSummary {
    var pretty: String {
        return """
        daysSinceLastExposure: \(daysSinceLastExposure)
        matchedKeyCount: \(matchedKeyCount)
        maximumRiskScore: \(maximumRiskScore)
        """
    }
}

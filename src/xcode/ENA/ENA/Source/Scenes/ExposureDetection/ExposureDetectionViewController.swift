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

    private lazy var exposureDetectionService = ExposureDetectionService(delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateLastSyncLabel),
                                               name: .dateLastExposureDetectionDidChange,
                                               object: nil)

        setupView()
    }

    private func setupView() {
        contactTitleLabel.text = AppStrings.ExposureDetection.lastContactTitle
        lastContactLabel.text = String.localizedStringWithFormat(AppStrings.ExposureDetection.lastContactDays, 3)

        updateLastSyncLabel()
        updateNextSyncLabel()

        syncButton.setTitle(AppStrings.ExposureDetection.synchronize, for: .normal)
        infoTitleLabel.text = AppStrings.ExposureDetection.info
        infoTextView.text = AppStrings.ExposureDetection.infoText
    }

    @objc func updateLastSyncLabel() {
        guard let lastSync = PersistenceManager.shared.dateLastExposureDetection else {
            self.lastSyncLabel.text = AppStrings.ExposureDetection.lastSync
            return
        }
        let hours = Calendar.current.component(.hour, from: lastSync)
        self.lastSyncLabel.text =  String.localizedStringWithFormat(AppStrings.ExposureDetection.lastContactHours, hours)
    }

    private func updateNextSyncLabel() {
        nextSyncLabel.text = String.localizedStringWithFormat(AppStrings.ExposureDetection.nextSync, 18)
    }


    @IBAction func refresh(_ sender: UIButton) {
        exposureDetectionService.detectExposureIfNeeded()
    }
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

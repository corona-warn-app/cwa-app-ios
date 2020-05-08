//
//  ExposureDetectionViewController.swift
//  ENA
//
//  Created by Bormeth, Marc on 30.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit
import ExposureNotification

final class ExposureDetectionViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var contactTitleLabel: UILabel!
    @IBOutlet weak var lastContactLabel: UILabel!

    @IBOutlet weak var lastSyncLabel: UILabel!
    @IBOutlet weak var syncButton: UIButton!
    @IBOutlet weak var nextSyncLabel: UILabel!

    @IBOutlet weak var infoTitleLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!

    var exposureDetectionService: ExposureDetector?
    var client: Client?
    var exposureManager: ExposureManager?
    
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
            lastSyncLabel.text = AppStrings.ExposureDetection.lastSync
            return
        }
        let hours = Calendar.current.component(.hour, from: lastSync)
        lastSyncLabel.text =  String.localizedStringWithFormat(AppStrings.ExposureDetection.lastContactHours, hours)
    }

    private func updateNextSyncLabel() {
        nextSyncLabel.text = String.localizedStringWithFormat(AppStrings.ExposureDetection.nextSync, 18)
    }


    @IBAction func refresh(_ sender: UIButton) {
        guard let client = client else {
            fatalError("`client` must be set before being able to refresh.")
        }

        // The user wants to know his/her current risk. We have to do several things in order to be able to display
        // the risk.
        // 1. Get the configuration from the backend.
        // 2. Get new diagnosis keys from the backend.
        // 3. Create a detector and start it.
        client.exposureConfiguration { configurationResult in
            switch configurationResult {
            case .success(let configuration):
                client.fetch() { [weak self] fetchResult in
                    switch fetchResult {
                        case .success(let urls):
                            self?.startExposureDetector(configuration: configuration, diagnosisKeyURLs: urls)
                        case .failure(_):
                        print("fail")
                    }
                }
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }

    private func startExposureDetector(configuration: ENExposureConfiguration, diagnosisKeyURLs: [URL]) {
        guard let exposureManager = exposureManager else {
            fatalError("exposureManager cannot be nil here.")
        }
        log(message: "Starting exposure detector")
        activityIndicator.startAnimating()
        let _ = exposureManager.detectExposures(configuration: configuration, diagnosisKeyURLs: diagnosisKeyURLs) { (summary, error) in
            if let error = error {
                self.activityIndicator.stopAnimating()
                logError(message: "Exposure detection failed due to underlying error: \(error.localizedDescription)")
                return
            }
            guard let summary = summary else {
                fatalError("can never happen")
            }
            log(message: "Exposure detection finished with summary: \(summary.pretty)")
            self.activityIndicator.stopAnimating()
            self.infoTextView.text = summary.pretty
        }
    }
}

fileprivate extension ENExposureDetectionSummary {
    var pretty: String {
        """
        daysSinceLastExposure: \(daysSinceLastExposure)
        matchedKeyCount: \(matchedKeyCount)
        maximumRiskScore: \(maximumRiskScore)
        """
    }
}

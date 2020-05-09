//
//  ExposureDetectionViewController.swift
//  ENA
//
//  Created by Bormeth, Marc on 30.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit
import ExposureNotification

protocol ExposureDetectionViewControllerDelegate: AnyObject {
    func exposureDetectionViewController(_ controller: ExposureDetectionViewController, didReceiveSummary summary: ENExposureDetectionSummary)
}

final class ExposureDetectionViewController: UIViewController {
    // MARK: Properties
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var contactTitleLabel: UILabel!
    @IBOutlet weak var lastContactLabel: UILabel!
    @IBOutlet weak var lastSyncLabel: UILabel!
    @IBOutlet weak var syncButton: UIButton!
    @IBOutlet weak var nextSyncLabel: UILabel!
    @IBOutlet weak var infoTitleLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!

    @IBOutlet weak var infoLabel: UILabel!
    var client: Client?
    var exposureManager: ExposureManager?
    weak var delegate: ExposureDetectionViewControllerDelegate?

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateLastSyncLabel),
            name: .dateLastExposureDetectionDidChange,
            object: nil
        )

        setupView()
    }

    // MARK: Helper
    private func setupView() {
        contactTitleLabel.text = AppStrings.ExposureDetection.lastContactTitle
        lastContactLabel.text = String.localizedStringWithFormat(AppStrings.ExposureDetection.lastContactDays, 3)

        updateLastSyncLabel()
        updateNextSyncLabel()

        syncButton.setTitle(AppStrings.ExposureDetection.synchronize, for: .normal)
        infoTitleLabel.text = AppStrings.ExposureDetection.info
        infoTextView.text = AppStrings.ExposureDetection.infoText
    }

    // MARK: Notification Handler
    @objc
    func updateLastSyncLabel() {
        guard let lastSync = PersistenceManager.shared.dateLastExposureDetection else {
            lastSyncLabel.text = AppStrings.ExposureDetection.lastSync
            return
        }
        let hours = Calendar.current.component(.hour, from: lastSync)
        lastSyncLabel.text = String.localizedStringWithFormat(AppStrings.ExposureDetection.lastContactHours, hours)
    }

    private func updateNextSyncLabel() {
        nextSyncLabel.text = String.localizedStringWithFormat(AppStrings.ExposureDetection.nextSync, 18)
    }


    // MARK: Actions
    @IBAction func refresh(_ sender: UIButton) {
        guard let client = client else {
            let error = "`client` must be set before being able to refresh."
            logError(message: error)
            fatalError(error)
        }

        // The user wants to know his/her current risk. We have to do several things in order to be able to display
        // the risk.
        // 1. Get the configuration from the backend.
        // 2. Get new diagnosis keys from the backend.
        // 3. Create a detector and start it.
        client.exposureConfiguration { configurationResult in
            switch configurationResult {
            case .success(let configuration):
                client.fetch { [weak self] fetchResult in
                    switch fetchResult {
                    case .success(let urls):
                        self?.startExposureDetector(configuration: configuration, diagnosisKeyURLs: urls)
                    case .failure(let fetchError):
                        logError(message: "Failed to fetch using client: \(fetchError.localizedDescription)")
                    }
                }
            case .failure(let error):
                logError(message: "Failed to get configuration: \(error.localizedDescription)")
            }
        }
    }

    // Important:
    // See HomeViewController for more details as to why we do this.
    private func startExposureDetector(configuration: ENExposureConfiguration, diagnosisKeyURLs: [URL]) {
        log(message: "Starting exposure detector")
        activityIndicator.startAnimating()

        let exposureManager = ExposureManager()

        func stopAndInvalidate() {
            activityIndicator.stopAnimating()
            exposureManager.invalidate()
        }

        func start() {
            _ = exposureManager.detectExposures(configuration: configuration, diagnosisKeyURLs: diagnosisKeyURLs) { summary, error in
                if let error = error {
                    logError(message: "Exposure detection failed due to underlying error: \(error.localizedDescription)")
                    stopAndInvalidate()
                    return
                }
                guard let summary = summary else {
                    fatalError("can never happen")
                }
                self.delegate?.exposureDetectionViewController(self, didReceiveSummary: summary)
                log(message: "Exposure detection finished with summary: \(summary.pretty)")
                self.infoLabel.backgroundColor = summary.riskLevel.backgroundColor
                self.infoLabel.attributedText = summary.pretty
                stopAndInvalidate()
            }
        }

        exposureManager.activate { error in
            if let error = error {
                logError(message: "Unable to detect exposures because exposure manager could not be activated due to: \(error)")
                stopAndInvalidate()
                return
            }
            start()
        }
    }
}

fileprivate extension ENExposureDetectionSummary {
    var pretty: NSAttributedString {
        let string = NSMutableAttributedString()
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 30)
        ]
        string.append(NSAttributedString(string: "\n\(riskLevel.localizedString)", attributes: attributes))
        string.append(NSAttributedString(string: "\n\n\n\(daysSinceLastExposure) Tage seit Kontakt", attributes: attributes))
          string.append(NSAttributedString(string: "\n\(matchedKeyCount) Kontakte\n\n", attributes: attributes))
        return string

    }
}

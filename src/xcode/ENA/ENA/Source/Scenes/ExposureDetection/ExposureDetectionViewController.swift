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
    @IBOutlet weak var riskViewContainerView: UIView!

    var client: Client?
    var exposureManager: ExposureManager?
    weak var delegate: ExposureDetectionViewControllerDelegate?
    weak var exposureDetectionSummary: ENExposureDetectionSummary?
    var riskView: RiskView?

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
        setupHeaderRiskView(to: riskViewContainerView)
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

    private func updateRiskView() {
        guard let riskView = self.riskView else {
            return
        }
        riskView.lastSyncLabel.text = "Letzte Überprüfung: \(Date())"

        if let summary = exposureDetectionSummary, summary.riskLevel != .unknown {
            riskView.daysSinceLastExposureLabel.text = "\(summary.daysSinceLastExposure)"
            riskView.matchedKeyCountLabel.text = "\(summary.matchedKeyCount)"

            switch summary.riskLevel {
            case .low:
                riskView.highRiskDetailView.isHidden = false
                riskView.riskDetailDescriptionLabel.text = "Es wurde ein geringes Risiko erkannt"
                riskView.riskImageView.image = UIImage(systemName: "cloud.rain")
                riskView.backgroundColor = UIColor.preferredColor(for: ColorStyle.positive)
            case .moderate:
                riskView.highRiskDetailView.isHidden = false
                riskView.riskDetailDescriptionLabel.text = "Es wurde ein moderates Risiko erkannt"
                riskView.riskImageView.image = UIImage(systemName: "cloud.rain")
                riskView.backgroundColor = UIColor.preferredColor(for: ColorStyle.critical)
            default:
                riskView.highRiskDetailView.isHidden = false
                riskView.riskDetailDescriptionLabel.text = "Vor \(summary.daysSinceLastExposure) Tagen hattest du das letzte Mal Kontakt mit Personen, die mit COVID 19 infiziert wurden"
                riskView.riskImageView.image = UIImage(systemName: "cloud.bolt")
                riskView.backgroundColor = UIColor.preferredColor(for: ColorStyle.negative)
            }

        } else {
           riskView.titleRiskLabel.text = "Risiko unbekannt"
           riskView.daysSinceLastExposureLabel.text = "0"
           riskView.matchedKeyCountLabel.text = "0"
           riskView.highRiskDetailView.isHidden = true //disable or enable view as you want
           riskView.riskDetailDescriptionLabel.text = "Es wurde kein Kontakt mit COVID 19 erkannt"
           riskView.riskImageView.image = UIImage(systemName: "sun.min")
           riskView.backgroundColor = UIColor.preferredColor(for: ColorStyle.positive)
       }

    }

    private func setupHeaderRiskView(to view: UIView) {
        guard let riskView = UINib(nibName: "RiskView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? RiskView else {
            return
        }
        riskView.translatesAutoresizingMaskIntoConstraints = false
        riskView.delegate = self
        view.addSubview(riskView)
        NSLayoutConstraint.activate([
            riskView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            riskView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            riskView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            riskView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
        self.riskView = riskView
        updateRiskView()
    }

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


    @IBAction func refresh(_ sender: Any) {
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
                self.infoTextView.text = summary.pretty
                self.updateRiskView()
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

extension ExposureDetectionViewController: RiskViewDelegate {
    func refreshView() {
        self.refresh(self)
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

private extension ENExposureDetectionSummary {
    var riskLevel: RiskCollectionViewCell.RiskLevel {
        // The mapping between the maximum risk score and the `RiskCollectionViewCell.RiskLevel`
        // is simply our best guess for the moment. If you see this and have more information about the
        // mapping to use don't hesitate to change the following code.
        switch maximumRiskScore {
        case 1, 2, 3:
            return .low
        case 4, 5, 6:
            return .moderate
        case 7, 8:
            return .high
        default:
            return .unknown
        }
    }
}

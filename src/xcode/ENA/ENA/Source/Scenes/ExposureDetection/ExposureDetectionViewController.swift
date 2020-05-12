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
    @IBOutlet weak var infoTitleLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var riskViewContainerView: UIView!

    var client: Client?
    var exposureManager: ExposureManager?
    weak var delegate: ExposureDetectionViewControllerDelegate?
    weak var exposureDetectionSummary: ENExposureDetectionSummary?
    let riskView: RiskView

    required init?(coder: NSCoder) {
        guard let riskView = UINib(nibName: "RiskView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? RiskView else {
              fatalError("It should not happen. RiskView is not avaiable")
        }
        self.riskView = riskView
        super.init(coder: coder)
    }

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
        setupHeaderRiskView(to: riskViewContainerView)

        infoTitleLabel.text = AppStrings.ExposureDetection.info
        infoTextView.text = AppStrings.ExposureDetection.infoText
    }

    private func updateRiskView() {
        updateLastSyncLabel()
        updateNextSyncLabel()

        if let summary = exposureDetectionSummary, summary.riskLevel != .unknown {
            riskView.daysSinceLastExposureLabel.text = "\(summary.daysSinceLastExposure)"
            riskView.matchedKeyCountLabel.text = "\(summary.matchedKeyCount)"
            riskView.highRiskDetailView.isHidden = false
            setRiskView(to: summary.riskLevel)
        } else {
            riskView.titleRiskLabel.text = AppStrings.RiskView.unknownRisk
            riskView.daysSinceLastExposureLabel.text = "0"
            riskView.matchedKeyCountLabel.text = "0"
            riskView.highRiskDetailView.isHidden = true //disable or enable view as you want
            riskView.riskDetailDescriptionLabel.text = AppStrings.RiskView.unknownRiskDetail
            riskView.riskImageView.image = UIImage(systemName: "sun.min")
            riskView.backgroundColor = UIColor.preferredColor(for: ColorStyle.positive)
       }
    }

    private func setRiskView(to riskLevel: RiskCollectionViewCell.RiskLevel) {
        switch riskLevel {
        case .low:
            riskView.titleRiskLabel.text = AppStrings.RiskView.lowRisk
            riskView.riskDetailDescriptionLabel.text = AppStrings.RiskView.lowRiskDetail
            riskView.riskImageView.image = UIImage(systemName: "cloud.rain")
            riskView.backgroundColor = UIColor.preferredColor(for: ColorStyle.positive)
        case .moderate:
            riskView.titleRiskLabel.text = AppStrings.RiskView.moderateRisk
            riskView.riskDetailDescriptionLabel.text = AppStrings.RiskView.moderateRiskDetail
            riskView.riskImageView.image = UIImage(systemName: "cloud.rain")
            riskView.backgroundColor = UIColor.preferredColor(for: ColorStyle.critical)
        default:
            riskView.titleRiskLabel.text = AppStrings.RiskView.highRisk
            riskView.riskDetailDescriptionLabel.text = AppStrings.RiskView.highRiskDetail
            riskView.riskImageView.image = UIImage(systemName: "cloud.bolt")
            riskView.backgroundColor = UIColor.preferredColor(for: ColorStyle.negative)
        }
    }

    private func setupHeaderRiskView(to view: UIView) {
        riskView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(riskView)
        NSLayoutConstraint.activate(
            [
            riskView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            riskView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            riskView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            riskView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
            ]
        )
        riskView.delegate = self
        self.updateRiskView()
    }

    @objc
    func updateLastSyncLabel() {
        guard let lastSync = PersistenceManager.shared.dateLastExposureDetection else {
            riskView.lastSyncLabel.text = AppStrings.ExposureDetection.lastSyncUnknown
            return
        }
        riskView.lastSyncLabel.text = AppStrings.ExposureDetection.lastSync + lastSync.description
    }

    private func updateNextSyncLabel() {
        riskView.refreshButton.setTitle(String.localizedStringWithFormat(AppStrings.ExposureDetection.nextSync, 0), for: .normal)
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

        let startDate = Date()

        let exposureManager = ExposureManager()

        func stopAndInvalidate() {
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
                self.exposureDetectionSummary = summary
                PersistenceManager.shared.dateLastExposureDetection = startDate
                self.delegate?.exposureDetectionViewController(self, didReceiveSummary: summary)
                log(message: "Exposure detection finished with summary: \(summary.pretty)")
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
    func riskView(riskView: RiskView, didTapRefreshButton _: UIButton) {
        refresh(riskView)
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
        string.append(NSAttributedString(string: "\n Max Risk Score:\(maximumRiskScore)", attributes: attributes))
        return string

    }
}

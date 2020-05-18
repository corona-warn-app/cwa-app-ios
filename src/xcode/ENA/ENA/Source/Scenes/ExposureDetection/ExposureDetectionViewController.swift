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
    // MARK: Creating a Exposure Detection View Controller
    required init?(coder: NSCoder, client: Client, store: Store, signedPayloadStore: SignedPayloadStore) {
        guard let riskView = UINib(nibName: "RiskView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? RiskView else {
              fatalError("It should not happen. RiskView is not avaiable")
        }
        self.client = client
        self.store = store
        self.riskView = riskView
        self.signedPayloadStore = signedPayloadStore
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Properties
    @IBOutlet weak var infoTitleLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var riskViewContainerView: UIView!
    private var transaction: ExposureDetectionTransaction?

    private let store: Store
    private let signedPayloadStore: SignedPayloadStore
    let client: Client
    var exposureManager: ExposureManager?
    weak var delegate: ExposureDetectionViewControllerDelegate?
    weak var exposureDetectionSummary: ENExposureDetectionSummary?
    let riskView: RiskView


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

        if let summary = exposureDetectionSummary, let riskLevel = RiskLevel(riskScore: summary.maximumRiskScore) {
            riskView.daysSinceLastExposureLabel.text = "\(summary.daysSinceLastExposure)"
            riskView.matchedKeyCountLabel.text = "\(summary.matchedKeyCount)"
            riskView.highRiskDetailView.isHidden = false
            setRiskView(to: riskLevel)
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

    private func setRiskView(to riskLevel: RiskLevel) {
        switch riskLevel {
        case .low:
            riskView.titleRiskLabel.text = AppStrings.RiskView.lowRisk
            riskView.riskDetailDescriptionLabel.text = AppStrings.RiskView.lowRiskDetail
            riskView.riskImageView.image = UIImage(systemName: "cloud.rain")
            riskView.backgroundColor = UIColor.preferredColor(for: ColorStyle.positive)
        case .inactive:
            riskView.titleRiskLabel.text = AppStrings.RiskView.inactiveRisk
            riskView.riskDetailDescriptionLabel.text = AppStrings.RiskView.inactiveRiskDetail
            riskView.riskImageView.image = UIImage(systemName: "cloud.rain")
            riskView.backgroundColor = UIColor.preferredColor(for: ColorStyle.inactive)
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
        guard let lastSync = store.dateLastExposureDetection else {
            riskView.lastSyncLabel.text = AppStrings.ExposureDetection.lastSyncUnknown
            return
        }
        riskView.lastSyncLabel.text = AppStrings.ExposureDetection.lastSync + lastSync.description
    }

    private func updateNextSyncLabel() {
        riskView.refreshButton.setTitle(String.localizedStringWithFormat(AppStrings.ExposureDetection.nextSync, 0), for: .normal)
    }

    @IBAction func refresh(_ sender: Any) {
        guard transaction == nil else {
            log(message: "Transaction already active. Please wait.")
            return
        }
        // The user wants to know his/her current risk.
        // We simply start the exposure detection transaction which does all the heavy lifting.
        let transaction = ExposureDetectionTransaction(
            delegate: self,
            client: client,
            signedPayloadStore: signedPayloadStore
        )
        log(message: "Starting exposure detection…")
        self.transaction = transaction
        transaction.resume()
    }
}

extension ExposureDetectionViewController: ExposureDetectionTransactionDelegate {
    func exposureDetectionTransaction(
        _ transaction: ExposureDetectionTransaction,
        didDetectSummary summary: ENExposureDetectionSummary
    ) {
        exposureDetectionSummary = summary
        store.dateLastExposureDetection = Date()
        delegate?.exposureDetectionViewController(
            self,
            didReceiveSummary: summary
        )
        log(message: "Exposure detection finished with summary: \(summary.pretty)")
        updateRiskView()

        self.transaction = nil
    }

    func exposureDetectionTransaction(
        _ transaction: ExposureDetectionTransaction,
        didEndPrematurely reason: ExposureDetectionTransaction.DidEndPrematurelyReason
    ) {
        logError(message: "Exposure transaction failed: \(reason)")
        self.transaction = nil
    }

    func exposureDetectionTransaction(
        _ transaction: ExposureDetectionTransaction,
        continueWithExposureManager: @escaping ContinueHandler,
        abort: @escaping AbortHandler
    ) {
        // Important:
        // See HomeViewController for more details as to why we create a new manager here.

        let manager = ENAExposureManager()
        manager.activate { error in
            if let error = error {
                let message = "Unable to detect exposures because exposure manager could not be activated due to: \(error)"
                logError(message: message)
                manager.invalidate()
                abort(error)
                // TODO: We should defer abort(…) until the invalidation handler has been called.
                return
            }
            continueWithExposureManager(manager)
        }
    }

    func exposureDetectionTransactionRequiresFormattedToday(
        _ transaction: ExposureDetectionTransaction
    ) -> String {
        .formattedToday()
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
        let title: String = self.title(for: RiskLevel(riskScore: maximumRiskScore) ?? .unknown)
        string.append(NSAttributedString(string: "\n\(title)", attributes: attributes))
        string.append(NSAttributedString(string: "\n\n\n\(daysSinceLastExposure) Tage seit Kontakt", attributes: attributes))
        string.append(NSAttributedString(string: "\n\(matchedKeyCount) Kontakte\n\n", attributes: attributes))
        string.append(NSAttributedString(string: "\n Max Risk Score:\(maximumRiskScore)", attributes: attributes))
        return string

    }

    func title(for riskLevel: RiskLevel) -> String {
        let key: String
        switch riskLevel {
        case .unknown:
            key = AppStrings.Home.riskCardUnknownTitle
        case .inactive:
            key = AppStrings.Home.riskCardInactiveTitle
        case .low:
            key = AppStrings.Home.riskCardLowTitle
        case .high:
            key = AppStrings.Home.riskCardHighTitle
        }
        return key
    }

}

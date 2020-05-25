//
//  ExposureDetectionViewController.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 15.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit
import ExposureNotification


class ExposureDetectionViewController: DynamicTableViewController {
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!


    // MARK: Creating an Exposure Detection View Controller

    init?(
        coder: NSCoder,
        store: Store,
        client: Client,
        keyPackagesStore: DownloadedPackagesStore,
        exposureManager: ExposureManager
    ) {
        self.store = store
        self.client = client
        self.keyPackagesStore = keyPackagesStore
        self.exposureManager = exposureManager

        state = ExposureDetectionViewControllerState()

        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has intentionally not been implemented")
    }


    // MARK: Properties

    let store: Store
    let client: Client
    let keyPackagesStore: DownloadedPackagesStore
    let exposureManager: ExposureManager

    private var exposureDetectionTransaction: ExposureDetectionTransaction?

    private weak var refreshTimer: Timer?

    var state: ExposureDetectionViewControllerState
}


extension ExposureDetectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        checkButton.setTitle(AppStrings.ExposureDetection.checkNow, for: .normal)

        updateRiskLevel(riskLevel: .unknown)
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate() ; return }

            let indexPath = IndexPath(row: self.dynamicTableViewModel.numberOfRows(inSection: 0) - 1, section: 0)

            if let cell = self.tableView.cellForRow(at: indexPath) {
                self.dynamicTableViewModel.cell(at: indexPath).configure(cell: cell, at: indexPath)
            }
        }
    }


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        refreshTimer?.invalidate()
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        (cell as? DynamicTypeTableViewCell)?.backgroundColor = .clear

        return cell
    }
}


private extension ExposureDetectionViewController {
    @IBAction func tappedClose() {
        self.dismiss(animated: true)
    }


    @IBAction func tappedCheckNow() {
        log(message: "Starting exposure detection ...")
        self.exposureDetectionTransaction = ExposureDetectionTransaction(delegate: self, client: self.client, keyPackagesStore: self.keyPackagesStore)
        self.exposureDetectionTransaction?.start()
    }


    func updateRiskLevel(riskLevel: RiskLevel) {
        self.state.riskLevel = riskLevel

        self.titleView.backgroundColor = state.riskTintColor
        self.titleLabel.text = state.riskText
        self.titleLabel.textColor = state.riskContrastColor

        self.dynamicTableViewModel = self.dynamicTableViewModel(for: riskLevel, isTracingEnabled: state.isTracingEnabled)

        self.tableView.reloadData()
    }
}


extension ExposureDetectionViewController: ViewControllerUpdatable {
    func updateUI() {
        tableView.reloadData()
    }
}


extension ExposureDetectionViewController: ExposureDetectionTransactionDelegate {
    func exposureDetectionTransactionRequiresExposureManager(
        _ transaction: ExposureDetectionTransaction
    ) -> ExposureManager {
        exposureManager
    }

    func exposureDetectionTransaction(_ transaction: ExposureDetectionTransaction, didEndPrematurely reason: ExposureDetectionTransaction.DidEndPrematurelyReason) {
        // TODO show error to user
        logError(message: "Exposure transaction failed: \(reason)")
        self.exposureDetectionTransaction = nil
    }

    func exposureDetectionTransaction(
        _ transaction: ExposureDetectionTransaction,
        didDetectSummary summary: ENExposureDetectionSummary
    ) {
        self.exposureDetectionTransaction = nil

        self.store.dateLastExposureDetection = Date()

        self.state.summary = summary

        self.updateRiskLevel(riskLevel: RiskLevel(riskScore: summary.maximumRiskScore) ?? .unknown)

        // Temporarily trigger exposure detection summary notification locally until implemented by transaction flow
        NotificationCenter.default.post(name: .didDetectExposureDetectionSummary, object: nil, userInfo: ["summary": summary])
    }

    func exposureDetectionTransactionRequiresFormattedToday(_ transaction: ExposureDetectionTransaction) -> String {
        return .formattedToday()
    }
}

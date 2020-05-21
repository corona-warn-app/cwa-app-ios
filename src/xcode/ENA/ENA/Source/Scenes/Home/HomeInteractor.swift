//
//  HomeInteractor.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import ExposureNotification

final class HomeInteractor {

    // MARK: Creating
    
    init(
        homeViewController: HomeViewController,
        exposureManager: ExposureManager,
        client: Client,
        store: Store
    ) {
        self.homeViewController = homeViewController
        self.exposureManager = exposureManager
        self.client = client
        self.store = store
    }

    // MARK: Properties
    
    private unowned var homeViewController: HomeViewController
    private let store: Store
    var detectionSummary: ENExposureDetectionSummary?
    private(set) var exposureManager: ExposureManager
    private let client: Client

    private lazy var developerMenu: DMDeveloperMenu = {
        DMDeveloperMenu(
            presentingViewController: homeViewController,
            client: client,
            store: store,
            exposureManager: exposureManager
        )
    }()

    func developerMenuEnableIfAllowed() {
        developerMenu.enableIfAllowed()
    }

    func cellConfigurators() -> [CollectionViewCellConfiguratorAny] {

        let activeConfigurator = HomeActivateCellConfigurator(isActivated: true)
        let date = store.dateLastExposureDetection

        let riskLevel: RiskLevel
        if let detectionSummary = detectionSummary, let rlevel = RiskLevel(riskScore: detectionSummary.maximumRiskScore) {
            riskLevel = rlevel
        } else {
            riskLevel = .unknown
        }
        let riskConfigurator = HomeRiskCellConfigurator(riskLevel: riskLevel, date: date)
        riskConfigurator.contactAction = { [unowned self] in
            self.homeViewController.showExposureDetection()
        }
        let submitConfigurator = HomeSubmitCellConfigurator()

        submitConfigurator.submitAction = { [unowned self] in
            self.homeViewController.showSubmitResult()
        }
        
		let configurators: [CollectionViewCellConfiguratorAny] = [
			activeConfigurator,
			riskConfigurator,
			submitConfigurator,
		]
        return configurators
    }
}

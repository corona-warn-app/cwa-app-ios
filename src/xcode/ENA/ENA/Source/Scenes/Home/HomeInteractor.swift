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
    private var detectionSummary: ENExposureDetectionSummary?
    private(set) var exposureManager: ExposureManager
    private let client: Client

    private lazy var developerMenu: DMDeveloperMenu = {
        DMDeveloperMenu(
            presentingViewController: homeViewController,
            client: client,
            store: store
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
        
		let info1Configurator = HomeInfoCellConfigurator(
			title: AppStrings.Home.infoCardShareTitle,
			body: AppStrings.Home.infoCardShareBody,
			position: .first,
			accessibilityIdentifier: Accessibility.Cell.infoCardShareTitle
		)
		let info2Configurator = HomeInfoCellConfigurator(
			title: AppStrings.Home.infoCardAboutTitle,
			body: AppStrings.Home.infoCardAboutBody,
			position: .last,
			accessibilityIdentifier: Accessibility.Cell.infoCardAboutTitle
		)

		let appInformationConfigurator = HomeInfoCellConfigurator(
			title: AppStrings.Home.appInformationCardTitle,
			body: nil,
			position: .first,
			accessibilityIdentifier: Accessibility.Cell.appInformationCardTitle
		)
		let settingsConfigurator = HomeInfoCellConfigurator(
			title: AppStrings.Home.settingsCardTitle,
			body: nil,
			position: .last,
			accessibilityIdentifier: Accessibility.Cell.settingsCardTitle
		)

		let configurators: [CollectionViewCellConfiguratorAny] = [
			activeConfigurator,
			riskConfigurator,
			submitConfigurator,
			info1Configurator,
			info2Configurator,
			appInformationConfigurator,
			settingsConfigurator
		]
        return configurators
    }
}

extension HomeInteractor: ExposureDetectionViewControllerDelegate {
    func exposureDetectionViewController(_ controller: ExposureDetectionViewController, didReceiveSummary summary: ENExposureDetectionSummary) {
        log(message: "got summary: \(summary.description)")
        detectionSummary = summary
        homeViewController.prepareData()
        homeViewController.reloadData()
    }
}

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
        DMDeveloperMenu(presentingViewController: homeViewController, client: client)
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
        // swiftlint:disable:next unowned_variable_capture
        riskConfigurator.contactAction = { [unowned self] in
            self.homeViewController.showExposureDetection()
        }
        let submitConfigurator = HomeSubmitCellConfigurator()

        // swiftlint:disable:next unowned_variable_capture
        submitConfigurator.submitAction = { [unowned self] in
            self.homeViewController.showSubmitResult()
        }
        let title1 = AppStrings.Home.infoCardShareTitle
        let body1 = AppStrings.Home.infoCardShareBody
        let info1Configurator = HomeInfoCellConfigurator(title: title1, body: body1)
        
		let title2 = AppStrings.Home.infoCardAboutTitle
        let body2 = AppStrings.Home.infoCardAboutBody
        let info2Configurator = HomeInfoCellConfigurator(title: title2, body: body2)
		info2Configurator.position = .last

		let appInformationConfigurator = HomeSettingsCellConfigurator(title: AppStrings.Home.appInformationCardTitle, position: .first)
		appInformationConfigurator.position = .first
        
		let settingsConfigurator = HomeSettingsCellConfigurator(title: AppStrings.Home.settingsCardTitle, position: .first)
		settingsConfigurator.position = .last

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

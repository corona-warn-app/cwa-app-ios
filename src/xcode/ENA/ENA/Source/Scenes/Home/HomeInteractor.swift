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
        self.cells = initialCellConfigurators()
    }

    // MARK: Properties
    
    private unowned var homeViewController: HomeViewController
    private let exposureManager: ExposureManager
    private let client: Client
    private let store: Store
    var detectionSummary: ENExposureDetectionSummary?

    private var cells: [CollectionViewCellConfiguratorAny] = []
    
    var cellConfigurators: [CollectionViewCellConfiguratorAny] {
        cells
    }
    
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

    private func riskCellTask(completion: (() -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            completion?()
        }
    }
    
    private func startCheckRisk() {
        isLoading.toggle()
        if isLoading {
            riskConfigurator.startLoading()
            homeViewController.reloadCell(at: 1)
        } else {
            riskConfigurator.stopLoading()
            homeViewController.reloadCell(at: 1)
        }
//        riskCellTask(completion: {
//            self.riskConfigurator.stopLoading()
//            self.homeViewController.reloadCell(at: 2)
//        })
    }
    
    var isLoading = false
    
    private var riskConfigurator: HomeRiskCellConfigurator!
    
    private func initialCellConfigurators() -> [CollectionViewCellConfiguratorAny] {

        let activeConfigurator = HomeActivateCellConfigurator(isActivated: true)
        let date = store.dateLastExposureDetection

        let riskLevel: RiskLevel
        if let detectionSummary = detectionSummary, let rlevel = RiskLevel(riskScore: detectionSummary.maximumRiskScore) {
            riskLevel = rlevel
        } else {
            riskLevel = .unknown
        }
        riskConfigurator = HomeRiskCellConfigurator(riskLevel: riskLevel, lastUpdateDate: date, numberRiskContacts: 2, lastContactDate: Date(), isLoading: isLoading)
        riskConfigurator.contactAction = { [unowned self] in
            self.startCheckRisk()
        }
        let submitConfigurator = HomeSubmitCellConfigurator()

        submitConfigurator.submitAction = { [unowned self] in
            self.homeViewController.showSubmitResult()
        }
        
		let info1Configurator = HomeInfoCellConfigurator(
			title: AppStrings.Home.infoCardShareTitle,
			body: AppStrings.Home.infoCardShareBody,
			position: .first
		)
		let info2Configurator = HomeInfoCellConfigurator(
			title: AppStrings.Home.infoCardAboutTitle,
			body: AppStrings.Home.infoCardAboutBody,
			position: .last
		)

		let appInformationConfigurator = HomeInfoCellConfigurator(
			title: AppStrings.Home.appInformationCardTitle,
			body: nil,
			position: .first
		)
		let settingsConfigurator = HomeInfoCellConfigurator(
			title: AppStrings.Home.settingsCardTitle,
			body: nil,
			position: .last
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

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

    private var activeConfigurator: HomeActivateCellConfigurator!
    private var cells: [CollectionViewCellConfiguratorAny] = []
    var cellConfigurators: [CollectionViewCellConfiguratorAny] { cells }
    private var riskConfigurator: HomeRiskCellConfigurator?
    
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


    
    private func riskCellTask(completion: (() -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            completion?()
        }
    }
    
    private func startCheckRisk() {
        guard let indexPath = indexPathForRiskCell() else { return }
        riskConfigurator?.startLoading()
        homeViewController.reloadCell(at: indexPath)
        riskCellTask(completion: {
            self.riskConfigurator?.stopLoading()
            guard let indexPath = self.indexPathForRiskCell() else { return }
            self.homeViewController.reloadCell(at: indexPath)
        })
    }
    
    private func indexPathForRiskCell() -> IndexPath? {
        let index = cells.firstIndex { cellConfigurator in
            cellConfigurator === self.riskConfigurator
        }
        guard let item = index else { return nil }
        let indexPath = IndexPath(item: item, section: HomeViewController.Section.actions.rawValue)
        return indexPath
    }
    
    func updateActiveCell() {
        guard let indexPath = indexPathForActiveCell() else { return }
        let exposureManagerEnabled = homeViewController.exposureManagerEnabled
        activeConfigurator.setActivate(isActivated: exposureManagerEnabled)
        homeViewController.reloadCell(at: indexPath)
    }
    
    private func indexPathForActiveCell() -> IndexPath? {
        let index = cells.firstIndex { cellConfigurator in
            cellConfigurator === self.activeConfigurator
        }
        guard let item = index else { return nil }
        let indexPath = IndexPath(item: item, section: HomeViewController.Section.actions.rawValue)
        return indexPath
    }
    
    private func initialCellConfigurators() -> [CollectionViewCellConfiguratorAny] {
        
        let exposureManagerEnabled = homeViewController.exposureManagerEnabled
        activeConfigurator = HomeActivateCellConfigurator(isActivated: exposureManagerEnabled)
        let date = store.dateLastExposureDetection

        let riskLevel: RiskLevel
        if let detectionSummary = detectionSummary, let rlevel = RiskLevel(riskScore: detectionSummary.maximumRiskScore) {
            riskLevel = rlevel
        } else {
            riskLevel = .unknown
        }
        riskConfigurator = HomeRiskCellConfigurator(riskLevel: riskLevel, lastUpdateDate: date, numberRiskContacts: 2, lastContactDate: Date(), isLoading: false)
        riskConfigurator?.contactAction = { [unowned self] in
            self.startCheckRisk()
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

		var configurators: [CollectionViewCellConfiguratorAny] = [activeConfigurator]
        if let risk = riskConfigurator {
            configurators.append(risk)
        }
        let others: [CollectionViewCellConfiguratorAny] = [
			submitConfigurator,
			info1Configurator,
			info2Configurator,
			appInformationConfigurator,
			settingsConfigurator
		]
        configurators.append(contentsOf: others)
        return configurators
    }
}

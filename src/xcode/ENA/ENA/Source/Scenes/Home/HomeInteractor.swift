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
    
    private unowned var homeViewController: HomeViewController
    private let persistenceManager = PersistenceManager.shared
    private var detectionSummary: ENExposureDetectionSummary?
    private(set) var exposureManager: ExposureManager
    
    private(set) var client: Client = {
        let fileManager = FileManager.default
        let documentDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileUrl = documentDir.appendingPathComponent("keys", isDirectory: false).appendingPathExtension("proto")
        return MockClient(submittedKeysFileURL: fileUrl)
    }()
    
    private lazy var developerMenu: DMDeveloperMenu = {
        DMDeveloperMenu(presentingViewController: homeViewController, client: client)
    }()
    
    init(homeViewController: HomeViewController, exposureManager: ExposureManager) {
        self.homeViewController = homeViewController
        self.exposureManager = exposureManager
    }
    
    func developerMenuEnableIfAllowed() {
        developerMenu.enableIfAllowed()
    }
    
    func cellConfigurators() -> [CollectionViewCellConfiguratorAny] {
        let activeConfigurator = HomeActivateCellConfigurator()
        let date = persistenceManager.dateLastExposureDetection
        let riskLevel: RiskLevel
        if let detectionSummary = detectionSummary {
            riskLevel = RiskLevel(riskScore: detectionSummary.maximumRiskScore)
        } else {
            riskLevel = .unknown
        }
        let riskConfigurator = HomeRiskCellConfigurator(riskLevel: riskLevel, date: date)
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
        let settingsConfigurator = HomeSettingsCellConfigurator()
        let configurators: [CollectionViewCellConfiguratorAny] = [activeConfigurator, riskConfigurator, submitConfigurator, info1Configurator, info2Configurator, settingsConfigurator]
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

//
//  HomeInteractor.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

final class HomeInteractor {
    
    private unowned var homeViewController: HomeViewController
    
    private let persistenceManager = PersistenceManager.shared
    
    init(homeViewController: HomeViewController) {
        self.homeViewController = homeViewController
    }
    
    func cellConfigurators() -> [CollectionViewCellConfiguratorAny] {
        let activeConfigurator = HomeActivateCellConfigurator()
        let date = persistenceManager.dateLastExposureDetection

        let riskConfigurator = HomeRiskCellConfigurator(homeViewController: homeViewController, date: date)
        riskConfigurator.contactAction = { [unowned self] in
            self.homeViewController.showExposureDetection()
        }
        let submitConfigurator = HomeSubmitCellConfigurator()
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

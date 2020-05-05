//
//  HomeInteractor.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

class HomeInteractor {
    
    unowned var homeViewController: HomeViewController
    
    init(homeViewController: HomeViewController) {
        self.homeViewController = homeViewController
    }
    
    func cellConfigurators() -> [CollectionViewCellConfiguratorAny] {
        let activeConfigurator = HomeActivateCellConfigurator()
        let riskConfigurator = HomeRiskCellConfigurator()
        riskConfigurator.contactAction = { [unowned self] in
            self.homeViewController.showExposureDetection()
        }
        let submitConfigurator = HomeSubmitCellConfigurator()
        submitConfigurator.submitAction = { [unowned self] in
            self.homeViewController.showSubmitResult()
        }
        let title1 = NSLocalizedString("home_info_card_share_title", comment: "")
        let body1 = NSLocalizedString("home_info_card_share_body", comment: "")
        let info1Configurator = HomeInfoCellConfigurator(title: title1, body: body1)
        let title2 = NSLocalizedString("home_info_card_about_title", comment: "")
        let body2 = NSLocalizedString("home_info_card_about_body", comment: "")
        let info2Configurator = HomeInfoCellConfigurator(title: title2, body: body2)
        let settingsConfigurator = HomeSettingsCellConfigurator()
        let configurators: [CollectionViewCellConfiguratorAny] = [activeConfigurator, riskConfigurator, submitConfigurator, info1Configurator, info2Configurator, settingsConfigurator]
        return configurators
    }
}

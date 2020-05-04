//
//  HomeInteractor.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 04.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

struct HomeInteractor {
    func cellConfigurators() -> [CollectionViewCellConfiguratorAny] {
        let activeConfigurator = HomeActivateCellConfigurator()
        let riskConfigurator = HomeRiskCellConfigurator()
        let submitConfigurator = HomeSubmitCellConfigurator()
        let info1Configurator = HomeInfoCellConfigurator(title: "Teilen Sie die App", body: "Laden Sie Andere zum Mitmachen ein, denn zusammen sind wir stärker.")
        let info2Configurator = HomeInfoCellConfigurator(title: "Über COVID-19 informieren", body: "Finden Sie verlässliche Antworten und konkrete informationen, wie Sie sich schützen und anderen helfen können")
        let settingsConfigurator = HomeSettingsCellConfigurator()
        let configurators: [CollectionViewCellConfiguratorAny] = [activeConfigurator, riskConfigurator, submitConfigurator, info1Configurator, info2Configurator, settingsConfigurator]
        return configurators
    }
}

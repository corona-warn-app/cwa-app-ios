//
// Created by Hu, Hao on 07.06.20.
// Copyright (c) 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit

protocol RequiresAppDependencies {
	var client: Client { get }
	var store: Store { get }
	var taskScheduler: ENATaskScheduler { get }
	var downloadedPackagesStore: DownloadedPackagesStore { get }
	var riskProvider: RiskProvider { get }
	var exposureManager: ExposureManager { get }
	var lastRiskCalculation: String { get }  // TODO: REMOVE ME
}

extension RequiresAppDependencies {
	var client: Client {
		UIApplication.coronaWarnDelegate().client
	}

	var downloadedPackagesStore: DownloadedPackagesStore {
		UIApplication.coronaWarnDelegate().downloadedPackagesStore
	}

	var store: Store {
		UIApplication.coronaWarnDelegate().store
	}

	var taskScheduler: ENATaskScheduler {
		UIApplication.coronaWarnDelegate().taskScheduler
	}

	var riskProvider: RiskProvider {
		UIApplication.coronaWarnDelegate().riskProvider
	}

	var lastRiskCalculation: String {
		UIApplication.coronaWarnDelegate().lastRiskCalculation
	}

	var exposureManager: ExposureManager {
		UIApplication.coronaWarnDelegate().exposureManager
	}
}
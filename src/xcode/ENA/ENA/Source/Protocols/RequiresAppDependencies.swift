//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

typealias DownloadedPackagesStore = DownloadedPackagesStoreV3
typealias DownloadedPackagesSQLLiteStore = DownloadedPackagesSQLLiteStoreV3

protocol RequiresAppDependencies {
	var client: HTTPClient { get }
	var wifiClient: WifiOnlyHTTPClient { get }
	var store: Store { get }
	var taskScheduler: ENATaskScheduler { get }
	var downloadedPackagesStore: DownloadedPackagesStore { get }
	var appConfigurationProvider: AppConfigurationProviding { get }
	var riskProvider: RiskProviding { get }
	var exposureManager: ExposureManager { get }
}

extension RequiresAppDependencies {
	var client: HTTPClient {
		UIApplication.coronaWarnDelegate().client
	}

	var wifiClient: WifiOnlyHTTPClient {
		UIApplication.coronaWarnDelegate().wifiClient
	}

	var downloadedPackagesStore: DownloadedPackagesStore {
		UIApplication.coronaWarnDelegate().downloadedPackagesStore
	}

	var store: Store {
		UIApplication.coronaWarnDelegate().store
	}

	var appConfigurationProvider: AppConfigurationProviding {
		UIApplication.coronaWarnDelegate().appConfigurationProvider
	}

	var riskProvider: RiskProviding {
		UIApplication.coronaWarnDelegate().riskProvider
	}

	var exposureManager: ExposureManager {
		UIApplication.coronaWarnDelegate().exposureManager
	}

	var taskScheduler: ENATaskScheduler {
		UIApplication.coronaWarnDelegate().taskScheduler
	}
}

private extension UIApplication {
	class func coronaWarnDelegate() -> CoronaWarnAppDelegate {
		// Normally there should be an AppDelegate, but not for unit tests (see `main.swift`)
		// In that case we use a blank app delegate
		shared.delegate as? CoronaWarnAppDelegate ?? AppDelegate()
	}
}

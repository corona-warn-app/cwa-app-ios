// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.


import Foundation
import UIKit

typealias DownloadedPackagesStore = DownloadedPackagesStoreV2
typealias DownloadedPackagesSQLLiteStore = DownloadedPackagesSQLLiteStoreV2

protocol RequiresAppDependencies {
	var client: HTTPClient { get }
	var wifiClient: WifiOnlyHTTPClient { get }
	var store: Store { get }
	var taskScheduler: ENATaskScheduler { get }
	var downloadedPackagesStore: DownloadedPackagesStore { get }
	var appConfigurationProvider: AppConfigurationProviding { get }
	var riskProvider: RiskProviding { get }
	var exposureManager: ExposureManager { get }
	var serverEnvironment: ServerEnvironment { get }
	var warnOthersReminder: WarnOthersRemindable { get }
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

	var serverEnvironment: ServerEnvironment {
		UIApplication.coronaWarnDelegate().serverEnvironment
	}
	
	var warnOthersReminder: WarnOthersRemindable {
		UIApplication.coronaWarnDelegate().warnOthersReminder
	}
}

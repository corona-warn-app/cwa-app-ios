//
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
//

import Foundation

struct ENSettingEuTracingViewModel {
	
	let title: String
	
	let countryListLabel: String
	
	let allCountriesEnbledStateLabel: String
	
	init(euTracingSettings: EUTracingSettings) {
		self.title = AppStrings.ExposureNotificationSetting.euTracingAllCountriesTitle
		
		var enabledCountries: String {
			guard !euTracingSettings.enabledCountries.isEmpty else { return "" }
			return euTracingSettings.enabledCountries
				.compactMap( {Country(countryCode: $0)?.localizedName} )
				.joined(separator: ", ")
			}
		
		self.countryListLabel = enabledCountries
		
		self.allCountriesEnbledStateLabel = euTracingSettings.isAllCountriesEnbled ? AppStrings.ExposureNotificationSetting.euTracingAllCountriesStatusOnLabel : AppStrings.ExposureNotificationSetting.euTracingAllCountrieStatusOffLabel
	}
}

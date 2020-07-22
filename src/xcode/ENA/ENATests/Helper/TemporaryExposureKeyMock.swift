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
import ExposureNotification

final class TemporaryExposureKeyMock: ENTemporaryExposureKey {
	init(
		keyData: Data = Data(),
		rollingPeriod: ENIntervalNumber = 0,
		rollingStartNumber: ENIntervalNumber = 0,
		transmissionRiskLevel: ENRiskLevel = 0
	) {
		_keyData = keyData
		_rollingPeriod = rollingPeriod
		_rollingStartNumber = rollingStartNumber
		_transmissionRiskLevel = transmissionRiskLevel
		super.init()
	}

	var _keyData: Data
	override var keyData: Data {
		get { _keyData }
		set { _keyData = newValue }
	}

	var _rollingPeriod: ENIntervalNumber
	override var rollingPeriod: ENIntervalNumber {
		get { _rollingPeriod }
		set { _rollingPeriod = newValue }
	}

	var _rollingStartNumber: ENIntervalNumber
	override var rollingStartNumber: ENIntervalNumber {
		get { _rollingStartNumber }
		set { _rollingStartNumber = newValue }
	}

	var _transmissionRiskLevel: ENRiskLevel
	override var transmissionRiskLevel: ENRiskLevel {
		get { _transmissionRiskLevel }
		set { _transmissionRiskLevel = newValue }
	}

	override func isEqual(_ object: Any?) -> Bool {
		guard let other = object as? ENTemporaryExposureKey else {
			return false
		}

		guard
			keyData == other.keyData,
			rollingPeriod == other.rollingPeriod,
			rollingStartNumber == other.rollingStartNumber,
			transmissionRiskLevel == other.transmissionRiskLevel
		else {
			return false
		}

		return true
	}
}

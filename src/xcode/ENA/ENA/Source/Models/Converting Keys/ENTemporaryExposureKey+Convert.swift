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

import ExposureNotification

extension ENTemporaryExposureKey {
	var sapKey: SAP_TemporaryExposureKey {
		SAP_TemporaryExposureKey.with {
			$0.keyData = self.keyData
			$0.rollingPeriod = Int32(self.rollingPeriod)
			$0.rollingStartIntervalNumber = Int32(self.rollingStartNumber)
			$0.transmissionRiskLevel = Int32(self.transmissionRiskLevel)
		}
	}
}

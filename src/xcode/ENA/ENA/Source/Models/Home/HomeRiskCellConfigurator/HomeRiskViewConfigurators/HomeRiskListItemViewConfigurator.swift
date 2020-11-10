//
// Corona-Warn-App
//
// SAP SE and all other contributors /
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

import UIKit

final class HomeRiskListItemViewConfigurator: HomeRiskViewConfigurator {
	var text: String
	var textColor: UIColor


	init(text: String, titleColor: UIColor) {
		self.text = text
		self.textColor = titleColor
	}

	func configure(riskView: RiskListItemView) {
		riskView.textLabel?.text = text
		riskView.textLabel?.textColor = textColor

		riskView.dotLabel?.text = "•"
		riskView.dotLabel?.textColor = textColor

	}
}

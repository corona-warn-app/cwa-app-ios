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

import UIKit

final class HomeRiskLoadingItemViewConfigurator: HomeRiskViewConfigurator {

	var title: String
	var titleColor: UIColor
	var isLoading: Bool
	var color: UIColor
	var separatorColor: UIColor

	init(title: String, titleColor: UIColor, isLoading: Bool, color: UIColor, separatorColor: UIColor) {
		self.title = title
		self.titleColor = titleColor
		self.isLoading = isLoading
		self.color = color
		self.separatorColor = separatorColor
	}

	func configure(riskView: RiskLoadingItemView) {
		let iconTintColor = titleColor
		riskView.activityIndicatorView.color = iconTintColor
		riskView.textLabel?.text = title
		riskView.textLabel?.textColor = titleColor
		riskView.separatorView?.backgroundColor = separatorColor
		if isLoading {
			riskView.activityIndicatorView.startAnimating()
		} else {
			riskView.activityIndicatorView.stopAnimating()
		}
		riskView.backgroundColor = color
	}
}

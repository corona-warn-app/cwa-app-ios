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

protocol HomeRiskViewConfiguratorAny {
	var viewAnyType: UIView.Type { get }

	func configureAny(riskView: UIView)
}

protocol HomeRiskViewConfigurator: HomeRiskViewConfiguratorAny {
	associatedtype ViewType: UIView
	func configure(riskView: ViewType)
}

extension HomeRiskViewConfigurator {
	var viewAnyType: UIView.Type {
		ViewType.self
	}

	func configureAny(riskView: UIView) {
		if let riskView = riskView as? ViewType {
			configure(riskView: riskView)
		} else {
			let error = "\(riskView) isn't conformed ViewType"
			logError(message: error)
			fatalError(error)
		}
	}
}

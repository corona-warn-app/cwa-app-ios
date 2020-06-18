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

final class HomeActivateCellConfigurator: CollectionViewCellConfigurator {
	// MARK: Creating a Configurator
	init(state: ENStateHandler.State) {
		self.state = state
	}

	// MARK: Properties
	let identifier = UUID()
	private var state: ENStateHandler.State

	// MARK: Configuring a Cell
	func configure(cell: ActivateCollectionViewCell) {
		cell.iconImageView.image = state.homeActivateCellIcon.withRenderingMode(.alwaysTemplate)
		cell.titleLabel.text = state.homeActivateTitle
		cell.accessibilityIdentifier = state.homeActivateAccessibilityIdentifier
		cell.accessibilityLabel = cell.titleLabel.text ?? ""
	}
}

extension HomeActivateCellConfigurator: ENStateHandlerUpdating {
	func updateEnState(_ state: ENStateHandler.State) {
		self.state = state
	}
}

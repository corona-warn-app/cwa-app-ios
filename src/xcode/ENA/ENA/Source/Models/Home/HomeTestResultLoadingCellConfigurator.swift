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

class HomeTestResultLoadingCellConfigurator: CollectionViewCellConfigurator {

	func configure(cell: HomeTestResultLoadingCell) {
		cell.setupCell()
		cell.title.text = AppStrings.Home.resultCardLoadingTitle
		cell.body.text = AppStrings.Home.resultCardLoadingBody
		cell.button.isEnabled = false
		cell.button.setTitle(AppStrings.Home.resultCardShowResultButton, for: .disabled)
	}

	// MARK: Hashable

	func hash(into hasher: inout Swift.Hasher) {
		// this class has no stored properties, that's why hash function is empty here
	}

	static func == (lhs: HomeTestResultLoadingCellConfigurator, rhs: HomeTestResultLoadingCellConfigurator) -> Bool {
		// instances of this class have no differences between each other
		true
	}
}

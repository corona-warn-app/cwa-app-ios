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

import UIKit

final class LogoBarButtonItem: UIBarButtonItem {
	override init() {
		super.init()
		customView = UIImageView(image: .coronaWarnLogo())
		isAccessibilityElement = true
		accessibilityTraits = .none
		accessibilityLabel = AppStrings.Home.leftBarButtonDescription
		accessibilityIdentifier = AccessibilityIdentifiers.Home.leftBarButtonDescription
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}
}

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

#if DEBUG

extension UIAlertController {
	func applyAccessibilityIdentifiers() {
		for action in actions {
			let label = action.value(forKey: "__representer")
			let view = label as? UIView
			view?.accessibilityIdentifier = action.getAcAccessibilityIdentifier()
		}
	}
}

extension UIAlertAction {
	// swiftlint:disbale:next convenience_type
	private enum AssociatedKeys {
		static var AccessabilityIdentifier = "UITestAccesabilityIdentifier"
	}

	func setAccessibilityIdentifier(accessabilityIdentifier: String) {
		objc_setAssociatedObject(self, &AssociatedKeys.AccessabilityIdentifier, accessabilityIdentifier, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
	}

	func getAcAccessibilityIdentifier() -> String? {
		return objc_getAssociatedObject(self, &AssociatedKeys.AccessabilityIdentifier) as? String
	}
}
#endif

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

import Foundation
import UIKit

protocol SegueIdentifiers {
	var rawValue: String { get }

	init?(rawValue: String)
	init?(_ string: String)
	init?(_ segue: UIStoryboardSegue)
}

extension SegueIdentifiers {
	init?(_ string: String) {
		self.init(rawValue: string)
	}

	init?(_ segue: UIStoryboardSegue) {
		if let identifier = segue.identifier {
			self.init(identifier)
		} else {
			return nil
		}
	}
}

extension UIViewController {
	typealias SegueIdentifier = SegueIdentifiers

	func performSegue(withIdentifier identifier: SegueIdentifier, sender: Any?) {
		performSegue(withIdentifier: identifier.rawValue, sender: sender)
	}
}

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

import Foundation
import UIKit

class DynamicTableViewSpaceCell: UITableViewCell {
	private lazy var heightConstraint: NSLayoutConstraint = self.contentView.heightAnchor.constraint(equalToConstant: 0)

	var height: CGFloat {
		set {
			if newValue == UITableView.automaticDimension {
				heightConstraint.isActive = false
			} else {
				if newValue <= 0 {
					heightConstraint.constant = .leastNonzeroMagnitude
				} else {
					heightConstraint.constant = newValue
				}
				heightConstraint.isActive = true
			}
		}
		get { heightConstraint.isActive ? heightConstraint.constant : UITableView.automaticDimension }
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		height = UITableView.automaticDimension
		backgroundColor = nil
	}

	override func accessibilityElementCount() -> Int { 0 }

}

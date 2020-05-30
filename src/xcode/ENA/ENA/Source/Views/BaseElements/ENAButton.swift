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

/// A Button which has the same behavior of UIButton, but with different tint color.
@IBDesignable
class ENAButton: UIButton {
	override init(frame: CGRect) {
		super.init(frame: frame)
		customizeButton()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		customizeButton()
	}
	
	override var isEnabled: Bool {
		didSet {
			if isEnabled {
				backgroundColor = UIColor.preferredColor(for: .tint)
			} else {
				backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
			}
		}
	}
	
	private func customizeButton() {
		setButtonColors()
		setRoundCorner(radius: 8.0)
		
		contentEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
		heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
		
		titleLabel?.adjustsFontForContentSizeCategory = true
	}
	
	private func setButtonColors() {
		backgroundColor = UIColor.preferredColor(for: .tint)
		setTitleColor(UIColor.white, for: .normal)
		setTitleColor(UIColor.systemGray, for: .disabled)
	}
	
	private func setRoundCorner(radius: CGFloat) {
		layer.cornerRadius = radius
		layer.cornerCurve = .continuous
		clipsToBounds = true
	}
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		customizeButton()
	}
}

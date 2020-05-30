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

extension UIView {
	func setBorder(at edges: [UIRectEdge], with color: UIColor, thickness: CGFloat, and inset: UIEdgeInsets = .zero) {
		if edges.contains(.all) {
			addBorder(at: .bottom, with: color, thickness: thickness, and: inset)
			addBorder(at: .left, with: color, thickness: thickness, and: inset)
			addBorder(at: .right, with: color, thickness: thickness, and: inset)
			addBorder(at: .top, with: color, thickness: thickness, and: inset)
			return
		}
		for rectEdge in edges {
			if edges.contains(rectEdge) {
				addBorder(at: rectEdge, with: color, thickness: thickness, and: inset)
			}
		}
	}
	
	// Use additional view in order to set constraints for border layer
	private func addBorder(at edge: UIRectEdge, with color: UIColor, thickness: CGFloat, and inset: UIEdgeInsets) {
		let view = UIView()
		insertSubview(view, at: 0)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = color
		
		switch edge {
		case .top:
			view.topAnchor.constraint(equalTo: topAnchor, constant: inset.top).isActive = true
			view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset.left).isActive = true
			view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: inset.right).isActive = true
			view.heightAnchor.constraint(equalToConstant: thickness).isActive = true
		case .right:
			view.topAnchor.constraint(equalTo: topAnchor, constant: inset.top).isActive = true
			view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: inset.bottom).isActive = true
			view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: inset.right).isActive = true
			view.widthAnchor.constraint(equalToConstant: thickness).isActive = true
		case .bottom:
			view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: inset.bottom).isActive = true
			view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset.left).isActive = true
			view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: inset.right).isActive = true
			view.heightAnchor.constraint(equalToConstant: thickness).isActive = true
		case .left:
			view.topAnchor.constraint(equalTo: topAnchor, constant: inset.top).isActive = true
			view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: inset.bottom).isActive = true
			view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset.left).isActive = true
			view.widthAnchor.constraint(equalToConstant: thickness).isActive = true
		default:
			return
		}
	}
}

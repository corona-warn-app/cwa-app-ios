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

class PrivacyProtectionViewController: UIViewController {
	override func loadView() {
		view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .enaColor(for: .background)
		
		if let image = UIImage(named: "Illu_PrivacyProtection_Logo") {
			let imageView = UIImageView(image: image)
			imageView.translatesAutoresizingMaskIntoConstraints = false
			imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: image.size.width / image.size.height).isActive = true
			
			view.addSubview(imageView)
			view.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
			view.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
			view.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 375.0 / 100.0).isActive = true
		}
	}
	
	func show() {
		UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
			self.view.alpha = 1.0
		})
	}
	
	func hide(completion: (() -> Void)? = nil) {
		UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
			self.view.alpha = 0.0
		}, completion: { _ in
			completion?()
		})
	}
}

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
import UIKit

class ENAButtonFooterView: UIView {
	private(set) var primaryFooterButton: ENAButton!
	private(set) var secondaryFooterButton: ENAButton!

}


extension ENAButtonFooterView {
	private func setupFooterView() {
		primaryFooterButton = ENAButton(type: .custom)
		primaryFooterButton.setTitle("Primary Button", for: .normal)
		primaryFooterButton.addTarget(self, action: #selector(didTapPrimaryButton), for: .primaryActionTriggered)

		secondaryFooterButton = ENAButton(type: .custom)
		secondaryFooterButton.setTitle("Secondary Button", for: .normal)
		secondaryFooterButton.isTransparent = true
		primaryFooterButton.addTarget(self, action: #selector(didTapSecondaryButton), for: .primaryActionTriggered)

		footerButtonContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 300 + 2 * 16, height: 2 * 50 + 8 + 2 * 16))
		footerButtonContainerView.translatesAutoresizingMaskIntoConstraints = false
		footerButtonContainerView.insetsLayoutMarginsFromSafeArea = false
		footerButtonContainerView.preservesSuperviewLayoutMargins = false
		footerButtonContainerView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

		footerButtonContainerView.addSubview(primaryFooterButton)
		footerButtonContainerView.addSubview(secondaryFooterButton)

		primaryFooterButton.autoresizingMask = [.flexibleWidth]
		primaryFooterButton.frame = CGRect(x: 16, y: 16, width: 300, height: 50)

		secondaryFooterButton.autoresizingMask = [.flexibleWidth]
		secondaryFooterButton.frame = CGRect(x: 16, y: 16 + 50 + 8, width: 300, height: 50)

		footerView = ENAFooterView()
		footerView.isTranslucent = true
		footerView.translatesAutoresizingMaskIntoConstraints = false
		footerView.contentView.addSubview(footerButtonContainerView)
		footerView.contentView.topAnchor.constraint(equalTo: footerButtonContainerView.topAnchor).isActive = true
		footerView.contentView.leftAnchor.constraint(equalTo: footerButtonContainerView.leftAnchor).isActive = true
		footerView.contentView.rightAnchor.constraint(equalTo: footerButtonContainerView.rightAnchor).isActive = true

		view.addSubview(footerView)
		view.bottomAnchor.constraint(equalTo: footerView.bottomAnchor).isActive = true
		view.leftAnchor.constraint(equalTo: footerView.leftAnchor).isActive = true
		view.rightAnchor.constraint(equalTo: footerView.rightAnchor).isActive = true

		let safeAreaBottomConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: footerView.topAnchor)
		safeAreaBottomConstraint.priority = .defaultHigh
		safeAreaBottomConstraint.isActive = true
		footerViewTopConstraint = view.bottomAnchor.constraint(equalTo: footerView.topAnchor)
	}

	@objc
	private func didTapPrimaryButton() {
		topChildViewController?.didTapPrimaryButton(primaryFooterButton)
	}

	@objc
	private func didTapSecondaryButton() {
		topChildViewController?.didTapSecondaryButton(secondaryFooterButton)
	}
}

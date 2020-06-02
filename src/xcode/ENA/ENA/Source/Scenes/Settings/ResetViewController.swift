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

protocol ResetDelegate: AnyObject {
	func reset()
}

final class ResetViewController: UIViewController {
	@IBOutlet var header1Label: DynamicTypeLabel!
	@IBOutlet var description1TextView: UITextView!
	@IBOutlet var resetButton: ENAButton!
	@IBOutlet var discardResetButton: UIButton!
	@IBOutlet var infoTitleLabel: DynamicTypeLabel!
	@IBOutlet var infoDescriptionLabel: UILabel!
	@IBOutlet var infoView: UIView!

	weak var delegate: ResetDelegate?

	@IBAction func resetData(_: Any) {
		delegate?.reset()
	}

	override func viewDidLoad() {
		setupView()
	}

	@IBAction func discard(_: Any) {
		dismiss(animated: true, completion: nil)
	}

	override func traitCollectionDidChange(_: UITraitCollection?) {
		resetButton.sizeToFit()
		discardResetButton.sizeToFit()
	}

	private func setupView() {
		navigationItem.title = AppStrings.Reset.navigationBarTitle
		navigationController?.navigationBar.prefersLargeTitles = true

		description1TextView.contentInset = .zero
		description1TextView.textContainer.lineFragmentPadding = 0

		header1Label.text = AppStrings.Reset.header1
		description1TextView.text = AppStrings.Reset.description1
		resetButton.setTitle(AppStrings.Reset.resetButton, for: .normal)
		resetButton.titleLabel?.adjustsFontForContentSizeCategory = true
		resetButton.backgroundColor = UIColor.preferredColor(for: .brandRed)
		discardResetButton.setTitle(AppStrings.Reset.discardButton, for: .normal)
		discardResetButton.titleLabel?.adjustsFontForContentSizeCategory = true

		infoView.layer.cornerRadius = 14
		infoTitleLabel.text = AppStrings.Reset.infoTitle
		infoDescriptionLabel.text = AppStrings.Reset.infoDescription
	}
}

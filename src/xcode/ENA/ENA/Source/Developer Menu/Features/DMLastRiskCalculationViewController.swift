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

#if !RELEASE

import UIKit

/// A view controller that displays the last performed risk calculation details.
final class DMLastRiskCalculationViewController: UIViewController {
	// MARK: Creating a last risk calculcation view controller
	init(lastRisk: String?) {
		self.lastRisk = lastRisk
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: UIViewController
	override func loadView() {
		view = textView
		view.backgroundColor = .white
	}

	override func viewWillAppear(_ animated: Bool) {
		textView.attributedText = NSAttributedString(string: lastRisk ?? "")
		navigationController?.setToolbarHidden(false, animated: animated)
		let exportItem = UIBarButtonItem(
			title: "Export",
			style: .plain,
			target: self,
			action: #selector(exportRiskCalculation)
		)
		exportItem.isEnabled = lastRisk != nil
		setToolbarItems(
			[

				UIBarButtonItem(
					barButtonSystemItem: .flexibleSpace,
					target: nil,
					action: nil
				),
				exportItem,
				UIBarButtonItem(
					barButtonSystemItem: .flexibleSpace,
					target: nil,
					action: nil
				)
			],
			animated: animated
		)
		super.viewWillAppear(animated)
	}

	// MARK: Properties
	private let lastRisk: String?
	/// A text view displaying the last risk calculation.
	private let textView = UITextView()

	@objc
	func exportRiskCalculation() {
		let activityViewController = UIActivityViewController(activityItems: [lastRisk ?? ""], applicationActivities: nil)
		activityViewController.modalTransitionStyle = .coverVertical
		present(activityViewController, animated: true, completion: nil)
	}
}

#endif

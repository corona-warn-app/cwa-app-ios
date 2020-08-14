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

/// A view controller that displays all errors that are usually logged via `logError(…)`.
final class DMErrorsViewController: UIViewController {
	// MARK: Creating an Errors View Controller
	init() {
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
		textView.attributedText = NSAttributedString(string: errorMessages)

		navigationController?.setToolbarHidden(false, animated: animated)
		let exportItem = UIBarButtonItem(
			title: "Export",
			style: .plain,
			target: self,
			action: #selector(exportErrorLog)
		)

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
	/// Text view that displays the error messages.
	private let textView = UITextView()
	private var errorMessages: String {
		UserDefaults.standard.dmErrorMessages.map { "❌ \($0)" }.joined(separator: "\n\n\n")
	}

	// MAKR: Exporting the error messages
	@objc
	func exportErrorLog() {
		let activityViewController = UIActivityViewController(activityItems: [errorMessages], applicationActivities: nil)
		activityViewController.modalTransitionStyle = .coverVertical
		present(activityViewController, animated: true, completion: nil)
	}
}


#endif

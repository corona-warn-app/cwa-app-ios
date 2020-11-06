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

class DMDebugRiskCalculationViewController: UIViewController {

	// MARK: - Init

	init(store: Store) {
		self.store = store

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setUp()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.setToolbarHidden(false, animated: animated)

		let shareBarButtonItem = UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(didTapExportButton))

		setToolbarItems(
			[
				UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
				shareBarButtonItem,
				UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
			],
			animated: animated
		)
	}

	// MARK: - Private

	private let store: Store

	private let textView = UITextView()

	private func setUp() {
		title = "🐞🥊 🦠🧮"

		textView.isEditable = false

		view.addSubview(textView)
		textView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			view.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
			view.topAnchor.constraint(equalTo: textView.topAnchor),
			view.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
			view.bottomAnchor.constraint(equalTo: textView.bottomAnchor)
		])

		guard let mostRecentRiskCalculationConfiguration = store.mostRecentRiskCalculationConfiguration,
			  let mostRecentRiskCalculation = store.mostRecentRiskCalculation else {
			textView.text = "No risk calculation run yet."
			return
		}

		textView.text = "Most recent risk calculation: "

		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .short

		textView.text += dateFormatter.string(from: mostRecentRiskCalculation.calculationDate)

		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted

		textView.text += "\n\nConfiguration:\n\n"
		if let data = try? encoder.encode(mostRecentRiskCalculationConfiguration), let mostRecentRiskCalculationConfiguration = String(data: data, encoding: .utf8) {
			textView.text += mostRecentRiskCalculationConfiguration
		}

		textView.text += "\n\n\nValues:\n\n"
		if let data = try? encoder.encode(mostRecentRiskCalculation), let mostRecentRiskCalculation = String(data: data, encoding: .utf8) {
			textView.text += mostRecentRiskCalculation
		}
	}

	@objc
	private func didTapExportButton() {
		let activityViewController = UIActivityViewController(activityItems: [textView.text ?? ""], applicationActivities: nil)
		present(activityViewController, animated: true, completion: nil)
	}

}

#endif

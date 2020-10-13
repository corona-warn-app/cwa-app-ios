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
import os.log

private extension OSLogType {

	static var allCases: [OSLogType] {
		return [.error, .debug, .info, .default]
	}

	var index: Int {
		switch self {
		case .error:
			return 0
		case .debug:
			return 1
		case .info:
			return 2
		case .default:
			return 3
		default:
			return -1
		}
	}

	static func logType(for index: Int) -> OSLogType? {
		switch index {
		case 0:
			return .error
		case 1:
			return .debug
		case 2:
			return .info
		case 3:
			return .default
		default:
			return nil
		}
	}
}

/// A view controller that displays all logs that are usually logged via `Log.`.
final class DMLogsViewController: UIViewController {

	// MARK: Creating an Errors View Controller
	init() {
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .systemBackground
		textView.textColor = .label

		let segementedControlItems = OSLogType.allCases.map { $0.title }
		segmentedControl = UISegmentedControl(items: segementedControlItems)
		segmentedControl.selectedSegmentIndex = OSLogType.error.index
		updateTextView()
		segmentedControl.translatesAutoresizingMaskIntoConstraints = false
		segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)

		let stackView = UIStackView(arrangedSubviews: [segmentedControl, textView])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		view.addSubview(stackView)
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}

	override func viewWillAppear(_ animated: Bool) {
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

	private var segmentedControl: UISegmentedControl!

	private var selectedLogType: OSLogType {
		return OSLogType.logType(for: segmentedControl.selectedSegmentIndex) ?? .error
	}

	// MAKR: Exporting the error messages
	@objc
	func exportErrorLog() {
		let fileLogger = FileLogger()
		let logString = fileLogger.read(logType: selectedLogType)
		let activityViewController = UIActivityViewController(activityItems: [logString], applicationActivities: nil)
		activityViewController.modalTransitionStyle = .coverVertical
		present(activityViewController, animated: true, completion: nil)
	}

	@objc
	private func segmentedControlChanged() {
		updateTextView()
	}

	private func updateTextView() {
		let fileLogger = FileLogger()
		let logString = fileLogger.read(logType: selectedLogType)
		textView.text = logString
	}
}

#endif

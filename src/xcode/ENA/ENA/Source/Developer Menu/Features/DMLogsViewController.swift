//
// 🦠 Corona-Warn-App
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

		view.backgroundColor = ColorCompatibility.systemBackground
		textView.textColor = ColorCompatibility.label

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
		
		let deleteItem = UIBarButtonItem(
			title: "Delete Logs",
			style: .plain,
			target: self,
			action: #selector(deleteErrorLog)
		)
		deleteItem.tintColor = .red
		
		setToolbarItems(
			[
				exportItem,
				UIBarButtonItem(
					barButtonSystemItem: .flexibleSpace,
					target: nil,
					action: nil
				),
				deleteItem
			],
			animated: animated
		)
		super.viewWillAppear(animated)
	}

	// MARK: Properties
	/// Text view that displays the error messages.
	private let textView: UITextView = {
		let view = UITextView()
		view.isEditable = false
		view.textAlignment = .natural
		if #available(iOS 13.0, *) {
			view.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
		}
		return view
	}()

	private var segmentedControl: UISegmentedControl!

	private var selectedLogType: OSLogType {
		return OSLogType.logType(for: segmentedControl.selectedSegmentIndex) ?? .error
	}

	// MAKR: Exporting the error messages
	@objc
	func exportErrorLog() {
		let fileLogger = FileLogger()
		var logString = String()
		OSLogType.allCases.forEach { logString.append(fileLogger.read(logType: $0)) }
		let activityViewController = UIActivityViewController(activityItems: [logString], applicationActivities: nil)
		activityViewController.modalTransitionStyle = .coverVertical
		present(activityViewController, animated: true, completion: nil)
	}
	
	@objc
	func deleteErrorLog() {
		let alert = UIAlertController(title: "Logs", message: "Do you really want to delete ALL logs?", preferredStyle: .alert)
		
		let cancelAction = UIAlertAction(title: "No, i want to keep them", style: .cancel, handler: nil)
		alert.addAction(cancelAction)
		
		let deleteAction = UIAlertAction(title: "Yes, delete them ALL!", style: .destructive, handler: { [weak self] _ in
			let fileLogger = FileLogger()
			fileLogger.deleteLogs()
			self?.updateTextView()
		})
		alert.addAction(deleteAction)
		
		self.present(alert, animated: true, completion: nil)
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

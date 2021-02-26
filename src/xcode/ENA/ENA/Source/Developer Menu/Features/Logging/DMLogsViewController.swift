//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit
import os.log
import ZIPFoundation

enum LogSegment: Int, CaseIterable {
	case all
	case error
	case debug
	case info
	case warning

	var title: String {
		switch self {
		case .all:
			return "All"
		case .error:
			return "Error"
		case .debug:
			return "Debug"
		case .info:
			return "Info"
		case .warning:
			return "Warning"
		}
	}

	var osLogType: OSLogType? {
		switch self {
		case .all:
			return nil
		case .error:
			return .error
		case .debug:
			return .debug
		case .info:
			return .info
		case .warning:
			return .default
		}
	}
}

/// A view controller that displays all logs that are usually logged via `Log.`.
final class DMLogsViewController: UIViewController {

	// MARK: - Init

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = ColorCompatibility.systemBackground
		textView.textColor = ColorCompatibility.label

		let segementedControlItems = LogSegment.allCases.map { $0.title }
		segmentedControl = UISegmentedControl(items: segementedControlItems)
		segmentedControl.selectedSegmentIndex = 0
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
		updateTextView()

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

	// MARK: - Private

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

	@objc
	private func exportErrorLog() {
		let fileLogger = FileLogger()

		guard let item = LogDataItem(at: fileLogger.allLogsFileURL) else {
			Log.warning("No log data to export.", log: .localData)
			return
		}

		// Log.debug("Preparing log export. Log length, raw: \(rawData.count), compressed: \(archive.data?.count ?? 0)", log: .localData)
		// using archive data with the plain log string as fallback
		let activityViewController = UIActivityViewController(activityItems: [item], applicationActivities: nil)
		activityViewController.modalTransitionStyle = .coverVertical
		present(activityViewController, animated: true, completion: nil)
	}

	@objc
	private func deleteErrorLog() {
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
		guard let selectedSegment = LogSegment(rawValue: segmentedControl.selectedSegmentIndex) else {
			return
		}

		let fileLogger = FileLogger()
		let reader: StreamReader

		do {
			if let osLogType = selectedSegment.osLogType {
				reader = try fileLogger.logReader(for: osLogType)
			} else {
				reader = try fileLogger.logReader()
			}
			var text = ""
			while let line = reader.nextLine() {
				// why not `append`? https://twitter.com/nicklockwood/status/972215130825154561
				text += line
				text += "\n"
			}
			textView.text = text

			// Does NOT fully scroll to bottom. I assume it's because of the custom font size and the way UIKit calculates the contentOffset.
			// However I leave it in for two reasons:
			// 1. this view might get a refactoring later™ (https://jira-ibs.wbs.net.sap/browse/EXPOSUREAPP-5426)
			// 2. this is better than the current start at the top of a potentially very long log
			textView.scrollRangeToVisible(NSRange(location: textView.text.count - 1, length: 1))
		} catch {
			Log.error("Error while displaying logs: \(error)", log: .default, error: error)
		}
	}
}

#endif

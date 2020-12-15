//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

final class DMBackendConfigurationViewController: UITableViewController {

	// MARK: Creating a Configuration View Controller

	init(
		distributionURL: String?,
		submissionURL: String?,
		verificationURL: String?,
		exposureSubmissionService: ExposureSubmissionService
	) {
		self.distributionURL = distributionURL
		self.submissionURL = submissionURL
		self.verificationURL = verificationURL
		self.exposureSubmissionService = exposureSubmissionService

		super.init(style: .plain)
		title = "⚙️ Backend Configuration"
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Properties

	private let distributionURL: String?
	private let submissionURL: String?
	private let verificationURL: String?
	private let exposureSubmissionService: ExposureSubmissionService

	// MARK: UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(
			DMConfigurationCell.self,
			forCellReuseIdentifier: DMConfigurationCell.reuseIdentifier
		)
	}

	// MARK: UITableViewController

	override func tableView(
		_ tableView: UITableView,
		cellForRowAt indexPath: IndexPath
	) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: DMConfigurationCell.reuseIdentifier, for: indexPath)
		let title: String?
		let subtitle: String?
		switch indexPath.row {
		case 0:
			title = "Distribution URL"
			subtitle = distributionURL ?? "<none>"
		case 1:
			title = "Submission URL"
			subtitle = submissionURL ?? "<none>"
		case 2:
			title = "Verification URL"
			subtitle = verificationURL ?? "<none>"
		default:
			title = nil
			subtitle = nil
		}
		cell.textLabel?.text = title
		cell.detailTextLabel?.text = subtitle
		cell.detailTextLabel?.numberOfLines = 0
		return cell
	}

	override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		3
	}
}

#endif

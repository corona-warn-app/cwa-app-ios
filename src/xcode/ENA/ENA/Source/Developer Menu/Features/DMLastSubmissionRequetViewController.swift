//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

class DMLastSubmissionRequestViewController: UITableViewController {
	init(lastSubmissionRequest: Data?) {
		self.lastSubmissionRequest = lastSubmissionRequest
		super.init(style: .plain)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private let lastSubmissionRequest: Data?

	override func viewWillAppear(_ animated: Bool) {
		navigationController?.setToolbarHidden(false, animated: animated)
		let exportItem = UIBarButtonItem(
			title: "Export",
			style: .plain,
			target: self,
			action: #selector(exportRequest)
		)
		exportItem.isEnabled = lastSubmissionRequest != nil
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

	@objc
	func exportRequest() {
		let activityViewController = UIActivityViewController(activityItems: [lastSubmissionRequest ?? Data()], applicationActivities: nil)
		activityViewController.modalTransitionStyle = .coverVertical
		present(activityViewController, animated: true, completion: nil)
	}
}


#endif

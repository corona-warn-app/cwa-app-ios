////
// 🦠 Corona-Warn-App
//

import UIKit

class ValidationInformationViewController: UITableViewController, DismissHandling {

	// MARK: - Init

	init(
		dismiss: @escaping () -> Void
	) {
		self.dismiss = dismiss
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let dismiss: () -> Void

	// MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 0
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return 0
	}

}

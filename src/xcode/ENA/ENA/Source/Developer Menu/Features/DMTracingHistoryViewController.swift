//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

final class DMTracingHistoryViewController: UITableViewController {
	init(tracingHistory: TracingStatusHistory) {
		self.tracingHistory = tracingHistory
		super.init(style: .plain)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private let tracingHistory: TracingStatusHistory


	override func viewWillAppear(_ animated: Bool) {
		navigationController?.setToolbarHidden(true, animated: animated)
		super.viewWillAppear(animated)
	}

	// MARK: UITableView DataSource/Delegate
	override func numberOfSections(in tableView: UITableView) -> Int {
		1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		tracingHistory.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "DMTracingHistoryCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DMTracingHistoryCell")
		let item = tracingHistory[indexPath.row]
		cell.textLabel?.text = item.date.description
		cell.detailTextLabel?.text = String(item.on)
		return cell
	}
}

#endif

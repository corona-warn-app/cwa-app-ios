//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

final class DMNotificationsViewController: UITableViewController {
	
	// MARK: - Init
	
	init() {
		super.init(style: .plain)
		self.title = "Pending Notifications"
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.register(DMNotificationCell.self, forCellReuseIdentifier: DMNotificationCell.reuseIdentifier)
		tableView.allowsSelection = false
		
		UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
			self.localNotificationRequests = requests
		}
	}
	
	// MARK: - Protocol UITableView
	
	override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		localNotificationRequests.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: DMNotificationCell.reuseIdentifier, for: indexPath)
		let notificationRequest = localNotificationRequests[indexPath.row]
		
		cell.textLabel?.text = notificationRequest.identifier
		cell.textLabel?.numberOfLines = 0

		// Dear future developer that thinks it would be nice to display the nextTriggerDate of the notificationRequest for `UNTimeIntervalNotificationTrigger`
		// https://stackoverflow.com/questions/51618620/nexttriggerdate-doesnt-return-the-expected-value-is-there-another-way-to-o
		// Please check first if Apple was so kind to fix the nextTriggerDate ✌️
		// For `UNCalendarNotificationTrigger` the nextTriggerDate works as expected 🥳
		guard let trigger = notificationRequest.trigger as? UNCalendarNotificationTrigger, let triggerDate = trigger.nextTriggerDate() else {
			cell.detailTextLabel?.text = nil
			return cell
		}

		let df = DateFormatter()
		df.dateStyle = .short
		df.timeStyle = .short

		cell.detailTextLabel?.text = df.string(from: triggerDate)
		return cell
	}
	
	// MARK: - Private

	private var localNotificationRequests = [UNNotificationRequest]() {
		didSet {
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
}
#endif

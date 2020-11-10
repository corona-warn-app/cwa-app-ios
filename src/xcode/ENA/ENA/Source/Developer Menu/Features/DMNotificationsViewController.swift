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
		
		// Dear future developer that thinks it would be nice to display the nextTriggerDate of the notificationRequest
		// https://stackoverflow.com/questions/51618620/nexttriggerdate-doesnt-return-the-expected-value-is-there-another-way-to-o
		// Please check first if Apple was so kind to fix the nextTriggerDate ✌️
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

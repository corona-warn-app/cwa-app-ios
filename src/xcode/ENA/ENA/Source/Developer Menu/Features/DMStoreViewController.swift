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

/// A view controller that displays parts of what is stored in `Store`.
final class DMStoreViewController: UITableViewController {
	// MARK: Creating a Store view controller.
	init(store: Store) {
		self.store = store
		super.init(style: .plain)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Properties
	private let store: Store
	private lazy var items: [DMStoreItem] = {
		[
			DMStoreItem(attribute: "lastSuccessfulSubmitDiagnosisKeyTimestamp") { store in
				String(store.lastSuccessfulSubmitDiagnosisKeyTimestamp ?? 0)
			},
			DMStoreItem(attribute: "initialSubmitCompleted") { store in
				String(store.initialSubmitCompleted)
			},
			DMStoreItem(attribute: "devicePairingConsentAcceptTimestamp") { store in
				store.devicePairingConsentAcceptTimestamp?.description ?? ""
			},
			DMStoreItem(attribute: "devicePairingSuccessfulTimestamp") { store in
				store.devicePairingSuccessfulTimestamp?.description ?? ""
			},
			DMStoreItem(attribute: "devicePairingConsentAcceptTimestamp") { store in
				store.devicePairingConsentAcceptTimestamp?.description ?? ""
			},
			DMStoreItem(attribute: "previousRiskLevel") { store in
				store.previousRiskLevel?.description ?? ""
			}
		]
	}()

	// MARK: UIViewController
	override func viewWillAppear(_ animated: Bool) {
		navigationController?.setToolbarHidden(true, animated: animated)
		super.viewWillAppear(animated)
	}

	// MARK: UITableView DataSource/Delegate
	override func numberOfSections(in tableView: UITableView) -> Int {
		1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		items.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "DMStoreCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DMStoreCell")
		let item = items[indexPath.row]
		cell.textLabel?.text = item.attribute
		cell.detailTextLabel?.text = item.buildValue(store)
		return cell
	}
}

/// A model object for one row in the table.
private final class DMStoreItem {
	// MARK: Types
	typealias DMStoreItemBuildValue = (Store) -> String

	// MARK: Creating a store item.
	init(
		attribute: String,
		buildValue: @escaping DMStoreItemBuildValue
	) {
		self.buildValue = buildValue
		self.attribute = attribute
	}

	// MARK: Properties
	fileprivate let attribute: String
	fileprivate let buildValue: DMStoreItemBuildValue
}

#endif

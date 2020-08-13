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

/// A view controller that displays developer related settings.
final class DMSettingsViewController: UITableViewController {
	// MARK: Creating a settings view controller
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

	// MARK: UIViewController
	override func viewWillAppear(_ animated: Bool) {
		navigationController?.setToolbarHidden(true, animated: animated)
		super.viewWillAppear(animated)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.rowHeight = UITableView.automaticDimension
		tableView.register(DMOnOffCell.self, forCellReuseIdentifier: "DMOnOffCell")
	}

	// MARK: UITableView DataSource/Delegate
	override func numberOfSections(in tableView: UITableView) -> Int {
		1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// swiftlint:disable:next force_cast
		let cell = tableView.dequeueReusableCell(withIdentifier: "DMOnOffCell", for: indexPath) as! DMOnOffCell
		
		cell.configure(
			with: .init(
				title: "Fetch Hours instead of Days",
				subtitle: "If enabled, only the last 3 hours are fetched.",
				isOn: store.hourlyFetchingEnabled
			)
		)

		cell.onOffDidChange = { isOn in
			self.store.hourlyFetchingEnabled = isOn
		}

		return cell
	}
}

private class DMOnOffCell: UITableViewCell {
	// MARK: Types and Contants
	typealias DMOnOffDidChange = (Bool) -> Void
	private static let onOffNoOp: DMOnOffDidChange = { _ in }

	// MARK: Properties
	private let `switch` = UISwitch()
	var onOffDidChange: DMOnOffDidChange = onOffNoOp

	// MARK: Creating an OnOffCell
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: "DMOnOffCell")
		accessoryView = `switch`
		`switch`.addTarget(self, action: #selector(_takeOnOffValueFromSwitch(_:)), for: UIControl.Event.valueChanged)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Configure the Cell
	func configure(with model: Model) {
		`switch`.isOn = model.isOn
		textLabel?.text = model.title
		detailTextLabel?.text = model.subtitle
	}

	// MARK: UITableViewCell
	override func prepareForReuse() {
		super.prepareForReuse()
		onOffDidChange = type(of: self).onOffNoOp
	}

	@objc
	func _takeOnOffValueFromSwitch(_ sender: UISwitch) {
		onOffDidChange(sender.isOn)
	}
}


private extension DMOnOffCell {
	/// The model used to configure the cell.
	struct Model {
		let title: String
		let subtitle: String
		let isOn: Bool
	}
}

#endif

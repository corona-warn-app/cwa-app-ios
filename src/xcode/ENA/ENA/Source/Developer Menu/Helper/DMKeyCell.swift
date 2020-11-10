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

import UIKit
import ExposureNotification

final class DMKeyCell: UITableViewCell {
	static var reuseIdentifier = "DMKeyCell"
	
	override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension UITableView {
	func registerKeyCell() {
		register(DMKeyCell.self, forCellReuseIdentifier: DMKeyCell.reuseIdentifier)
	}

	func dequeueReusableKeyCell(for indexPath: IndexPath) -> DMKeyCell {
		// swiftlint:disable:next force_cast
		dequeueReusableCell(withIdentifier: DMKeyCell.reuseIdentifier, for: indexPath) as! DMKeyCell
	}
}

extension DMKeyCell {
	struct Model {
		private static let dateFormatter: DateFormatter = .rollingPeriodDateFormatter()
		let keyData: Data
		let rollingStartIntervalNumber: Int32
		let transmissionRiskLevel: Int32

		var rollingStartNumberDate: Date {
			Date(timeIntervalSince1970: Double(rollingStartIntervalNumber * 600))
		}

		var formattedRollingStartNumberDate: String {
			type(of: self).dateFormatter.string(from: rollingStartNumberDate)
		}

		var temporaryExposureKey: ENTemporaryExposureKey {
			let key = ENTemporaryExposureKey()
			key.keyData = keyData
			key.rollingStartNumber = UInt32(rollingStartIntervalNumber)
			key.transmissionRiskLevel = UInt8(transmissionRiskLevel)
			return key
		}
	}

	func configure(with model: Model) {
		textLabel?.text = model.keyData.base64EncodedString()
		detailTextLabel?.text = "Rolling Start Date: \(model.formattedRollingStartNumberDate)"
	}
}

private extension DateFormatter {
	class func rollingPeriodDateFormatter() -> DateFormatter {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .medium
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		return formatter
	}
}

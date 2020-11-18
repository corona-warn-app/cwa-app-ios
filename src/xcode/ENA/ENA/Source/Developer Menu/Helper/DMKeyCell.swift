//
// 🦠 Corona-Warn-App
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

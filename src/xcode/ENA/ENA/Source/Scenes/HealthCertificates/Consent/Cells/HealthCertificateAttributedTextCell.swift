////
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateAttributedTextCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal
	
	enum CellReuseIdentifier: String, TableViewCellReuseIdentifiers {
		case attributedText = "HealthCertificateAttributedTextCell"
	}

	// MARK: - Private

	private let attributedLabel = ENALabel()

	private func setupView() {
		textLabel?.numberOfLines = 0
	}
}

extension DynamicCell {

	static func attributedText(
		text: NSAttributedString,
		link: URL? = nil,
		accessibilityIdentifier: String? = nil
	) -> DynamicCell {
		var action: DynamicAction = .none
		if let url = link {
			action = .open(url: url)
		}
		return .custom(
			withIdentifier: HealthCertificateAttributedTextCell.CellReuseIdentifier.attributedText,
			action: action,
			accessoryAction: .none,
			configure: { _, cell, _ in
				cell.textLabel?.attributedText = text
				cell.accessibilityIdentifier = accessibilityIdentifier
			}
		)
	}

}

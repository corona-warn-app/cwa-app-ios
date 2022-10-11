////
// 🦠 Corona-Warn-App
//

import UIKit

class AntigenTestProfileInputDescriptionCell: UITableViewCell, ReuseIdentifierProviding {
		
	// MARK: - Init
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		selectionStyle = .none
		contentView.backgroundColor = .enaColor(for: .background)

		let label = ENALabel()
		label.text = AppStrings.AntigenProfile.Create.description
		label.style = .subheadline
		label.textColor = .enaColor(for: .textPrimary2)
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(label)

		NSLayoutConstraint.activate([
			label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 23),
			label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -23),
			label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
			label.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -2)
		])
	}
}

////
// 🦠 Corona-Warn-App
//

import UIKit

class CreateAntigenTestProfileDescriptionCell: UITableViewCell, ReuseIdentifierProviding {
		
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		selectionStyle = .none

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
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

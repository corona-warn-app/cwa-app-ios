//
// 🦠 Corona-Warn-App
//

import UIKit

class RiskLegendDotBodyCell: UITableViewCell {

	var dotView: UIView!
	var label: ENALabel!
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		// dotView
		dotView = UIView()
		dotView.backgroundColor = .enaColor(for: .riskHigh)
		dotView.layer.cornerRadius = 8
		dotView.layer.masksToBounds = true
		dotView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(dotView)
		dotView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 8).isActive = true
		dotView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -8).isActive = true
		dotView.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor).isActive = true
		dotView.heightAnchor.constraint(equalToConstant: 16).isActive = true
		dotView.widthAnchor.constraint(equalToConstant: 16).isActive = true
		// label
		label = ENALabel()
		label.style = .body
		label.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(label)
		label.leadingAnchor.constraint(equalTo: dotView.trailingAnchor, constant: 24).isActive = true
		label.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -8).isActive = true
		label.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor).isActive = true
		label.topAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.topAnchor, constant: 8).isActive = true
		label.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor, constant: -8).isActive = true
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

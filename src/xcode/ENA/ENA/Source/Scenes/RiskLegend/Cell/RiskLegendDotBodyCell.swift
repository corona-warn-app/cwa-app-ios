//
// 🦠 Corona-Warn-App
//

import UIKit

class RiskLegendDotBodyCell: UITableViewCell {
	
	// MARK: - Init
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		// dotView
		dotView.backgroundColor = .enaColor(for: .riskHigh)
		dotView.layer.cornerRadius = 8
		dotView.layer.masksToBounds = true
		dotView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(dotView)
		// label
		label.style = .body
		label.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(label)
		// set constraints
		NSLayoutConstraint.activate([
			// dotView
			dotView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 8),
			dotView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -8),
			dotView.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
			dotView.heightAnchor.constraint(equalToConstant: 16),
			dotView.widthAnchor.constraint(equalToConstant: 16),
			// label
			label.leadingAnchor.constraint(equalTo: dotView.trailingAnchor, constant: 24),
			label.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -8),
			label.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
			label.topAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.topAnchor, constant: 8),
			label.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor, constant: -8)
		])
	}
	
	// MARK: - Internal
	
	let dotView = UIView()
	let label = ENALabel()
}

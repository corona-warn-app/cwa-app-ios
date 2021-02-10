//
// 🦠 Corona-Warn-App
//

import UIKit

class EuTracingTableViewCell: UITableViewCell {

	private var iconView: UIImageView!
	private var titleLabel: ENALabel!
	private var countryList: ENALabel!
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		// self
		selectionStyle = .default
		contentView.backgroundColor = .enaColor(for: .background)
		accessoryType = .disclosureIndicator
		// iconView
		iconView = UIImageView(image: UIImage(named: "flag.eu"))
		iconView.contentMode = .scaleAspectFit
		iconView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(iconView)
		// titleLabel
		titleLabel = ENALabel()
		titleLabel.style = .body
		titleLabel.numberOfLines = 0
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(titleLabel)
		// countryList
		countryList = ENALabel()
		countryList.style = .footnote
		countryList.numberOfLines = 0
		countryList.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(countryList)
		// activate constrinats
		NSLayoutConstraint.activate([
			// iconView
			iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			iconView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
			iconView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 16),
			iconView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
			iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			iconView.widthAnchor.constraint(equalToConstant: 35),
			iconView.heightAnchor.constraint(equalToConstant: 25),
			// titleLabel
			titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
			titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
			// countryList
			countryList.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
			countryList.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			countryList.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
			countryList.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	var state: ENStateHandler.State?
	var viewModel: ENSettingEuTracingViewModel! {
		didSet {
			self.titleLabel.text = viewModel.title
			self.countryList.text = viewModel.countryListLabel
		}
	}

	func configure(using viewModel: ENSettingEuTracingViewModel = .init()) {
		self.viewModel = viewModel
		let backgroundView = UIView()
		backgroundView.backgroundColor = UIColor.clear
		self.selectedBackgroundView = backgroundView
	}
}

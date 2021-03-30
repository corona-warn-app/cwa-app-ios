////
// 🦠 Corona-Warn-App
//

import UIKit

class TraceLocationDetailsLocationCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	func configure(_ model: String) {
		locationLabel.text = model
	}

	// MARK: - Private

	private let locationLabel = ENALabel()

	private func setupView() {
		selectionStyle = .none
		backgroundColor = .clear
		contentView.backgroundColor = .clear

		locationLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(locationLabel)
		locationLabel.font = .enaFont(for: .subheadline)
		locationLabel.textColor = .enaColor(for: .textContrast)
		locationLabel.accessibilityTraits = .header
		locationLabel.numberOfLines = 0
		locationLabel.textAlignment = .center

		NSLayoutConstraint.activate([
			locationLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
			locationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.0),
			locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
			locationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0)
		])
	}
}

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

	// MARK: - Public

	// MARK: - Internal

	func configure(_ model: String) {
		let paragraph = NSMutableParagraphStyle()
		paragraph.alignment = .center
		titleLabel.attributedText = NSAttributedString(string: model, attributes: [.paragraphStyle: paragraph])
	}

	// MARK: - Private

	private let titleLabel = ENALabel()

	private func setupView() {
		selectionStyle = .none
		backgroundColor = .clear
		contentView.backgroundColor = .clear

		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(titleLabel)
		titleLabel.font = .enaFont(for: .subheadline)
		titleLabel.textColor = .enaColor(for: .textContrast)
		titleLabel.accessibilityTraits = .header
		titleLabel.numberOfLines = 0

		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
			titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.0),
			titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0)
		])
	}
}

////
// 🦠 Corona-Warn-App
//

import UIKit

class TraceLocationDetailsHeaderCell: UITableViewCell, ReuseIdentifierProviding {

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
		titleLabel.font = .enaFont(for: .headline)
		titleLabel.textColor = .enaColor(for: .textContrast)
		titleLabel.accessibilityTraits = .header
		titleLabel.numberOfLines = 0

		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26.0),
			titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12.0),
			titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0)
		])
	}
}

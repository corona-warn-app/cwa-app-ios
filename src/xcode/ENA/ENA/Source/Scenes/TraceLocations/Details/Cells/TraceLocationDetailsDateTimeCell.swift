////
// 🦠 Corona-Warn-App
//

import UIKit

class TraceLocationDetailsDateTimeCell: UITableViewCell, ReuseIdentifierProviding {

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

	func configure(_ model: String?) {
		let paragraph = NSMutableParagraphStyle()
		paragraph.alignment = .center
		dateTimeLabel.attributedText = NSAttributedString(string: model ?? String(), attributes: [.paragraphStyle: paragraph])
	}

	// MARK: - Private

	private let dateTimeLabel = ENALabel()

	private func setupView() {
		selectionStyle = .none
		backgroundColor = .clear
		contentView.backgroundColor = .clear

		dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(dateTimeLabel)
		dateTimeLabel.font = .enaFont(for: .subheadline)
		dateTimeLabel.textColor = .enaColor(for: .textPrimary1)
		dateTimeLabel.numberOfLines = 0

		NSLayoutConstraint.activate([
			dateTimeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.0),
			dateTimeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.0),
			dateTimeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
			dateTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0)
		])
	}
}

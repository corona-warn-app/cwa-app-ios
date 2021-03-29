////
// 🦠 Corona-Warn-App
//

import UIKit

class CheckInNoticeCell: UITableViewCell, ReuseIdentifierProviding {

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
		noticeLabel.text = model
	}

	// MARK: - Private

	private let typeLabel = ENALabel()

	private let noticeLabel = ENALabel()

	private func setupView() {
		selectionStyle = .none
		backgroundColor = .clear
		contentView.backgroundColor = .clear

		let tileView = UIView()
		tileView.translatesAutoresizingMaskIntoConstraints = false
		tileView.backgroundColor = .enaColor(for: .darkBackground)
		tileView.layer.cornerRadius = 12.0
		tileView.layer.masksToBounds = true
		tileView.layer.borderWidth = 1.0
		tileView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
		contentView.addSubview(tileView)

		noticeLabel.translatesAutoresizingMaskIntoConstraints = false
		tileView.addSubview(noticeLabel)
		noticeLabel.font = .enaFont(for: .subheadline)
		noticeLabel.textColor = .enaColor(for: .textPrimary1)
		noticeLabel.accessibilityTraits = .staticText
		noticeLabel.numberOfLines = 0

		NSLayoutConstraint.activate([
			tileView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3.0),
			tileView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			tileView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
			tileView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

			noticeLabel.topAnchor.constraint(equalTo: tileView.topAnchor, constant: 12.0),
			noticeLabel.bottomAnchor.constraint(equalTo: tileView.bottomAnchor, constant: -12.0),
			noticeLabel.leadingAnchor.constraint(equalTo: tileView.leadingAnchor, constant: 16.0),
			noticeLabel.trailingAnchor.constraint(equalTo: tileView.trailingAnchor, constant: -16.0)
		])
	}

}

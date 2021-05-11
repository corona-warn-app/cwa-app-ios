////
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateSimpleTextCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
		isAccessibilityElement = false
		contentTextLabel.isAccessibilityElement = true
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	func configure(with cellViewModel: HealthCertificateSimpleTextCellViewModel) {
		backgroundContainerView.backgroundColor = cellViewModel.backgroundColor ?? .clear
		contentTextLabel.accessibilityTraits = cellViewModel.accessibilityTraits
		if cellViewModel.attributedText != nil {
			contentTextLabel.attributedText = cellViewModel.attributedText
		} else {
			contentTextLabel.textColor = cellViewModel.textColor
			contentTextLabel.textAlignment = cellViewModel.textAlignment
			contentTextLabel.text = cellViewModel.text
			contentTextLabel.font = cellViewModel.font
		}
		topSpaceLayoutConstraint.constant = cellViewModel.topSpace
		backgroundContainerView.layer.borderColor = cellViewModel.boarderColor.cgColor
	}

	// MARK: - Private

	private let backgroundContainerView = UIView()
	private let contentTextLabel = ENALabel()
	private var topSpaceLayoutConstraint: NSLayoutConstraint!

	private func setupView() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		selectionStyle = .none

		if #available(iOS 13.0, *) {
			backgroundContainerView.layer.cornerCurve = .continuous
		}
		backgroundContainerView.layer.cornerRadius = 15.0
		backgroundContainerView.layer.masksToBounds = true
		backgroundContainerView.layer.borderWidth = 1.0

		backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(backgroundContainerView)

		contentTextLabel.translatesAutoresizingMaskIntoConstraints = false
		contentTextLabel.numberOfLines = 0

		backgroundContainerView.addSubview(contentTextLabel)
		topSpaceLayoutConstraint = contentTextLabel.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 18.0)

		NSLayoutConstraint.activate(
			[
				backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0),
				backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0),
				backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				topSpaceLayoutConstraint,
				contentTextLabel.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -18.0),
				contentTextLabel.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 14.0),
				contentTextLabel.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -14.0)
			]
		)
	}
}

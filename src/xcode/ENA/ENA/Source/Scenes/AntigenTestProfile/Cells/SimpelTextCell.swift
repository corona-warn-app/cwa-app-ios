////
// 🦠 Corona-Warn-App
//

import UIKit

class SimpelTextCell: UITableViewCell, ReuseIdentifierProviding {

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

	func configure(with cellViewModel: SimpelTextCellViewModel) {
		backgroundContainerView.backgroundColor = cellViewModel.backgroundColor ?? .clear
		contentTextLabel.textColor = cellViewModel.textColor
		contentTextLabel.textAlignment = cellViewModel.textAlignment
		contentTextLabel.text = cellViewModel.text
		topSpaceLayoutConstraint.constant = cellViewModel.topSpace
		contentTextLabel.font = cellViewModel.font
	}

	// MARK: - Private

	private let backgroundContainerView = UIView()
	private let contentTextLabel = ENALabel()
	private var topSpaceLayoutConstraint: NSLayoutConstraint!

	private func setupView() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear

		backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(backgroundContainerView)

		contentTextLabel.translatesAutoresizingMaskIntoConstraints = false
		backgroundContainerView.addSubview(contentTextLabel)
		topSpaceLayoutConstraint = contentTextLabel.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 5.0)

		NSLayoutConstraint.activate(
			[
				backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
				backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0),
				backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30.0),
				backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30.0),

				topSpaceLayoutConstraint,
				contentTextLabel.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -5.0),
				contentTextLabel.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 14.0),
				contentTextLabel.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -14.0)
			]
		)

	}

}

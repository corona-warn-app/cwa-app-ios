////
// 🦠 Corona-Warn-App
//

import UIKit

class CheckInDescriptionCell: UITableViewCell, ReuseIdentifierProviding {

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

	func configure(cellModel: CheckInDescriptionCellModel) {
		traceLocationTypeLabel.text = cellModel.locationType
		traceLocationDescriptionLabel.text = cellModel.description
		traceLocationAddressLabel.text = cellModel.address
	}

	// MARK: - Private

	private let traceLocationTypeLabel = ENALabel()
	private let traceLocationDescriptionLabel = ENALabel()
	private let traceLocationAddressLabel = ENALabel()

	private func setupView() {
		selectionStyle = .none
		backgroundColor = .clear
		contentView.backgroundColor = .clear

		traceLocationTypeLabel.translatesAutoresizingMaskIntoConstraints = false
		traceLocationTypeLabel.font = .enaFont(for: .body)
		traceLocationTypeLabel.textColor = .enaColor(for: .textPrimary2)
		traceLocationTypeLabel.numberOfLines = 0

		traceLocationDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		traceLocationDescriptionLabel.font = .enaFont(for: .title1)
		traceLocationDescriptionLabel.textColor = .enaColor(for: .textPrimary1)
		traceLocationDescriptionLabel.numberOfLines = 0

		traceLocationAddressLabel.translatesAutoresizingMaskIntoConstraints = false
		traceLocationAddressLabel.font = .enaFont(for: .body)
		traceLocationAddressLabel.textColor = .enaColor(for: .textPrimary2)
		traceLocationAddressLabel.numberOfLines = 0

		let tileView = UIView()
		tileView.translatesAutoresizingMaskIntoConstraints = false
		tileView.backgroundColor = .enaColor(for: .darkBackground)
		tileView.layer.cornerRadius = 12.0
		tileView.layer.masksToBounds = true
		tileView.layer.borderWidth = 1.0
		tileView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
		contentView.addSubview(tileView)

		let stackView = UIStackView(
			arrangedSubviews:
				[
					traceLocationTypeLabel,
					traceLocationDescriptionLabel,
					traceLocationAddressLabel
				]
		)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 14.0
		tileView.addSubview(stackView)

		NSLayoutConstraint.activate(
			[
				tileView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.0),
				tileView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3.0),
				tileView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				tileView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				stackView.topAnchor.constraint(equalTo: tileView.topAnchor, constant: 32.0),
				stackView.bottomAnchor.constraint(equalTo: tileView.bottomAnchor, constant: -32.0),
				stackView.leadingAnchor.constraint(equalTo: tileView.leadingAnchor, constant: 16.0),
				stackView.trailingAnchor.constraint(equalTo: tileView.trailingAnchor, constant: -16.0)
			]
		)
	}

}

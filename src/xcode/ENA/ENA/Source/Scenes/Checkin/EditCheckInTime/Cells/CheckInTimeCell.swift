////
// 🦠 Corona-Warn-App
//

import UIKit

class CheckInTimeCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	func configure(_ cellModel: CheckInTimeModel) {
		typeLabel.text = cellModel.type
		dateTimeLabel.text = cellModel.dateString
	}

	// MARK: - Private

	private let typeLabel = ENALabel()
	private let dateTimeLabel = ENALabel()

	private func setupView() {
		selectionStyle = .none
		backgroundColor = .enaColor(for: .cellBackground)
		contentView.backgroundColor = .enaColor(for: .cellBackground)

		typeLabel.translatesAutoresizingMaskIntoConstraints = false
		typeLabel.font = .enaFont(for: .subheadline)
		typeLabel.textColor = .enaColor(for: .textPrimary1)

		dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
		dateTimeLabel.font = .enaFont(for: .subheadline)
		dateTimeLabel.textColor = .enaColor(for: .textPrimary1)
		dateTimeLabel.textAlignment = .right
		dateTimeLabel.numberOfLines = 1

		let tileView = UIView()
		tileView.translatesAutoresizingMaskIntoConstraints = false
		tileView.backgroundColor = .enaColor(for: .background)
		contentView.addSubview(tileView)

		let mainStackView = UIStackView(
			arrangedSubviews:
				[
					typeLabel,
					dateTimeLabel
				]
		)
		mainStackView.translatesAutoresizingMaskIntoConstraints = false
		mainStackView.axis = .horizontal
		mainStackView.spacing = 36.0
		mainStackView.distribution = .fillEqually
		mainStackView.alignment = .center
		tileView.addSubview(mainStackView)

		NSLayoutConstraint.activate(
			[
				tileView.topAnchor.constraint(equalTo: contentView.topAnchor),
				tileView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
				tileView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				tileView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				mainStackView.topAnchor.constraint(equalTo: tileView.topAnchor, constant: 12.0),
				mainStackView.bottomAnchor.constraint(equalTo: tileView.bottomAnchor, constant: -12.0),
				mainStackView.leadingAnchor.constraint(equalTo: tileView.leadingAnchor, constant: 16.0),
				mainStackView.trailingAnchor.constraint(equalTo: tileView.trailingAnchor, constant: -16.0)
			]
		)
	}

}

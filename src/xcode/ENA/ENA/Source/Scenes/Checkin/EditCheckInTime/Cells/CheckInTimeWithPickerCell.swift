////
// 🦠 Corona-Warn-App
//

import UIKit

class CheckInTimeWithPickerCell: UITableViewCell, ReuseIdentifierProviding {

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

	func configure(_ cellModel: CheckInTimeWithPickerModel) {
		typeLabel.text = cellModel.type
		dateLabel.text = cellModel.dateString
		timeLabel.text = cellModel.timeString
	}

	// MARK: - Private

	private let typeLabel = ENALabel()
	private let dateLabel = ENALabel()
	private let timeLabel = ENALabel()

	private func setupView() {
		selectionStyle = .none
		backgroundColor = .enaColor(for: .cellBackground)
		contentView.backgroundColor = .enaColor(for: .cellBackground)

		typeLabel.translatesAutoresizingMaskIntoConstraints = false
		typeLabel.font = .enaFont(for: .subheadline)
		typeLabel.textColor = .enaColor(for: .textPrimary1)

		dateLabel.translatesAutoresizingMaskIntoConstraints = false
		dateLabel.font = .enaFont(for: .subheadline)
		dateLabel.textColor = .enaColor(for: .textPrimary1)
		dateLabel.textAlignment = .right
		dateLabel.numberOfLines = 1

		timeLabel.translatesAutoresizingMaskIntoConstraints = false
		timeLabel.font = .enaFont(for: .subheadline)
		timeLabel.textColor = .enaColor(for: .textPrimary1)
		timeLabel.textAlignment = .right
		timeLabel.numberOfLines = 1

		let tileView = UIView()
		tileView.translatesAutoresizingMaskIntoConstraints = false
		tileView.backgroundColor = .enaColor(for: .background)
		tileView.layer.cornerRadius = 12.0
		tileView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//		tileView.layer.masksToBounds = true
		tileView.layer.borderWidth = 1.0
		tileView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
		contentView.addSubview(tileView)

		let rightStackView = UIStackView(
			arrangedSubviews:
				[
					dateLabel,
					timeLabel
				]
		)
		rightStackView.translatesAutoresizingMaskIntoConstraints = false
		rightStackView.axis = .horizontal
		rightStackView.spacing = 1.0
		rightStackView.distribution = .fillEqually

		let mainStackView = UIStackView(
			arrangedSubviews:
				[
					typeLabel,
					rightStackView
				]
		)
		mainStackView.translatesAutoresizingMaskIntoConstraints = false
		mainStackView.axis = .horizontal
		mainStackView.spacing = 36.0
		mainStackView.distribution = .fillEqually
		tileView.addSubview(mainStackView)

		NSLayoutConstraint.activate(
			[
				tileView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3.0),
				tileView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
				tileView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				tileView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				mainStackView.topAnchor.constraint(equalTo: tileView.topAnchor, constant: 14.0),
				mainStackView.bottomAnchor.constraint(equalTo: tileView.bottomAnchor, constant: -14.0),
				mainStackView.leadingAnchor.constraint(equalTo: tileView.leadingAnchor, constant: 16.0),
				mainStackView.trailingAnchor.constraint(equalTo: tileView.trailingAnchor, constant: -16.0)
			]
		)
	}

}

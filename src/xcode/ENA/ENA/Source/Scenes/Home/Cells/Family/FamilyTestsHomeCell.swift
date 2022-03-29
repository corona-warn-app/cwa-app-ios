//
// 🦠 Corona-Warn-App
//

import UIKit

class FamilyTestsHomeCell: UITableViewCell, ReuseIdentifierProviding {

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

	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)
		homeCardView.setHighlighted(highlighted, animated: animated)
	}

	// MARK: - Internal

	func configure(with viewModel: FamilyTestsHomeCellViewModel) {
		badgeView.setBadge(viewModel.badgeText, animated: true)
		detailsLabel.text = viewModel.detailText
		detailsLabel.isHidden = viewModel.isDetailsHidden
	}

	// MARK: - Private

	private let headerLabel: ENALabel =  {
		let headerLabel = ENALabel(style: .headline)
		headerLabel.text = AppStrings.Home.familyTestTitle
		headerLabel.numberOfLines = 0
		return headerLabel
	}()

	private let detailsLabel: ENALabel = {
		let detailsLabel = ENALabel(style: .body)
		detailsLabel.text = AppStrings.Home.familyTestDetail
		detailsLabel.numberOfLines = 0
		return detailsLabel
	}()

	private let homeCardView = HomeCardView()
	private let badgeView = BadgeView(nil, fillColor: .red, textColor: .white)

	private func setupView() {
		selectionStyle = .none
		backgroundColor = .clear
		contentView.backgroundColor = .clear

		homeCardView.backgroundColor = .enaColor(for: .cellBackground)
		contentView.addSubview(homeCardView)

		let imageView = UIImageView(image: UIImage(imageLiteralResourceName: "Icon_Family_Cell"))
		imageView.translatesAutoresizingMaskIntoConstraints = false
		homeCardView.addSubview(imageView)

		badgeView.translatesAutoresizingMaskIntoConstraints = false
		homeCardView.addSubview(badgeView)

		headerLabel.translatesAutoresizingMaskIntoConstraints = false
		homeCardView.addSubview(headerLabel)

		detailsLabel.translatesAutoresizingMaskIntoConstraints = false
		homeCardView.addSubview(detailsLabel)

		let chevronImageView = UIImageView(image: UIImage(imageLiteralResourceName: "Icons_Chevron_plain"))
		chevronImageView.translatesAutoresizingMaskIntoConstraints = false
		homeCardView.addSubview(chevronImageView)

		NSLayoutConstraint.activate(
			[
				homeCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15.0),
				homeCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14.0),
				homeCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -17.0),
				homeCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12.0),

				imageView.leadingAnchor.constraint(equalTo: homeCardView.leadingAnchor, constant: 13.0),
				imageView.topAnchor.constraint(equalTo: homeCardView.topAnchor, constant: 12.0),
				imageView.widthAnchor.constraint(equalToConstant: 40.0),
				imageView.heightAnchor.constraint(equalToConstant: 40.0),

				badgeView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: -2.0),
				badgeView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 2.0),

				headerLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 9.0),
				headerLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),

				chevronImageView.leadingAnchor.constraint(greaterThanOrEqualTo: headerLabel.trailingAnchor, constant: 14.0),
				chevronImageView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
				chevronImageView.trailingAnchor.constraint(equalTo: homeCardView.trailingAnchor, constant: -24.0),
				chevronImageView.widthAnchor.constraint(equalToConstant: 7.0),
				chevronImageView.heightAnchor.constraint(equalToConstant: 12.0),

				detailsLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
				detailsLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 4.0),
				detailsLabel.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),
				detailsLabel.bottomAnchor.constraint(equalTo: homeCardView.bottomAnchor, constant: -15.0)
			]
		)
	}

}

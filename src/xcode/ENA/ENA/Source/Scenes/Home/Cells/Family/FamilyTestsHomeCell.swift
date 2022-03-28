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

	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)
		homeCardView.setHighlighted(highlighted, animated: animated)
	}

	// MARK: - Private

	private let headerLabel: ENALabel =  {
		let headlineLabel = ENALabel(style: .headline)
		headlineLabel.text = AppStrings.Home.familyTestTitle
		return headlineLabel
	}()

	private let detailsLabel: ENALabel = {
		let detailsLabel = ENALabel(style: .body)
		detailsLabel.text = AppStrings.Home.familyTestDetail
		return detailsLabel
	}()

	private let homeCardView = HomeCardView()

	private func setupView() {
		selectionStyle = .none
		backgroundColor = .clear
		contentView.backgroundColor = .clear

		homeCardView.backgroundColor = .white
		contentView.addSubview(homeCardView)

		let imageView = UIImageView(image: UIImage(imageLiteralResourceName: "Icon_Family"))
		imageView.translatesAutoresizingMaskIntoConstraints = false
		homeCardView.addSubview(imageView)

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

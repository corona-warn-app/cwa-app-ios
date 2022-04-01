//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

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
		subscriptions.removeAll()
		viewModel.badgeCount
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] _ in
				self?.badgeView.setBadge(viewModel.badgeText, animated: true)
				self?.detailsLabel.text = viewModel.detailText
				self?.detailsLabel.isHidden = viewModel.isDetailsHidden
			}
			.store(in: &subscriptions)
	}

	// MARK: - Private

	private let headerLabel: ENALabel =  {
		let headerLabel = ENALabel(style: .headline)
		headerLabel.translatesAutoresizingMaskIntoConstraints = false
		headerLabel.text = AppStrings.Home.familyTestTitle
		headerLabel.numberOfLines = 0
		return headerLabel
	}()

	private let detailsLabel: ENALabel = {
		let detailsLabel = ENALabel(style: .body)
		detailsLabel.translatesAutoresizingMaskIntoConstraints = false
		detailsLabel.text = AppStrings.Home.familyTestDetail
		detailsLabel.numberOfLines = 0
		return detailsLabel
	}()

	private let badgeView: BadgeView = {
		let badgeView = BadgeView(nil, fillColor: .red, textColor: .white)
		badgeView.translatesAutoresizingMaskIntoConstraints = false
		return badgeView
	}()

	private let homeCardView: HomeCardView = {
		let homeCardView = HomeCardView()
		homeCardView.backgroundColor = .enaColor(for: .background)
		return homeCardView
	}()

	private let familyIconImageView: UIImageView = {
		let imageView = UIImageView(image: UIImage(imageLiteralResourceName: "Icon_Family_Cell"))
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private let chevronImageView: UIImageView = {
		let imageView = UIImageView(image: UIImage(imageLiteralResourceName: "Icons_Chevron_plain"))
		imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private var subscriptions = Set<AnyCancellable>()

	private func setupView() {
		selectionStyle = .none
		backgroundColor = .clear
		contentView.backgroundColor = .clear

		contentView.addSubview(homeCardView)
		homeCardView.addSubview(familyIconImageView)
		homeCardView.addSubview(badgeView)
		homeCardView.addSubview(headerLabel)
		homeCardView.addSubview(detailsLabel)
		homeCardView.addSubview(chevronImageView)

		NSLayoutConstraint.activate(
			[
				homeCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				homeCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12.0),
				homeCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
				homeCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12.0),

				familyIconImageView.leadingAnchor.constraint(equalTo: homeCardView.leadingAnchor, constant: 13.0),
				familyIconImageView.topAnchor.constraint(greaterThanOrEqualTo: homeCardView.topAnchor, constant: 12.0),
				familyIconImageView.bottomAnchor.constraint(lessThanOrEqualTo: homeCardView.bottomAnchor, constant: -12.0),
				familyIconImageView.widthAnchor.constraint(equalToConstant: 40.0),
				familyIconImageView.heightAnchor.constraint(equalToConstant: 40.0),

				badgeView.topAnchor.constraint(equalTo: familyIconImageView.topAnchor, constant: -2.0),
				badgeView.trailingAnchor.constraint(equalTo: familyIconImageView.trailingAnchor, constant: 2.0),

				headerLabel.topAnchor.constraint(greaterThanOrEqualTo: homeCardView.topAnchor, constant: 15.0),
				headerLabel.leadingAnchor.constraint(equalTo: familyIconImageView.trailingAnchor, constant: 9.0),
				headerLabel.centerYAnchor.constraint(equalTo: familyIconImageView.centerYAnchor),

				chevronImageView.leadingAnchor.constraint(greaterThanOrEqualTo: headerLabel.trailingAnchor, constant: 14.0),
				chevronImageView.centerYAnchor.constraint(equalTo: familyIconImageView.centerYAnchor),
				chevronImageView.trailingAnchor.constraint(equalTo: homeCardView.trailingAnchor, constant: -24.0),

				detailsLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
				detailsLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 4.0),
				detailsLabel.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),
				detailsLabel.bottomAnchor.constraint(equalTo: homeCardView.bottomAnchor, constant: -15.0)
			]
		)

		accessibilityTraits = .button
	}

}

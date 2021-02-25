//
// 🦠 Corona-Warn-App
//

import UIKit

extension OnboardingInfoViewController {

	func addPanel(
		title: String,
		body: String,
		textColor: ENAColor = .textPrimary1,
		bgColor: ENAColor = .separator,
		titleStyle: ENALabel.Style = .headline,
		bodyStyle: ENALabel.Style = .subheadline,
		insets: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
		itemSpacing: CGFloat = 10
	) {

		let titleLabel = ENALabel()
		titleLabel.style = titleStyle
		titleLabel.text = title
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.textColor = .enaColor(for: textColor)
		titleLabel.lineBreakMode = .byWordWrapping
		titleLabel.numberOfLines = 0

		let textLabel = ENALabel()
		textLabel.style = bodyStyle
		textLabel.text = body
		textLabel.translatesAutoresizingMaskIntoConstraints = false
		textLabel.textColor = .enaColor(for: textColor)
		textLabel.lineBreakMode = .byWordWrapping
		textLabel.numberOfLines = 0

		let labelStackView = UIStackView(arrangedSubviews: [titleLabel, textLabel])
		labelStackView.translatesAutoresizingMaskIntoConstraints = false
		labelStackView.axis = .vertical
		labelStackView.alignment = .fill
		labelStackView.distribution = .equalSpacing
		labelStackView.spacing = itemSpacing

		let containerView = UIView()
		containerView.addSubview(labelStackView)
		containerView.layer.cornerRadius = 14.0
		containerView.backgroundColor = .enaColor(for: bgColor)
		containerView.layoutMargins = insets
		stackView.addArrangedSubview(containerView)

		let layoutMarginsGuide = containerView.layoutMarginsGuide
		NSLayoutConstraint.activate([
			labelStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
			labelStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
			labelStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			labelStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
		])

	}

	/// Adds a simple paragraph with a title and a text under it.
	func addParagraph(
		title: String,
		body: String,
		textColor: ENAColor = .textPrimary1,
		bgColor: ENAColor = .background,
		itemSpacing: CGFloat = 20
	) {
		addPanel(
			title: title,
			body: body,
			textColor: .textPrimary1,
			bgColor: .background,
			bodyStyle: .subheadline,
			insets: .zero,
			itemSpacing: itemSpacing
		)
	}

	func createCountrySection(
		title: String,
		countries: [Country]
	) -> UIView {

		let containerView = UIView()

		let flagsLabel = UILabel()
		flagsLabel.numberOfLines = 0
		flagsLabel.translatesAutoresizingMaskIntoConstraints = false

		let namesLabel = UILabel()
		namesLabel.numberOfLines = 0
		namesLabel.translatesAutoresizingMaskIntoConstraints = false

		let topSeparator = UIView()
		topSeparator.backgroundColor = .enaColor(for: .hairline)

		let bottomSeparator = UIView()
		bottomSeparator.backgroundColor = .enaColor(for: .hairline)

		let containerStackView = UIStackView(
			arrangedSubviews: [
				topSeparator,
				flagsLabel,
				namesLabel,
				bottomSeparator
			]
		)
		containerStackView.translatesAutoresizingMaskIntoConstraints = false
		containerStackView.axis = .vertical
		containerStackView.alignment = .leading
		containerStackView.distribution = .equalCentering
		containerStackView.spacing = 4
		containerView.addSubview(containerStackView)

		let titleLabel = ENALabel()
		titleLabel.style = .headline
		titleLabel.text = title
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.textColor = .enaColor(for: .textPrimary1)
		titleLabel.lineBreakMode = .byWordWrapping
		titleLabel.numberOfLines = 0
		containerView.addSubview(titleLabel)

		let layoutMarginsGuide = containerView.layoutMarginsGuide
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			topSeparator.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			topSeparator.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
			topSeparator.heightAnchor.constraint(equalToConstant: 1),
			containerStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
			containerStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
			containerStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			containerStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
			bottomSeparator.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			bottomSeparator.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
			bottomSeparator.heightAnchor.constraint(equalToConstant: 1)
		])

		let countryNames = countries.map({ $0.localizedName })
			.joined(separator: ", ")

		let flagImages = countries.map { $0.flag }
			.map { image -> NSAttributedString in
				let imageAttribute = NSTextAttachment()
				imageAttribute.image = image?.resize(with: CGSize(width: 28.0, height: 28.0))
				return NSAttributedString(attachment: imageAttribute)
			}
			.joined(with: "  ")

		flagsLabel.attributedText = flagImages
		namesLabel.text = countryNames

		return containerView
	}

	func addCountrySection(
		title: String,
		countries: [Country]
	) {
		if countries.isEmpty {
			addParagraph(
				title: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_emptyEuTitle,
				body: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_emptyEuDescription
			)
			return
		}

		let containerView = createCountrySection(title: title, countries: countries)
		stackView.addArrangedSubview(containerView)
	}

}

// MARK: - Protocol UITextViewDelegate

extension OnboardingInfoViewController: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		LinkHelper.openLink(withUrl: url, from: self)
		return false
	}
}

// MARK: - Protocol NavigationBarOpacityDelegate

extension OnboardingInfoViewController: NavigationBarOpacityDelegate {
	var preferredNavigationBarOpacity: CGFloat {
		let alpha = (scrollView.adjustedContentInset.top + scrollView.contentOffset.y) / scrollView.adjustedContentInset.top
		return max(0, min(alpha, 1))
	}
}

// MARK: - Protocol RequiresAppDependencies

extension OnboardingInfoViewController: RequiresAppDependencies {

}

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

		let countryListView = UIStackView()
		countryListView.translatesAutoresizingMaskIntoConstraints = false
		countryListView.axis = .vertical
		countryListView.alignment = .leading
		countryListView.distribution = .equalSpacing
		countryListView.spacing = 7.5
		containerView.addSubview(countryListView)

		let titleLabel = ENALabel()
		titleLabel.style = .headline
		titleLabel.text = title
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.textColor = .enaColor(for: .textPrimary1)
		titleLabel.lineBreakMode = .byWordWrapping
		titleLabel.numberOfLines = 0
		containerView.addSubview(titleLabel)

		for (index, country) in countries.enumerated() {
			let stackView = UIStackView()
			stackView.axis = .horizontal
			stackView.alignment = .center
			stackView.spacing = 13

			let label = ENALabel()
			label.style = .body
			label.text = country.localizedName

			let image = UIImageView(image: country.flag)
			image.widthAnchor.constraint(equalToConstant: 28).isActive = true
			image.contentMode = .scaleAspectFit

			stackView.addArrangedSubview(image)
			stackView.addArrangedSubview(label)
			countryListView.addArrangedSubview(stackView)

			if index == countries.count - 1 { break }
			let separator = UIView()
			separator.backgroundColor = .enaColor(for: .hairline)
			countryListView.addArrangedSubview(separator)

			NSLayoutConstraint.activate([
				separator.leadingAnchor.constraint(equalTo: countryListView.leadingAnchor),
				separator.trailingAnchor.constraint(equalTo: countryListView.trailingAnchor),
				separator.heightAnchor.constraint(equalToConstant: 1)
			])
		}

		let layoutMarginsGuide = containerView.layoutMarginsGuide

		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			countryListView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
			countryListView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
			countryListView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			countryListView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
		])

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

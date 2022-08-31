//
// 🦠 Corona-Warn-App
//

import UIKit

class MaskStateTableViewCell: UITableViewCell, UITextViewDelegate, ReuseIdentifierProviding {
	
	// MARK: - Init
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		setupView()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Protocol UITextViewDelegate

	func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		LinkHelper.open(url: url, interaction: interaction) == .allow
	}
	
	// MARK: - Internal
	
	func configure(with cellModel: MaskStateCellModel) {
		titleLabel.text = cellModel.title
		titleLabel.isHidden = (cellModel.title ?? "").isEmpty

		subtitleLabel.text = cellModel.subtitle
		subtitleLabel.isHidden = (cellModel.subtitle ?? "").isEmpty
		
		badgeImageView.image = cellModel.badgeImage

		descriptionLabel.text = cellModel.description
		descriptionLabel.isHidden = (cellModel.description ?? "").isEmpty

		faqLinkTextView.attributedText = cellModel.faqLink
		faqLinkTextView.isHidden = (cellModel.faqLink?.string ?? "").isEmpty
	}
	
	// MARK: - Private
	
	/// The main container for any elements
	private let backgroundContainerView: UIView = {
		let backgroundContainerView = UIView()
		backgroundContainerView.backgroundColor = .enaColor(for: .cellBackground2)
		backgroundContainerView.layer.borderColor = .enaColor(for: .hairline)
		if #available(iOS 13.0, *) {
			backgroundContainerView.layer.cornerCurve = .continuous
		}
		backgroundContainerView.layer.cornerRadius = 15
		backgroundContainerView.layer.masksToBounds = true

		return backgroundContainerView
	}()
	
	/// The container for all content elements
	private let contentStackView: UIStackView = {
		let contentStackView = UIStackView()
		contentStackView.axis = .vertical
		contentStackView.alignment = .fill
		contentStackView.spacing = 6

		return contentStackView
	}()
	
	/// The container for upper elements like titles or badge
	private let topElementsStackView: UIStackView = {
		let topElementsStackView = UIStackView()
		topElementsStackView.axis = .horizontal
		topElementsStackView.alignment = .top
		topElementsStackView.distribution = .equalSpacing
		return topElementsStackView
	}()
	
	/// The container to all title elements
	private let titlesStackView: UIStackView = {
		let titleStackView = UIStackView()
		titleStackView.axis = .vertical
		titleStackView.alignment = .leading
		
		return titleStackView
	}()
	
	/// The title element
	private let titleLabel: ENALabel = {
		let titleLabel = ENALabel(style: .headline)
		titleLabel.numberOfLines = 0
		titleLabel.textColor = .enaColor(for: .textPrimary1)
		titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

		return titleLabel
	}()
	
	/// The subtitle element
	private let subtitleLabel: ENALabel = {
		let subtitleLabel = ENALabel(style: .body)
		subtitleLabel.numberOfLines = 0
		subtitleLabel.textColor = .enaColor(for: .textPrimary2)

		return subtitleLabel
	}()
	
	/// The badge icon element (mask status)
	private var badgeImageView: UIImageView = {
		let badgeImageView = UIImageView()
		badgeImageView.contentMode = .scaleAspectFit
		
		return badgeImageView
	}()
	
	/// The description text element
	private let descriptionLabel: ENALabel = {
		let descriptionLabel = ENALabel(style: .body)
		descriptionLabel.numberOfLines = 0

		return descriptionLabel
	}()
	
	/// The FAQ link element
	private lazy var faqLinkTextView: UITextView = {
		let faqLinkTextView = UITextView()
		faqLinkTextView.backgroundColor = .enaColor(for: .cellBackground2)
		faqLinkTextView.isScrollEnabled = false
		faqLinkTextView.isEditable = false
		faqLinkTextView.textContainerInset = .zero
		faqLinkTextView.textContainer.lineFragmentPadding = .zero
		faqLinkTextView.textColor = .enaColor(for: .textPrimary1)
		faqLinkTextView.tintColor = .enaColor(for: .textTint)
		faqLinkTextView.accessibilityTraits = .button
		faqLinkTextView.linkTextAttributes = [
			.foregroundColor: UIColor.enaColor(for: .textTint),
			.underlineColor: UIColor.clear
		]
		
		return faqLinkTextView
	}()
	
	private func setupView() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		selectionStyle = .none
		
		[
			backgroundContainerView,
			contentStackView,
			topElementsStackView,
			titleLabel,
			subtitleLabel,
			descriptionLabel,
			faqLinkTextView,
			badgeImageView
		].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
		
		contentView.addSubview(backgroundContainerView)
		backgroundContainerView.addSubview(contentStackView)
		contentStackView.addArrangedSubview(topElementsStackView)
		topElementsStackView.addArrangedSubview(titlesStackView)
		topElementsStackView.addArrangedSubview(badgeImageView)
		titlesStackView.addArrangedSubview(titleLabel)
		titlesStackView.addArrangedSubview(subtitleLabel)
		contentStackView.addArrangedSubview(descriptionLabel)
		contentStackView.addArrangedSubview(faqLinkTextView)
		
		contentStackView.setCustomSpacing(16, after: descriptionLabel)
		
		NSLayoutConstraint.activate([
			backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
			backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
			backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			
			contentStackView.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 16),
			contentStackView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -16),
			contentStackView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16),
			contentStackView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16),
			
			badgeImageView.widthAnchor.constraint(equalToConstant: 51),
			badgeImageView.heightAnchor.constraint(equalToConstant: 31)
		])
	}
}

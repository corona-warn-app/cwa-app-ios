////
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateTextViewCell: UITableViewCell, UITextViewDelegate, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
		isAccessibilityElement = false
		contentTextView.isAccessibilityElement = true

		contentTextView.dataDetectorTypes = UIDataDetectorTypes.all
		contentTextView.isScrollEnabled = false
		contentTextView.isUserInteractionEnabled = true
		contentTextView.adjustsFontForContentSizeCategory = true
		contentTextView.textContainerInset = .zero
		contentTextView.textContainer.lineFragmentPadding = .zero
		contentTextView.backgroundColor = .clear
		contentTextView.delegate = self
		contentTextView.isSelectable = true
		contentTextView.isEditable = false
		contentTextView.tintColor = .enaColor(for: .tint)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateBorderWidth()
	}

	// MARK: - Protocol UITextViewDelegate

	func textViewDidChangeSelection(_ textView: UITextView) {
		endEditing(true)
		textView.selectedTextRange = nil
	}

	func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		LinkHelper.open(url: url, interaction: interaction) == .allow
	}

	// MARK: - Internal

	func configure(with cellViewModel: HealthCertificateSimpleTextCellViewModel) {
		backgroundContainerView.backgroundColor = cellViewModel.backgroundColor ?? .clear
		contentTextView.accessibilityTraits = cellViewModel.accessibilityTraits
		if cellViewModel.attributedText != nil {
			contentTextView.attributedText = cellViewModel.attributedText
		} else {
			contentTextView.textColor = cellViewModel.textColor
			contentTextView.textAlignment = cellViewModel.textAlignment
			contentTextView.text = cellViewModel.text
			contentTextView.font = cellViewModel.font
		}
		topSpaceLayoutConstraint.constant = cellViewModel.topSpace
		backgroundContainerView.layer.borderColor = cellViewModel.borderColor.cgColor
		accessibilityIdentifier = cellViewModel.accessibilityIdentifier
	}

	// MARK: - Private

	private let backgroundContainerView = UIView()
	private let contentTextView = UITextView()
	private var topSpaceLayoutConstraint: NSLayoutConstraint!

	private func setupView() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		selectionStyle = .none

		if #available(iOS 13.0, *) {
			backgroundContainerView.layer.cornerCurve = .continuous
		}
		backgroundContainerView.layer.cornerRadius = 15.0
		backgroundContainerView.layer.masksToBounds = true
		updateBorderWidth()

		backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(backgroundContainerView)

		contentTextView.translatesAutoresizingMaskIntoConstraints = false

		backgroundContainerView.addSubview(contentTextView)
		topSpaceLayoutConstraint = contentTextView.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 16.0)

		NSLayoutConstraint.activate(
			[
				backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0),
				backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0),
				backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				topSpaceLayoutConstraint,
				contentTextView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -16.0),
				contentTextView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16.0),
				contentTextView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16.0)
			]
		)
	}

	private func updateBorderWidth() {
		backgroundContainerView.layer.borderWidth = traitCollection.userInterfaceStyle == .dark ? 0 : 1
	}

}

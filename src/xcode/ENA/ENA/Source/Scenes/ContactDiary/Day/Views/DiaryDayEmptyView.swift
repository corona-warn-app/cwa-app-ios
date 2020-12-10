////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryDayEmptyView: UIView {

	// MARK: - Init

	@available(*, unavailable)
	override init(frame: CGRect) {
		fatalError("init(frame:) has not been implemented")
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	init(entryType: DiaryEntryType) {
		self.viewModel = DiaryDayEmptyViewModel(entryType: entryType)

		super.init(frame: .zero)

		setUp()
	}

	// MARK: - Private

	private let viewModel: DiaryDayEmptyViewModel

	private func setUp() {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.spacing = 12

		let imageView = UIImageView()
		imageView.image = viewModel.image
		stackView.addArrangedSubview(imageView)
		stackView.setCustomSpacing(30, after: imageView)

		let titleLabel = ENALabel()
		titleLabel.style = .headline
		titleLabel.textColor = .enaColor(for: .textPrimary1)
		titleLabel.textAlignment = .center
		titleLabel.numberOfLines = 0
		titleLabel.text = viewModel.title
		stackView.addArrangedSubview(titleLabel)

		let descriptionLabel = ENALabel()
		descriptionLabel.style = .subheadline
		descriptionLabel.textColor = .enaColor(for: .textPrimary2)
		descriptionLabel.textAlignment = .center
		descriptionLabel.numberOfLines = 0
		descriptionLabel.text = viewModel.description
		stackView.addArrangedSubview(descriptionLabel)

		addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			imageView.widthAnchor.constraint(equalToConstant: 200),
			imageView.heightAnchor.constraint(equalToConstant: 200),
			stackView.widthAnchor.constraint(lessThanOrEqualToConstant: 280),
			stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 50),
			stackView.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: 50),
			stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
			stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 30)
		])
	}

}

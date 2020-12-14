//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class DatePickerDayView: UIView {

	// MARK: - Init

	@available(*, unavailable)
	override init(frame: CGRect) {
		fatalError("init(frame:) has not been implemented")
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	init(viewModel: DatePickerDayViewModel) {
		self.viewModel = viewModel

		super.init(frame: .zero)

		setUp()
	}

	// MARK: - Overrides

	override func layoutSubviews() {
		super.layoutSubviews()

		layer.cornerRadius = bounds.width / 2
	}

	// MARK: - Private

	private let viewModel: DatePickerDayViewModel

	private var subscriptions = [AnyCancellable]()

	private let titleLabel = DynamicTypeLabel()

	private func setUp() {
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(titleLabel)

		NSLayoutConstraint.activate([
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			titleLabel.topAnchor.constraint(equalTo: topAnchor),
			titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
			titleLabel.heightAnchor.constraint(equalTo: titleLabel.widthAnchor)
		])

		titleLabel.numberOfLines = 0
		titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
		titleLabel.dynamicTypeSize = viewModel.fontSize
		titleLabel.text = viewModel.dayString
		titleLabel.textAlignment = .center
		titleLabel.adjustsFontSizeToFitWidth = true

		subscriptions = [
			viewModel.$backgroundColor.sink { [weak self] in self?.backgroundColor = $0 },
			viewModel.$textColor.assign(to: \.textColor, on: titleLabel),
			viewModel.$fontWeight.assign(to: \.dynamicTypeWeight, on: titleLabel),
			viewModel.$accessibilityTraits.assign(to: \.accessibilityTraits, on: self)
		]

		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
		addGestureRecognizer(tapGestureRecognizer)

		isAccessibilityElement = viewModel.isSelectable
		accessibilityLabel = viewModel.accessibilityLabel
		accessibilityIdentifier = AccessibilityIdentifiers.DatePickerOption.day
	}

	@objc
	private func viewTapped() {
		viewModel.onTap()
	}

}

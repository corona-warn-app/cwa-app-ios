//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class DatePickerOptionView: UIView {

	// MARK: - Init

	@available(*, unavailable)
	override init(frame: CGRect) {
		fatalError("init(frame:) has not been implemented")
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	init(title: String, today: Date, onTapOnDate: @escaping (Date) -> Void) {
		self.onTapOnDate = onTapOnDate
		self.viewModel = DatePickerOptionViewModel(today: today)

		super.init(frame: .zero)

		setUp(title: title)
	}
	// MARK: - Overrides

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		// Update selection state for dark mode (CGColors are not changed automatically)
		updateForSelectionState()
	}

	// MARK: - Internal

	var selectedDate: Date? {
		didSet {
			updateForSelectionState()
		}
	}

	// MARK: - Private

	private let onTapOnDate: (Date) -> Void
	private let viewModel: DatePickerOptionViewModel

	private var dayViewModels: [DatePickerDayViewModel] = []
	private let contentStackView = UIStackView()

	private func setUp(title: String) {
		backgroundColor = UIColor.enaColor(for: .background)

		layer.cornerRadius = 10

		layer.shadowOffset = CGSize(width: 0, height: 2)
		layer.shadowRadius = 2
		layer.shadowOpacity = 1

		layer.masksToBounds = false

		contentStackView.axis = .vertical
		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(contentStackView)

		NSLayoutConstraint.activate([
			contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
			contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
			contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
			contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
		])

		let titleStackView = UIStackView()
		titleStackView.isLayoutMarginsRelativeArrangement = true
		titleStackView.directionalLayoutMargins = .init(top: 0, leading: 12, bottom: 0, trailing: -12)
		titleStackView.axis = .vertical
		titleStackView.spacing = 6

		let titleLabel = ENALabel()
		titleLabel.numberOfLines = 0
		titleLabel.style = .headline
		titleLabel.text = title

		titleStackView.addArrangedSubview(titleLabel)

		let subtitleLabel = ENALabel()
		subtitleLabel.numberOfLines = 0
		subtitleLabel.style = .footnote
		subtitleLabel.text = viewModel.subtitle

		titleStackView.addArrangedSubview(subtitleLabel)

		contentStackView.addArrangedSubview(titleStackView)
		contentStackView.setCustomSpacing(20, after: titleStackView)

		let weekdayStackView = dayStackView()
		for (index, weekday) in viewModel.weekdays.enumerated() {
			let weekdayLabel = DynamicTypeLabel()
			weekdayLabel.font = UIFont.preferredFont(forTextStyle: .body)
			weekdayLabel.numberOfLines = 0
			weekdayLabel.dynamicTypeSize = 11
			weekdayLabel.dynamicTypeWeight = "bold"
			weekdayLabel.textColor = viewModel.weekdayTextColors[index]
			weekdayLabel.textAlignment = .center
			weekdayLabel.text = weekday

			weekdayStackView.addArrangedSubview(weekdayLabel)
		}
		contentStackView.addArrangedSubview(weekdayStackView)
		contentStackView.setCustomSpacing(8, after: weekdayStackView)

		let dayStackViews: [UIStackView] = [dayStackView(), dayStackView(), dayStackView(), dayStackView()]
		dayStackViews.forEach {
			contentStackView.addArrangedSubview($0)
			contentStackView.setCustomSpacing(4, after: $0)
		}

		for (index, datePickerDay) in viewModel.datePickerDays.enumerated() {
			let dayViewModel = DatePickerDayViewModel(
				datePickerDay: datePickerDay,
				onTapOnDate: { [weak self] date in
					self?.onTapOnDate(date)
				}
			)
			let datePickerDayView = DatePickerDayView(viewModel: dayViewModel)

			dayViewModels.append(dayViewModel)
			dayStackViews[index / 7].addArrangedSubview(datePickerDayView)
		}

		accessibilityElements = [titleLabel, subtitleLabel] + dayStackViews.map { $0.arrangedSubviews.filter { $0.isAccessibilityElement } }

		updateForSelectionState()
	}

	private func dayStackView() -> UIStackView {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.distribution = .fillEqually
		stackView.spacing = 4

		return stackView
	}

	private func updateForSelectionState() {
		for dayViewModel in dayViewModels {
			if let selectedDate = selectedDate {
				dayViewModel.selectIfSameDate(date: selectedDate)
			} else {
				dayViewModel.isSelected = false
			}
		}

		layer.shadowColor = UIColor.enaColor(for: .shadow).cgColor

		let isSelected = selectedDate != nil
		layer.borderWidth = isSelected ? 2 : 1
		layer.borderColor = isSelected ? UIColor.enaColor(for: .buttonPrimary).cgColor : UIColor.enaColor(for: .hairline).cgColor
	}

}

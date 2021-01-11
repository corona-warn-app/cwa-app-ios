//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class OptionGroupView: UIView {

	enum OptionViewType {
		case option(OptionView)
		case multipleChoiceOption(MultipleChoiceOptionView)
		case datePickerOption(DatePickerOptionView)
	}

	// MARK: - Init

	@available(*, unavailable)
	override init(frame: CGRect) {
		fatalError("init(frame:) has not been implemented")
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	init(viewModel: OptionGroupViewModel) {
		self.viewModel = viewModel

		super.init(frame: .zero)

		setUp()
	}

	// MARK: - Private

	private let viewModel: OptionGroupViewModel

	private let contentStackView = UIStackView()
	private var optionViews: [OptionViewType] = []

	private var selectionSubscription: AnyCancellable?

	private func setUp() {
		contentStackView.axis = .vertical
		contentStackView.spacing = 14

		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(contentStackView)

		NSLayoutConstraint.activate([
			contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			contentStackView.topAnchor.constraint(equalTo: topAnchor),
			contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])

		for optionIndex in 0..<viewModel.options.count {
			let option = viewModel.options[optionIndex]

			switch option {
			case let .option(title, id):
				let view = optionView(title: title, accessibilityIdentifier: id, index: optionIndex)
				optionViews.append(.option(view))
				contentStackView.addArrangedSubview(view)
			case let .multipleChoiceOption(title, choices, id):
				let view = multipleChoiceOptionView(title: title, choices: choices, accessibilityIdentifier: id, index: optionIndex)
				optionViews.append(.multipleChoiceOption(view))
				contentStackView.addArrangedSubview(view)
			case let .datePickerOption(title, today, accessibilityIdentifier):
				let view = datePickerOptionView(title: title, today: today, accessibilityIdentifier: accessibilityIdentifier, index: optionIndex)
				optionViews.append(.datePickerOption(view))
				contentStackView.addArrangedSubview(view)
			}
		}

		selectionSubscription = viewModel.$selection.sink { [weak self] selection in
			DispatchQueue.main.async {
				self?.updateOptionViews(for: selection)
			}
		}

		isAccessibilityElement = false
	}

	private func optionView(title: String, accessibilityIdentifier: String?, index: Int) -> OptionView {
		let view = OptionView(
			title: title,
			onTap: { [weak self] in
				self?.viewModel.optionTapped(index: index)
			}
		)
		view.accessibilityIdentifier = accessibilityIdentifier

		return view
	}

	private func multipleChoiceOptionView(title: String, choices: [OptionGroupViewModel.Choice], accessibilityIdentifier: String?, index: Int) -> MultipleChoiceOptionView {
		let view = MultipleChoiceOptionView(
			title: title,
			choices: choices,
			onTapOnChoice: { [weak self] choiceIndex in
				self?.viewModel.multipleChoiceOptionTapped(index: index, choiceIndex: choiceIndex)
			}
		)
		view.accessibilityIdentifier = accessibilityIdentifier

		return view
	}

	private func datePickerOptionView(title: String, today: Date, accessibilityIdentifier: String?, index: Int) -> DatePickerOptionView {
		let view = DatePickerOptionView(
			title: title,
			today: today,
			onTapOnDate: { [weak self] date in
				self?.viewModel.datePickerOptionTapped(index: index, date: date)
			}
		)
		view.accessibilityIdentifier = accessibilityIdentifier

		return view
	}

	private func deselectAllViews() {
		for viewIndex in 0..<self.optionViews.count {
			switch optionViews[viewIndex] {
			case .option(let view):
				view.isSelected = false
			case .multipleChoiceOption(let view):
				view.selectedChoices = []
			case .datePickerOption(let view):
				view.selectedDate = nil
			}
		}
	}

	private func updateOptionViews(for selection: OptionGroupViewModel.Selection?) {
		deselectAllViews()

		if case let .option(index: index) = selection, case let .option(view) = optionViews[index] {
			view.isSelected = true
		}

		if case let .multipleChoiceOption(index: index, selectedChoices: selectedChoices) = selection, case let .multipleChoiceOption(view) = optionViews[index] {
			view.selectedChoices = selectedChoices
		}

		if case let .datePickerOption(index: index, selectedDate: selectedDate) = selection, case let .datePickerOption(view) = optionViews[index] {
			view.selectedDate = selectedDate
		}
	}

}

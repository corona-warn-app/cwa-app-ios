////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

class DMDatePickerTableViewCell: UITableViewCell, ConfigureableCell {

	// MARK: - Overrides

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		createAndLayoutViewHierarchy()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	var didSelectDate: ((Date) -> Void)?

	func configure<T>(cellViewModel: T) {
		guard let cellViewModel = cellViewModel as? DMDatePickerCellViewModel else {
			fatalError("CellViewModel doesn't macht expecations")
		}

		titleLabel.text = cellViewModel.title

		datePicker.datePickerMode = cellViewModel.datePickerMode
		datePicker.date = cellViewModel.date
		datePicker.addTarget(self, action: #selector(didSelectDate(datePicker:)), for: .valueChanged)
		datePicker.accessibilityIdentifier = cellViewModel.accessibilityIdentifier
	}

	// MARK: - Private

	private var stackView: UIStackView = {
		let stackView = UIStackView(frame: .zero)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		return stackView
	}()

	private var titleLabel: ENALabel = {
		let label = ENALabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.style = .body
		label.numberOfLines = 0
		return label
	}()

	private var datePicker: UIDatePicker = {
		let datePicker = UIDatePicker(frame: .zero)
		if #available(iOS 15.0, *) {
			datePicker.preferredDatePickerStyle = .inline
		} else if #available(iOS 13.4, *) {
			datePicker.preferredDatePickerStyle = .wheels
		}
		datePicker.translatesAutoresizingMaskIntoConstraints = false
		datePicker.setContentHuggingPriority(.required, for: .horizontal)
		datePicker.setContentCompressionResistancePriority(.required, for: .horizontal)
		return datePicker
	}()

	@objc
	private func didSelectDate(datePicker: UIDatePicker) {
		didSelectDate?(datePicker.date)
	}

	private func createAndLayoutViewHierarchy() {
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(datePicker)
		contentView.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 16),
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
		])
	}
}

#endif

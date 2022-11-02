////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class OnBehalfDateSelectionCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
		backgroundColor = .clear
		accessibilityIdentifier = AccessibilityIdentifiers.OnBehalfCheckinSubmission.DateTimeSelection.dateCell
		accessibilityTraits = .button
		createAndLayoutViewHierarchy()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	var didSelectDate: ((Date) -> Void)?

	var selectedDate: Date? {
		didSet {
			if let date = selectedDate {
				selectedDateTimeLabel.text = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
				datePicker.date = date
			} else {
				selectedDateTimeLabel.text = ""
			}
		}
	}

	var isCollapsed: Bool = true {
		didSet {
			datePicker.isHidden = isCollapsed
			separator.isHidden = isCollapsed
			selectedDateTimeLabel.textColor = isCollapsed ? .enaColor(for: .textPrimary1) : .enaColor(for: .textTint)
		}
	}

	// MARK: - Private

	private lazy var cardContainer: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .enaColor(for: .cellBackground3)
		view.layer.cornerRadius = 8
		return view
	}()

	private lazy var containerStackView: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .vertical
		stack.spacing = 15
		return stack
	}()

	private lazy var selectedDateTimeLabel: UILabel = {
		let label = ENALabel()
		label.numberOfLines = 0
		label.setContentHuggingPriority(.required, for: .horizontal)
		label.textAlignment = .right
		label.font = .enaFont(for: .headline, weight: .semibold)
		return label
	}()

	private lazy var selectedDateTimeTitle: UILabel = {
		let label = ENALabel(style: .body)
		label.text = AppStrings.OnBehalfCheckinSubmission.DateTimeSelection.start
		label.numberOfLines = 0
		return label
	}()

	private lazy var selectedDateTimeStackView: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .horizontal
		stack.distribution = .fillProportionally
		return stack
	}()

	private lazy var datePicker: UIDatePicker = {
		let datePicker = UIDatePicker()
		datePicker.translatesAutoresizingMaskIntoConstraints = false
		datePicker.datePickerMode = .dateAndTime
		datePicker.tintColor = .enaColor(for: .tint)
		datePicker.maximumDate = Date()

		if #available(iOS 15.0, *) {
			datePicker.preferredDatePickerStyle = .inline
		} else if #available(iOS 13.4, *) {
			datePicker.preferredDatePickerStyle = .wheels
		}

		datePicker.addTarget(self, action: #selector(didSelectDate(datePicker:)), for: .valueChanged)

		return datePicker
	}()

	private lazy var separator: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .enaColor(for: .hairline)
		return view
	}()

	private func createAndLayoutViewHierarchy() {
		contentView.addSubview(cardContainer)
		NSLayoutConstraint.activate([
			cardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			cardContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
			cardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			cardContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])

		cardContainer.addSubview(containerStackView)
		NSLayoutConstraint.activate([
			containerStackView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 16),
			containerStackView.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 12),
			containerStackView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -16),
			containerStackView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: -12)
		])

		containerStackView.addArrangedSubview(selectedDateTimeStackView)
		containerStackView.addArrangedSubview(datePicker)

		selectedDateTimeStackView.addArrangedSubview(selectedDateTimeTitle)
		selectedDateTimeStackView.addArrangedSubview(selectedDateTimeLabel)

		cardContainer.addSubview(separator)

		NSLayoutConstraint.activate([
			separator.heightAnchor.constraint(equalToConstant: 1),
			separator.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
			separator.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
			separator.topAnchor.constraint(equalTo: selectedDateTimeStackView.bottomAnchor, constant: 8)
		])
	}

	@objc
	private func didSelectDate(datePicker: UIDatePicker) {
		selectedDate = datePicker.date
		didSelectDate?(datePicker.date)
	}

}

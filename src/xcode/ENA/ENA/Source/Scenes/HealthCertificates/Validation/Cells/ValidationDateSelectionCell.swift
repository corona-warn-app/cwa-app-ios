////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class ValidationDateSelectionCell: UITableViewCell {

	static let reuseIdentifier = "\(ValidationDateSelectionCell.self)"

	var didSelectDate: ((Date) -> Void)?

	var selectedDate: Date? {
		didSet {
			selectedDateLabel.text = "\(selectedDate?.timeIntervalSince1970)"
		}
	}

	private lazy var containerStackView: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.alignment = .fill
		stack.distribution = .fill
		stack.axis = .vertical
		return stack
	}()

	private lazy var selectedDateLabel: UILabel = {
		let label = UILabel()
		label.text = "Deutschland"
		label.numberOfLines = 0
		return label
	}()

	private lazy var selectedDateTitle: UILabel = {
		let label = UILabel()
		label.text = "Zu prüfendes Land"
		label.numberOfLines = 0
		return label
	}()

	private lazy var selectedDateStackView: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.alignment = .fill
		stack.distribution = .fill
		stack.axis = .horizontal
		return stack
	}()

	private lazy var datePicker: UIDatePicker = {
		let datePicker = UIDatePicker()
		datePicker.translatesAutoresizingMaskIntoConstraints = false
		datePicker.datePickerMode = .date
		if #available(iOS 14.0, *) {
			datePicker.preferredDatePickerStyle = .inline
		} else if #available(iOS 13.4, *) {
			datePicker.preferredDatePickerStyle = .wheels
		}

		datePicker.addTarget(self, action: #selector(didSelectDate(datePicker:)), for: .valueChanged)

		return datePicker
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
		createAndLayoutViewHierarchy()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func createAndLayoutViewHierarchy() {
		contentView.addSubview(containerStackView)
		NSLayoutConstraint.activate([
			containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
			containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])

		containerStackView.addArrangedSubview(selectedDateStackView)
		containerStackView.addArrangedSubview(datePicker)

		selectedDateStackView.addArrangedSubview(selectedDateTitle)
		selectedDateStackView.addArrangedSubview(selectedDateLabel)
	}

	@objc
	private func didSelectDate(datePicker: UIDatePicker) {
		selectedDate = datePicker.date
		didSelectDate?(datePicker.date)
	}

	func toggle(state: Bool) {
		datePicker.isHidden = state
	}
}

////
// 🦠 Corona-Warn-App
//

import UIKit

class CheckInDatePickerCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	func configure(_ cellModel: CheckInTimeModel) {
		self.cellModel = cellModel
		startTimeDatePicker.date = cellModel.date
	}

	// MARK: - Private

	private lazy var startTimeDatePicker: UIDatePicker = {
		let datePicker = UIDatePicker()

		if #available(iOS 14.0, *) {
			datePicker.preferredDatePickerStyle = .inline
		}
		datePicker.datePickerMode = .dateAndTime
		datePicker.tintColor = .enaColor(for: .tint)
		return datePicker
	}()

	private var cellModel: CheckInTimeModel!

	private func setupView() {
		selectionStyle = .none
		backgroundColor = .enaColor(for: .cellBackground)
		contentView.backgroundColor = .enaColor(for: .cellBackground)

		let tileView = UIView()
		tileView.translatesAutoresizingMaskIntoConstraints = false
		tileView.backgroundColor = .enaColor(for: .darkBackground)
		contentView.addSubview(tileView)

		startTimeDatePicker.translatesAutoresizingMaskIntoConstraints = false
		tileView.addSubview(startTimeDatePicker)
		startTimeDatePicker.addTarget(self, action: #selector(updateDate(sender:)), for: .valueChanged)

		NSLayoutConstraint.activate(
			[
				tileView.topAnchor.constraint(equalTo: contentView.topAnchor),
				tileView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
				tileView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				tileView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				startTimeDatePicker.topAnchor.constraint(equalTo: tileView.topAnchor, constant: 14.0),
				startTimeDatePicker.bottomAnchor.constraint(equalTo: tileView.bottomAnchor, constant: -14.0),
				startTimeDatePicker.leadingAnchor.constraint(equalTo: tileView.leadingAnchor, constant: 16.0),
				startTimeDatePicker.trailingAnchor.constraint(equalTo: tileView.trailingAnchor, constant: -16.0)
			]
		)
	}

	@objc
	private func updateDate(sender: UIDatePicker) {
		cellModel.date = sender.date
	}

}

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

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	func configure(_ cellModel: CheckInTimeModel) {
//		typeLabel.text = cellModel.type
//		dateLabel.text = cellModel.dateString
//		timeLabel.text = cellModel.timeString
	}

	// MARK: - Private

//	private let typeLabel = ENALabel()
//	private let dateLabel = ENALabel()
//	private let timeLabel = ENALabel()

	private lazy var startTimeDatePicker: UIDatePicker = {
		let datePicker = UIDatePicker()

		if #available(iOS 14.0, *) {
			datePicker.preferredDatePickerStyle = .inline
		}
		datePicker.locale = Locale(identifier: "de_DE")
		datePicker.datePickerMode = .dateAndTime
//		datePicker.alpha = 0.0
//		datePicker.isHidden = true
		return datePicker
	}()


	private func setupView() {
		selectionStyle = .none
		backgroundColor = .green // .enaColor(for: .cellBackground)
		contentView.backgroundColor = .enaColor(for: .cellBackground)

		let tileView = UIView()
		tileView.translatesAutoresizingMaskIntoConstraints = false
		tileView.backgroundColor = .enaColor(for: .background)
//		tileView.layer.cornerRadius = 12.0
//		tileView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//		tileView.layer.masksToBounds = true
//		tileView.layer.borderWidth = 1.0
//		tileView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
		contentView.addSubview(tileView)

		startTimeDatePicker.translatesAutoresizingMaskIntoConstraints = false
		tileView.addSubview(startTimeDatePicker)

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

}

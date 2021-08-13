////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class OnBehalfDurationSelectionCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
		backgroundColor = .clear
		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Validation.countrySelection
		accessibilityTraits = .button
		createAndLayoutViewHierarchy()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	var didSelectDuration: ((TimeInterval) -> Void)?

	var selectedDuration: TimeInterval = 15 * 60 {
		didSet {
			selectedDurationLabel.text = formattedDuration(for: selectedDuration)
			picker.countDownDuration = selectedDuration
		}
	}

	var isCollapsed: Bool = true {
		didSet {
			picker.isHidden = isCollapsed
			separator.isHidden = isCollapsed
			selectedDurationLabel.textColor = isCollapsed ? .enaColor(for: .textPrimary1) : .enaColor(for: .textTint)

			// Need to set the countDownDuration after unhiding, otherwise the first valueChanged event is not triggered
			if !isCollapsed {
				DispatchQueue.main.async {
					self.picker.countDownDuration = self.selectedDuration
				}
			}
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

	private lazy var selectedDurationLabel: UILabel = {
		let label = ENALabel(style: .headline)
		label.numberOfLines = 0
		label.setContentHuggingPriority(.required, for: .horizontal)
		label.textAlignment = .right
		label.font = .enaFont(for: .headline, weight: .semibold)
		return label
	}()

	private lazy var selectedDurationTitle: UILabel = {
		let label = ENALabel(style: .body)
		label.text = AppStrings.OnBehalfCheckinSubmission.DateTimeSelection.duration
		label.numberOfLines = 0
		label.setContentHuggingPriority(.required, for: .horizontal)
		return label
	}()

	private lazy var selectedDurationStackView: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .horizontal
		stack.distribution = .fillProportionally
		stack.spacing = 5
		return stack
	}()

	private lazy var picker: UIDatePicker = {
		let picker = UIDatePicker()
		picker.translatesAutoresizingMaskIntoConstraints = false
		picker.tintColor = .enaColor(for: .tint)
		picker.datePickerMode = .countDownTimer
		picker.minuteInterval = 15
		picker.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: .valueChanged)
		return picker
	}()

	private lazy var separator: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .enaColor(for: .hairline)
		return view
	}()

	private lazy var durationFormatter: DateComponentsFormatter = {
		let dateComponentsFormatter = DateComponentsFormatter()
		dateComponentsFormatter.allowedUnits = [.hour, .minute]
		dateComponentsFormatter.unitsStyle = .positional
		dateComponentsFormatter.zeroFormattingBehavior = .pad

		return dateComponentsFormatter
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

		containerStackView.addArrangedSubview(selectedDurationStackView)
		containerStackView.addArrangedSubview(picker)

		selectedDurationStackView.addArrangedSubview(selectedDurationTitle)
		selectedDurationStackView.addArrangedSubview(selectedDurationLabel)

		cardContainer.addSubview(separator)

		NSLayoutConstraint.activate([
			separator.heightAnchor.constraint(equalToConstant: 1),
			separator.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
			separator.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
			separator.topAnchor.constraint(equalTo: selectedDurationStackView.bottomAnchor, constant: 8)
		])
	}

	@objc
	func datePickerValueChanged(sender: UIDatePicker) {
		selectedDurationLabel.text = formattedDuration(for: sender.countDownDuration)
		didSelectDuration?(sender.countDownDuration)
	}

	func formattedDuration(for timeInterval: TimeInterval) -> String {
		guard let formattedDuration = durationFormatter.string(from: timeInterval) else {
			return ""
		}

		return String(
			format: AppStrings.TraceLocations.Configuration.hoursUnit,
			formattedDuration
		)
	}

}

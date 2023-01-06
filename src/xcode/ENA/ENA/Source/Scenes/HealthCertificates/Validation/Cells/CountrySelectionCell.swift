////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class CountrySelectionCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

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

	var didSelectCountry: ((Country) -> Void)?

	var countries: [Country] = [] {
		didSet {
			picker.reloadAllComponents()
		}
	}

	var selectedCountry: Country? {
		didSet {
			selectedCountryLabel.text = selectedCountry?.localizedName

			if let selectedCountry = selectedCountry,
				let countryIndex = countries.firstIndex(of: selectedCountry) {
				picker.selectRow(countryIndex, inComponent: 0, animated: false)
			}
		}
	}

	var isCollapsed: Bool = true {
		didSet {
			picker.isHidden = isCollapsed
			separator.isHidden = isCollapsed
			selectedCountryLabel.textColor = isCollapsed ? .enaColor(for: .textPrimary1) : .enaColor(for: .textTint)
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
		return stack
	}()

	private lazy var selectedCountryLabel: UILabel = {
		let label = ENALabel(style: .headline)
		label.numberOfLines = 0
		label.textAlignment = .right
		return label
	}()

	private lazy var selectedCountryTitle: UILabel = {
		let label = ENALabel(style: .body)
		label.text = AppStrings.HealthCertificate.Validation.countrySelectionTitle
		label.numberOfLines = 0
		label.setContentHuggingPriority(.required, for: .horizontal)
		return label
	}()

	private lazy var selectedCountryStackView: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .horizontal
		stack.distribution = .fillProportionally
		stack.spacing = 5
		return stack
	}()

	private lazy var picker: UIPickerView = {
		let picker = UIPickerView()
		picker.translatesAutoresizingMaskIntoConstraints = false
		picker.delegate = self
		picker.tintColor = .enaColor(for: .tint)
		return picker
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
			cardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 17),
			cardContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
			cardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -17),
			cardContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])

		cardContainer.addSubview(containerStackView)
		NSLayoutConstraint.activate([
			containerStackView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 19),
			containerStackView.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 8),
			containerStackView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -19),
			containerStackView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: -8)
		])

		containerStackView.addArrangedSubview(selectedCountryStackView)
		containerStackView.addArrangedSubview(picker)

		selectedCountryStackView.addArrangedSubview(selectedCountryTitle)
		selectedCountryStackView.addArrangedSubview(selectedCountryLabel)

		cardContainer.addSubview(separator)

		NSLayoutConstraint.activate([
			separator.heightAnchor.constraint(equalToConstant: 1),
			separator.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
			separator.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
			separator.topAnchor.constraint(equalTo: selectedCountryStackView.bottomAnchor, constant: 8)
		])
	}

	// MARK: - Protocol UIPickerViewDataDelegate

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return countries[row].localizedName
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		selectedCountryLabel.text = countries[row].localizedName
		didSelectCountry?(countries[row])
	}

	// MARK: - Protocol UIPickerViewDataSouce

	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return countries.count
	}

}

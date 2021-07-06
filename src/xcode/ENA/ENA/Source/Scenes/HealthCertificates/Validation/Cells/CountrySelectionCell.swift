////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class CountrySelectionCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

	static let reuseIdentifier = "\(CountrySelectionCell.self)"

	var didSelectCountry: ((Country) -> Void)?

	var countries: [Country] = [] {
		didSet {
			picker.reloadAllComponents()
		}
	}

	var selectedCountry: Country? {
		didSet {
			selectedCountryLabel.text = selectedCountry?.localizedName
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

	private lazy var selectedCountryLabel: UILabel = {
		let label = UILabel()
		label.text = "Deutschland"
		label.numberOfLines = 0
		return label
	}()

	private lazy var selectedCountryTitle: UILabel = {
		let label = UILabel()
		label.text = "Zu prüfendes Land"
		label.numberOfLines = 0
		return label
	}()

	private lazy var selectedCountryStackView: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.alignment = .fill
		stack.distribution = .fill
		stack.axis = .horizontal
		return stack
	}()

	private lazy var picker: UIPickerView = {
		let picker = UIPickerView()
		picker.translatesAutoresizingMaskIntoConstraints = false
		picker.delegate = self
		return picker
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

		containerStackView.addArrangedSubview(selectedCountryStackView)
		containerStackView.addArrangedSubview(picker)

		selectedCountryStackView.addArrangedSubview(selectedCountryTitle)
		selectedCountryStackView.addArrangedSubview(selectedCountryLabel)
	}

	func toggle(state: Bool) {
		picker.isHidden = state
	}

	// UIPickerViewDataDelegate

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return countries[row].localizedName
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		selectedCountryLabel.text = countries[row].localizedName
		didSelectCountry?(countries[row])
	}

	// UIPickerViewDataSouce

	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return countries.count
	}

}

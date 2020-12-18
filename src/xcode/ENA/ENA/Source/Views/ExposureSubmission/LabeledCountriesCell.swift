////
// 🦠 Corona-Warn-App
//

import UIKit

@IBDesignable
class LabeledCountriesCell: UITableViewCell {

	@IBOutlet private var countriesView: LabeledCountriesView!

	static let reuseIdentifier = "LabeledCountriesCell"
	
	override func awakeFromNib() {
		super.awakeFromNib()

		setup()
	}

	func configure(countriesList countries: [Country], accessibilityIdentifier: String? = nil) {
		countriesView.countries = countries

		self.accessibilityIdentifier = accessibilityIdentifier
	}
	
	// MARK: - Private
	
	private func setup() {
		backgroundColor = .clear
	}

}

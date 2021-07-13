//
// 🦠 Corona-Warn-App
//

import UIKit
import Contacts
import OpenCombine

final class HealthCertificateValidationViewModel {

	// MARK: - Init

	init(
		healthCertificate: HealthCertificate,
		countries: [ValidationCountryCode],
		store: HealthCertificateStoring,
		onValidationButtonTap: @escaping (Country, Date) -> Void
	) {
		self.healthCertificate = healthCertificate
		self.countries = countries
		self.store = store
		self.onValidationButtonTap = onValidationButtonTap
	}

	// MARK: - Internal

	var selectedArrivalCountry = Country.defaultCountry()
	var selectedArrivalDate = Date()

	func validate() {
		onValidationButtonTap(selectedArrivalCountry, selectedArrivalDate)
	}

	// MARK: - Private

	private let healthCertificate: HealthCertificate
	private let countries: [ValidationCountryCode]
	private let store: HealthCertificateStoring
	private let onValidationButtonTap: (Country, Date) -> Void

}

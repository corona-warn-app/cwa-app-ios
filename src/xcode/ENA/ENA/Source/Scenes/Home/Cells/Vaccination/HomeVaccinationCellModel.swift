////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeVaccinationCellModel {

	// MARK: - Init

	init(
		healthCertifiedPerson: HealthCertifiedPerson,
		onUpdate: @escaping () -> Void
	) {
		self.healthCertifiedPerson = healthCertifiedPerson
		healthCertifiedPerson.$hasValidProofCertificate.sink { isValid in
			self.isProgressLabelHidden = isValid
			self.backgroundColor = isValid ? .enaColor(for: .buttonPrimary) : .enaColor(for: .riskNeutral)
			self.iconimage = isValid ? UIImage(named: "Vaccination_full") : UIImage(named: "Vacc_Incomplete")
			self.vaccinatedPersonName = healthCertifiedPerson.fullName
			onUpdate()
		}.store(in: &subscriptions)
	}
	
	// MARK: - Internal

	@OpenCombine.Published var vaccinatedPersonName: String?
	@OpenCombine.Published var isProgressLabelHidden: Bool = false
	@OpenCombine.Published var backgroundColor: UIColor! = .enaColor(for: .riskNeutral)
	@OpenCombine.Published var iconimage: UIImage?

	// MARK: - Private

	private let healthCertifiedPerson: HealthCertifiedPerson
	private var subscriptions = Set<AnyCancellable>()
}

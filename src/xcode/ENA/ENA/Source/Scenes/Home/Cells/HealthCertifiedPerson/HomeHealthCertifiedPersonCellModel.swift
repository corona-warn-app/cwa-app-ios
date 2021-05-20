////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeHealthCertifiedPersonCellModel {

	// MARK: - Init

	init(
		healthCertifiedPerson: HealthCertifiedPerson
	) {
		self.healthCertifiedPerson = healthCertifiedPerson

		healthCertifiedPerson.$vaccinationState
			.sink { [weak self] in
				self?.backgroundGradientType = $0 == .completelyProtected ? .lightBlue : .solidGrey
				self?.iconImage = $0 == .partiallyVaccinated ? UIImage(named: "Vacc_Incomplete") : UIImage(named: "Vaccination_full")
				self?.name = healthCertifiedPerson.fullName

				switch $0 {
				case .partiallyVaccinated:
					self?.vaccinationState = AppStrings.HealthCertificate.Home.Person.partiallyVaccinated
				case .fullyVaccinated(daysUntilCompleteProtection: let daysUntilCompleteProtection):
					self?.vaccinationState = String(
						format: AppStrings.HealthCertificate.Home.Person.daysUntilCompleteProtection,
						daysUntilCompleteProtection
					)
				case .completelyProtected:
					self?.vaccinationState = nil
				}
			}
			.store(in: &subscriptions)
	}
	
	// MARK: - Internal

	@OpenCombine.Published var vaccinationState: String?
	@OpenCombine.Published var backgroundGradientType: GradientView.GradientType = .solidGrey
	@OpenCombine.Published var iconImage: UIImage?
	@OpenCombine.Published var name: String?

	// MARK: - Private

	private let healthCertifiedPerson: HealthCertifiedPerson
	private var subscriptions = Set<AnyCancellable>()

}

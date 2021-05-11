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
			self.isVerified = isValid
			onUpdate()
		}.store(in: &subscriptions)
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
			self.isVerified = true
			onUpdate()
		}
		healthCertifiedPerson.$proofCertificate.sink(receiveValue: { proofCertificate in
			guard let proofCertificate = proofCertificate else {
				self.vaccinatedPersonName = healthCertifiedPerson.healthCertificates.first?.name.fullName
				onUpdate()
				return
			}
			self.vaccinatedPersonName = proofCertificate.name.fullName
			onUpdate()
		})
			.store(in: &self.subscriptions)
	}
	
	// MARK: - Internal

	@OpenCombine.Published var vaccinatedPersonName: String?
	@OpenCombine.Published var isVerified: Bool = false

	// MARK: - Private

	private let healthCertifiedPerson: HealthCertifiedPerson
	private var subscriptions = Set<AnyCancellable>()
}

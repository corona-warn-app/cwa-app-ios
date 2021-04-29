////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class HealthCertificateService {

	// MARK: - Init

	init(
		store: HealthCertificateStoring
	) {
		self.store = store

		setup()
	}

	// MARK: - Internal

	@OpenCombine.Published /*private(set)*/ var healthCertifiedPersons: [HealthCertifiedPerson] = []

	func updatePublishersFromStore() {
		Log.info("[HealthCertificateService] Updating publishers from store", log: .api)

		healthCertifiedPersons = store.healthCertifiedPersons
	}

	// MARK: - Private

	private var store: HealthCertificateStoring

	private var subscriptions = Set<AnyCancellable>()

	private func setup() {
		updatePublishersFromStore()

		$healthCertifiedPersons
			.sink { [weak self] healthCertifiedPersons in
				self?.store.healthCertifiedPersons = healthCertifiedPersons
			}
			.store(in: &subscriptions)
	}

}

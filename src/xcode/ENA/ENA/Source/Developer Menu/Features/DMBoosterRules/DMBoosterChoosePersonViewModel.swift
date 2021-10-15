//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

final class DMBoosterChoosePersonViewModel {

	// MARK: - Init

	init(healthCertificateService: HealthCertificateService, store: Store) {
		self.healthCertificateService = healthCertificateService
		self.store = store
	}

	// MARK: - Internal
	
	var showViewController: (UIViewController) -> Void = { _ in }

	enum Sections: Int, CaseIterable {
		case expired
	}

	var numberOfSections: Int {
		healthCertificateService.healthCertifiedPersons.count
	}

	func items(section: Int) -> Int {
		let persons = healthCertificateService.healthCertifiedPersons
		return persons[section].healthCertificates.count
	}

	func cellViewModel(for indexPath: IndexPath) -> Any {
		let person = healthCertificateService.healthCertifiedPersons[indexPath.section]
		let numberOfCertificates = person.healthCertificates.count
		guard let name = person.name?.standardizedName else {
			fatalError("Failed to find matching identifier")
		}

		return DMButtonCellViewModel(
			text: "Booster rules for person: \(indexPath.section) - name: \(name) - certificates \(numberOfCertificates)",
			textColor: .enaColor(for: .textContrast),
			backgroundColor: .enaColor(for: .buttonPrimary),
			action: { [weak self] in
				guard let self = self else { return }
				let viewController = DMBoosterRulesViewController(store: self.store, healthCertificateService: self.healthCertificateService, healthCertifiedPerson: person)
				self.showViewController(viewController)
			}
		)
	}

	// MARK: - Private

	private let healthCertificateService: HealthCertificateService
	private let store: Store
}

#endif

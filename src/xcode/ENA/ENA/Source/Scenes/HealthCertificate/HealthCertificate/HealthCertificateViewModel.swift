////
// 🦠 Corona-Warn-App
//

import Foundation

final class HealthCertificateViewModel {

	// MARK: - Init

	init(
		// add healthCertificatePerson model later
	) {
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	func numberOfItems(in section: TableViewSection) -> Int {
		switch section {
		default:
			return 1
		}
	}

	enum TableViewSection: Int, CaseIterable {
		case topCorner
		case details
		case bottomCorner

		static var numberOfSections: Int {
			allCases.count
		}

		static func map(_ section: Int) -> TableViewSection {
			guard let section = TableViewSection(rawValue: section) else {
				fatalError("unsupported tableView section")
			}
			return section
		}
	}

	// MARK: - Private

}

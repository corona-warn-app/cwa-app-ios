////
// 🦠 Corona-Warn-App
//

import Foundation

struct AntigenTestProfileViewModel {

	// MARK: - Init
	init(
		store: AntigenTestProfileStoring
	) {
		self.store = store
		self.antigenTestProfile = store.antigenTestProfile
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	func deleteProfile() {
		store.antigenTestProfile = nil
	}

	var numberOfSections: Int {
		TableViewSections.allCases.count
	}

	func numberOfItems(in section: TableViewSections) -> Int {
		switch section {
		default:
			return 1
		}
	}

	var headerCellViewModel: SimpelTextCellViewModel {
		SimpelTextCellViewModel(
			backgroundColor: .clear,
			textColor: .enaColor(for: .textContrast),
			textAlignment: .center,
			text: AppStrings.ExposureSubmission.AntigenTest.Profile.headerText,
			topSpace: 42.0,
			font: .enaFont(for: .headline)
		)
	}

	// MARK: - Private

	enum TableViewSections: Int, CaseIterable {
		case header
//		case QRCode
//		case profile
//		case notice

		static func map(_ section: Int) -> TableViewSections {
			guard let section = TableViewSections(rawValue: section) else {
				fatalError("unsupported tableView section")
			}
			return section
		}
	}

	private let store: AntigenTestProfileStoring
	private var antigenTestProfile: AntigenTestProfile?
}

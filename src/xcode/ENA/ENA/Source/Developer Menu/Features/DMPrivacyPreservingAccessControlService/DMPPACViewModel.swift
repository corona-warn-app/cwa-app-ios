////
// 🦠 Corona-Warn-App
//
#if !RELEASE
import Foundation

final class DMPPCViewModel {
	
	// MARK: - Init
	
	init(
		_ store: Store,
		deviceCheck: DeviceCheckable) {
		self.ppacService = try? PPACService(store: store, deviceCheck: deviceCheck)
	}
	
	// MARK: - Public
	
	// MARK: - Internal
	
	var numberOfSections: Int {
		TableViewSections.allCases.count
	}
	
	func numberOfRows(in section: Int) -> Int {
		guard TableViewSections.allCases.indices.contains(section) else {
			return 0
		}
		// at the moment we assume one cell per section only
		return 1
	}
	
	func cellViewModel(by indexPath: IndexPath) -> Any {
		guard let section = TableViewSections(rawValue: indexPath.section) else {
			fatalError("Unknown cell requested - stop")
		}
		
		switch section {
		case .apiTokenWithCreatinDate:
			return DMKeyValueCellViewModel(key: "API Token", value: "12345")
		case .generateDeviceToken:
			return DMKeyValueCellViewModel(key: "renew", value: "tap to generate a new API Token")
		case .generateAPIToken:
			return DMKeyValueCellViewModel(key: "API Token", value: "A12345 \n tap to generate a new one")
		}
		
	}
	
	
	// MARK: - Private
	
	private enum TableViewSections: Int, CaseIterable {
		case apiTokenWithCreatinDate
		case generateDeviceToken
		case generateAPIToken
		// todo: force API Token authorization -> OTP
	}
	
	private let ppacService: PrivacyPreservingAccessControl?
	
}
#endif

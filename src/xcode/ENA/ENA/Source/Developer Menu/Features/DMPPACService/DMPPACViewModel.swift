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
		self.store = store
		self.ppacService = try? PPACService(store: store, deviceCheck: deviceCheck)
	}
	
	// MARK: - Public
	
	// MARK: - Internal

	var refreshTableView: (IndexSet) -> Void = { _ in }
	
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
			let ppacApiToken = store.ppacApiToken?.token ?? "no API Token generated yet"
			return DMKeyValueCellViewModel(key: "API Token", value: ppacApiToken)
		case .generateDeviceToken:
			return DMKeyValueCellViewModel(key: "Device Token", value: "tap to generate a new API Token")
		case .generateAPIToken:
			return DMButtonCellViewModel(text: "Generate API Token", textColor: .enaColor(for: .textPrimary1), backgroundColor: .enaColor(for: .buttonPrimary))
		}
	}

	func didTapCell(_ indexPath: IndexPath) {
		guard let section = TableViewSections(rawValue: indexPath.section) else {
			fatalError("Unknown cell requested - stop")
		}

		switch section {
//		case .generateDeviceToken:
//			<#code#>
		case .generateAPIToken:
			generatePpacAPIToken()
		default:
			break
		}

	}

	private func generatePpacAPIToken() {
		guard (ppacService?.generateNewAPIToken()) != nil else {
			return
		}
		refreshTableView([TableViewSections.apiTokenWithCreatinDate.rawValue])
	}

	// MARK: - Private
	
	private enum TableViewSections: Int, CaseIterable {
		case apiTokenWithCreatinDate
		case generateDeviceToken
		case generateAPIToken
		// todo: force API Token authorization -> OTP
	}

	private let store: Store
	private let ppacService: PrivacyPreservingAccessControl?

}
#endif

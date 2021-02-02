////
// 🦠 Corona-Warn-App
//
#if !RELEASE
import Foundation

final class DMPPCViewModel {
	
	// MARK: - Init
	
	init(
		_ store: Store,
		deviceCheck: DeviceCheckable
	) {
		self.store = store
		self.ppacService = try? PPACService(store: store, deviceCheck: deviceCheck)
	}
	
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

		case .deviceToken:
			var deviceTokenText: String
			switch lastKnownDeviceToken {
			case .none, .some(.failure):
				deviceTokenText = "no device token created"
			case .some(.success(let ppacToken)):
				deviceTokenText = ppacToken.deviceToken
			}
			return DMKeyValueCellViewModel(key: "Device Token", value: deviceTokenText)

		case .generateAPIToken:
			return DMButtonCellViewModel(
				text: "Generate new API Token",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: { [weak self] in
					self?.didTapCell(indexPath)
				}
			)

		case .generateDeviceToken:
			return DMButtonCellViewModel(
				text: "Generate Device Token",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: { [weak self] in
					self?.didTapCell(indexPath)
				}
			)
		}
	}

	// MARK: - Private

	private let store: Store
	private let ppacService: PrivacyPreservingAccessControl?
	private var lastKnownDeviceToken: Result<PPACToken, PPACError>?

	private func didTapCell(_ indexPath: IndexPath) {
		guard let section = TableViewSections(rawValue: indexPath.section) else {
			fatalError("Unknown cell requested - stop")
		}

		switch section {
		case .generateAPIToken:
			generatePpacAPIToken()
		case .generateDeviceToken:
			Log.debug("we need to create a device token")
			ppacService?.getPPACToken({ [weak self] result in
				self?.lastKnownDeviceToken = result
				self?.refreshTableView([TableViewSections.deviceToken.rawValue])
			})

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

	private enum TableViewSections: Int, CaseIterable {
		case apiTokenWithCreatinDate
		case generateAPIToken
		case deviceToken
		case generateDeviceToken
		// todo: force API Token authorization -> OTP
	}

}
#endif

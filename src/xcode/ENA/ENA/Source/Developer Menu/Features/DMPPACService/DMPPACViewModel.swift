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

	var deviceTokenText: String? {
		let deviceTokenText: String?
		switch lastKnownDeviceToken {
		case .none, .some(.failure):
			deviceTokenText = nil
		case .some(.success(let ppacToken)):
			deviceTokenText = ppacToken.deviceToken
		}
		return deviceTokenText
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
		case .ppacApiToken:
			let ppacApiToken = store.ppacApiToken?.token ?? "no API Token generated yet"
			return DMKeyValueCellViewModel(key: "API Token", value: ppacApiToken)

		case .ppacApiTokenLastChange:
			let creationDate: String
			if let timestamp = store.ppacApiToken?.timestamp {
				creationDate = DateFormatter.localizedString(from: timestamp, dateStyle: .medium, timeStyle: .medium)
			} else {
				creationDate = "unknown"
			}
			return DMKeyValueCellViewModel(key: "creation date", value: creationDate)

		case .deviceToken:
			let deviceTokenValue = deviceTokenText ?? "no device token created"
			return DMKeyValueCellViewModel(key: "Device Token", value: deviceTokenValue)

		case .generateAPIToken:
			return DMButtonCellViewModel(
				text: "Generate new API Token",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: { [weak self] in
					self?.generatePpacAPIToken()
				}
			)

		case .generateDeviceToken:
			return DMButtonCellViewModel(
				text: "Generate Device Token",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: { [weak self] in
					self?.ppacService?.getPPACToken({ [weak self] result in
						self?.lastKnownDeviceToken = result
						self?.refreshTableView([TableViewSections.deviceToken.rawValue])
					})

				}
			)
		}
	}

	// MARK: - Private

	private let store: Store
	private let ppacService: PrivacyPreservingAccessControl?
	private var lastKnownDeviceToken: Result<PPACToken, PPACError>?

	private func generatePpacAPIToken() {
		guard (ppacService?.generateNewAPIToken()) != nil else {
			return
		}
		refreshTableView(
			[TableViewSections.ppacApiToken.rawValue,
			 TableViewSections.ppacApiTokenLastChange.rawValue]
		)
	}

	private enum TableViewSections: Int, CaseIterable {
		case ppacApiToken
		case ppacApiTokenLastChange
		case generateAPIToken
		case deviceToken
		case generateDeviceToken
	}

}
#endif

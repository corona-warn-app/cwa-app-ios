////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

final class DMPPCViewModel {
	
	// MARK: - Init
	
	init(
		_ store: Store,
		ppacService: PrivacyPreservingAccessControl
	) {
		self.store = store
		self.ppacService = ppacService
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
		case .ppacEdusApiToken:
			let ppacEdusApiToken = store.ppacApiTokenEdus?.token ?? "no API Token generated yet"
			return DMKeyValueCellViewModel(key: "API Token", value: ppacEdusApiToken)

		case .ppacEdusApiTokenLastChange:
			let creationDate: String
			if let timestamp = store.ppacApiTokenEdus?.timestamp {
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
					self?.generateppacEdusApiToken()
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
		case .forceHTTPHeader:
			return DMSwitchCellViewModel(
				labelText: "Force API Token Authorization",
				isOn: { [store] in
					return store.forceAPITokenAuthorization
				},
				toggle: { [store] in
					store.forceAPITokenAuthorization.toggle()
				})
		}
	}

	// MARK: - Private

	private let store: Store
	private let ppacService: PrivacyPreservingAccessControl?
	private var lastKnownDeviceToken: Result<PPACToken, PPACError>?

	private func generateppacEdusApiToken() {
		guard (ppacService?.generateNewAPIToken()) != nil else {
			return
		}
		refreshTableView(
			[TableViewSections.ppacEdusApiToken.rawValue,
			 TableViewSections.ppacEdusApiTokenLastChange.rawValue]
		)
	}

	private enum TableViewSections: Int, CaseIterable {
		case ppacEdusApiToken
		case ppacEdusApiTokenLastChange
		case generateAPIToken
		case deviceToken
		case generateDeviceToken
		case forceHTTPHeader
	}

}
#endif

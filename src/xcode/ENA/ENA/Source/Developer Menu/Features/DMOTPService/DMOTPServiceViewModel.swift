////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

final class DMOTPServiceViewModel {

	// MARK: - Init

	init(
		store: Store,
		client: Client
	) {
		self.store = store
		self.otpService = OTPService(store: store, client: client)
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
		case .otpToken:
			let otpToken = store.otpToken?.token ?? "no OTP Token generated yet"
			return DMKeyValueCellViewModel(key: "OTP Token", value: otpToken)
		case .otpTimestamp:
			let creationDate: String
			if let timestamp = store.otpToken?.timestamp {
				creationDate = DateFormatter.localizedString(from: timestamp, dateStyle: .medium, timeStyle: .medium)
			} else {
				creationDate = "Due to no generated OTP Token, there is no timestamp"
			}
			return DMKeyValueCellViewModel(key: "otp timestamp", value: creationDate)
		case .otpExpirationDate:
			let expirationDate: String
			if let timestamp = store.otpToken?.expirationDate {
				expirationDate = DateFormatter.localizedString(from: timestamp, dateStyle: .medium, timeStyle: .medium)
			} else {
				expirationDate = "The OTP was not authorized and so has no expirationDate"
			}
			return DMKeyValueCellViewModel(key: "otp expiration date", value: expirationDate)
		case .discardOtp:
			return DMButtonCellViewModel(
				text: "Discard OTP Token",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: { [weak self] in
					self?.otpService.discardOTP()
					self?.refreshTableView([TableViewSections.otpToken.rawValue, TableViewSections.otpExpirationDate.rawValue, TableViewSections.otpTimestamp.rawValue])
				}
			)
		}

	}

	// MARK: - Private

	private enum TableViewSections: Int, CaseIterable {
		case otpToken
		case otpTimestamp
		case otpExpirationDate
		case discardOtp
	}

	private let store: Store
	private let otpService: OTPService

	private var lastKnownDeviceToken: Result<PPACToken, PPACError>?
}
#endif

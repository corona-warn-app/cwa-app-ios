////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

final class DMOTPServiceViewModel {

	// MARK: - Init

	init(
		store: Store,
		otpService: OTPServiceProviding
	) {
		self.store = store
		self.otpService = otpService
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

	// swiftlint:disable cyclomatic_complexity
	func cellViewModel(by indexPath: IndexPath) -> Any {
		guard let section = TableViewSections(rawValue: indexPath.section) else {
			fatalError("Unknown cell requested - stop")
		}

		switch section {
		case .otpEdusToken:
			let otpToken = store.otpTokenEdus?.token ?? "no OTP EDUS Token generated yet"
			return DMKeyValueCellViewModel(key: "OTP EDUS Token", value: otpToken)
		case .otpEdusTimestamp:
			let creationDate: String
			if let timestamp = store.otpTokenEdus?.timestamp {
				creationDate = DateFormatter.localizedString(from: timestamp, dateStyle: .medium, timeStyle: .medium)
			} else {
				creationDate = "Due to no generated OTP EDUS Token, there is no timestamp"
			}
			return DMKeyValueCellViewModel(key: "OTP EDUS timestamp", value: creationDate)
		case .otpEdusExpirationDate:
			let expirationDate: String
			if let timestamp = store.otpTokenEdus?.expirationDate {
				expirationDate = DateFormatter.localizedString(from: timestamp, dateStyle: .medium, timeStyle: .medium)
			} else {
				expirationDate = "The OTP EDUS was not authorized and so has no expirationDate"
			}
			return DMKeyValueCellViewModel(key: "OTP EDUS expiration date", value: expirationDate)
		case .otpEdusAuthorizationDate:
			let authorizationDate: String
			if let timestamp = store.otpEdusAuthorizationDate {
				authorizationDate = DateFormatter.localizedString(from: timestamp, dateStyle: .medium, timeStyle: .medium)
			} else {
				authorizationDate = "The OTP EDUS was not authorized and so has no authorizationDate"
			}
			return DMKeyValueCellViewModel(key: "OTP EDUS authorization date", value: authorizationDate)
		case .discardOtpEdus:
			return DMButtonCellViewModel(
				text: "Discard OTP EDUS Token",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: { [weak self] in
					self?.otpService.discardOTPEdus()
					self?.store.otpEdusAuthorizationDate = nil
					self?.refreshTableView([TableViewSections.otpEdusToken.rawValue, TableViewSections.otpEdusExpirationDate.rawValue, TableViewSections.otpEdusAuthorizationDate.rawValue, TableViewSections.otpEdusTimestamp.rawValue])
				}
			)
			
		case .otpElsToken:
			let otpToken = store.otpTokenEls?.token ?? "no OTP ELS Token generated yet"
			return DMKeyValueCellViewModel(key: "OTP ELS Token", value: otpToken)
		case .otpElsTimestamp:
			let creationDate: String
			if let timestamp = store.otpTokenEls?.timestamp {
				creationDate = DateFormatter.localizedString(from: timestamp, dateStyle: .medium, timeStyle: .medium)
			} else {
				creationDate = "Due to no generated OTP ELS Token, there is no timestamp"
			}
			return DMKeyValueCellViewModel(key: "OTP ELS timestamp", value: creationDate)
		case .otpElsExpirationDate:
			let expirationDate: String
			if let timestamp = store.otpTokenEls?.expirationDate {
				expirationDate = DateFormatter.localizedString(from: timestamp, dateStyle: .medium, timeStyle: .medium)
			} else {
				expirationDate = "The OTP ELS was not authorized and so has no expirationDate"
			}
			return DMKeyValueCellViewModel(key: "OTP ELS expiration date", value: expirationDate)
		case .otpElsAuthorizationDate:
			let authorizationDate: String
			if let timestamp = store.otpElsAuthorizationDate {
				authorizationDate = DateFormatter.localizedString(from: timestamp, dateStyle: .medium, timeStyle: .medium)
			} else {
				authorizationDate = "The OTP ELS was not authorized and so has no authorizationDate"
			}
			return DMKeyValueCellViewModel(key: "OTP ELS authorization date", value: authorizationDate)
		case .discardOtpEls:
			return DMButtonCellViewModel(
				text: "Discard OTP ELS Token",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonPrimary),
				action: { [weak self] in
					self?.otpService.discardOTPEls()
					self?.store.otpElsAuthorizationDate = nil
					self?.refreshTableView([TableViewSections.otpElsToken.rawValue, TableViewSections.otpElsExpirationDate.rawValue, TableViewSections.otpElsAuthorizationDate.rawValue, TableViewSections.otpElsTimestamp.rawValue])
				}
			)
		}
	}

	// MARK: - Private

	private enum TableViewSections: Int, CaseIterable {
		case otpEdusToken
		case otpEdusTimestamp
		case otpEdusExpirationDate
		case otpEdusAuthorizationDate
		case discardOtpEdus
		case otpElsToken
		case otpElsTimestamp
		case otpElsExpirationDate
		case otpElsAuthorizationDate
		case discardOtpEls
	}

	private let store: Store
	private let otpService: OTPServiceProviding

	private var lastKnownDeviceToken: Result<PPACToken, PPACError>?
}
#endif

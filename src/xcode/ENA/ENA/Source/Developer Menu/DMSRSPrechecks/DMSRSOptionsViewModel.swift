////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

final class DMSRSOptionsViewModel {
	
	// MARK: - Init
	
	init(
		store: Store
	) {
		self.store = store
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
		case .preChecks:
			return DMSwitchCellViewModel(
				labelText: "Enable pre-checks for SRS",
				isOn: { [store] in
					return store.dmIsSRSPreChecksEnabled
				},
				toggle: { [store] in
					store.dmIsSRSPreChecksEnabled.toggle()
				})
		case .srsStateValues:
			return DMStaticTextCellViewModel(
				staticText: srsStateValueStaticText(),
				font: .enaFont(for: .footnote),
				textColor: .enaColor(for: .textPrimary1),
				alignment: .left
			)
		case .mostRecentKeySubmission:
			return DMButtonCellViewModel(
				text: "Reset",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonDestructive),
				action: { [store] in
					store.mostRecentKeySubmissionDate = nil
					self.refreshTableView([TableViewSections.srsStateValues.rawValue])
				})
		}
	}

	// MARK: - Private

	private let store: Store
	
	private func srsStateValueStaticText() -> String {
	  """

	  MOST_RECENT_KEY_SUBMISSION
	  \(mostRecentKeySubmissionDateString(from: store.mostRecentKeySubmissionDate))

	  SRS_OTP
	  \(srsOTPString())

	  SRS_OTP_EXPIRATION_DATE
	  \(srsOTPExpirationDateString())

	  """
	}
	
	private func mostRecentKeySubmissionDateString(from: Date?) -> String {
		if let date = store.mostRecentKeySubmissionDate {
			return ISO8601DateFormatter.justLocalDateFormatter.string(from: date)
		} else {
			return "No Date set yet"
		}
	}
	
	private func srsOTPString() -> String {
		store.otpTokenSrs?.token ?? "No OTP Token set yet"
	}
	
	private func srsOTPExpirationDateString() -> String {
		if let date = store.otpTokenSrs?.expirationDate {
			return ISO8601DateFormatter.justLocalDateFormatter.string(from: date)
		} else {
			return "No Date set yet"
		}
	}
}

extension DMSRSOptionsViewModel {
	enum TableViewSections: Int, CaseIterable {
		case preChecks
		case srsStateValues
		case mostRecentKeySubmission
		
		var sectionTitle: String {
			switch self {
			case .preChecks:
				return "SRS Prerequisites"
			case .srsStateValues:
				return "SRS State Values"
			case .mostRecentKeySubmission:
				return "Most Recent Key Submission Date"
			}
		}
	}
}

#endif

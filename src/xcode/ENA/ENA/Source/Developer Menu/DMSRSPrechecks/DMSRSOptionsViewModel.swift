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
					return store.isSrsPrechecksEnabled
				},
				toggle: { [store] in
					store.isSrsPrechecksEnabled.toggle()
				})
		case .srsStateValues:
			return DMStaticTextCellViewModel(
				staticText: srsStateValueStaticText(),
				font: .enaFont(for: .footnote),
				textColor: .enaColor(for: .textPrimary1),
				alignment: .left
			)
		case .apiToken:
			return DMStaticTextCellViewModel(
				staticText: apiTokenStaticText(),
				font: .enaFont(for: .footnote),
				textColor: .enaColor(for: .textPrimary1),
				alignment: .left
			)
		case .resetMostRecentKeySubmission:
			return DMButtonCellViewModel(
				text: "Reset",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonDestructive),
				action: { [store] in
					store.mostRecentKeySubmissionDate = nil
					self.refreshTableView([TableViewSections.srsStateValues.rawValue])
				}
			)
		case .resetSRSStateValues:
			return DMButtonCellViewModel(
				text: "Reset",
				textColor: .white,
				backgroundColor: .enaColor(for: .buttonDestructive),
				action: { [store] in
					store.mostRecentKeySubmissionDate = nil
					store.otpTokenSrs = nil
					self.refreshTableView([TableViewSections.srsStateValues.rawValue])
				}
			)
		}
	}

	// MARK: - Private

	private let store: Store
	
	private func srsStateValueStaticText() -> String {
		"""

		MOST_RECENT_KEY_SUBMISSION
		\(createDateString(from: store.mostRecentKeySubmissionDate))

		SRS_OTP
		\(store.otpTokenSrs?.token ?? "No OTP Token set yet")

		SRS_OTP_EXPIRATION_DATE
		\(createDateString(from: store.otpTokenSrs?.expirationDate))

		"""
	}
	
	private func apiTokenStaticText() -> String {
	   """
	   
	   PPAC API Token SRS
	   \(store.ppacApiTokenSrs?.token ?? "No API Token generated yet")
	   
	   PPAC API Token SRS Creation Date
	   \(createDateString(from: store.ppacApiTokenSrs?.timestamp))
	   
	   Previous PPAC API Token SRS
	   \(store.previousPpacApiTokenSrs?.token ?? "No API Token available")
	   
	   Previous PPAC API Token SRS Creation Date
	   \(createDateString(from: store.previousPpacApiTokenSrs?.timestamp, fallback: "No Date available"))
	   
	   """
	}
	
	private func createDateString(
		from date: Date?,
		fallback: String = "No Date set yet"
	) -> String {
		if let date = date {
			return ISO8601DateFormatter.justLocalDateFormatter.string(from: date)
		} else {
			return fallback
		}
	}
}

extension DMSRSOptionsViewModel {
	enum TableViewSections: Int, CaseIterable {
		case preChecks
		case srsStateValues
		case apiToken
		case resetMostRecentKeySubmission
		case resetSRSStateValues
		
		var sectionTitle: String {
			switch self {
			case .preChecks:
				return "SRS Prerequisites"
			case .srsStateValues:
				return "SRS State Values"
			case .apiToken:
				return "API Token"
			case .resetMostRecentKeySubmission:
				return "Most Recent Key Submission"
			case .resetSRSStateValues:
				return "All SRS State Values"
			}
		}
	}
}

#endif

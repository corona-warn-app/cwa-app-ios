//
// 🦠 Corona-Warn-App
//

import Foundation

enum TestResult: Int, CaseIterable, Codable {

	// MARK: - Init

	//	Value of result	Description
	//	0	Pending (PCR test) or Pending (rapid antigen test)
	//	1	Negative (PCR test)
	//	2	Positive (PCR test)
	//	3	Invalid (PCR test)
	//	4	Redeemed (PCR test; locally referred to as Expired)
	//	5	Pending (rapid antigen test)
	//	6	Negative (rapid antigen test)
	//	7	Positive (rapid antigen test)
	//	8	Invalid (rapid antigen test)
	//	9	Redeemed (rapid antigen test; locally referred to as Expired))

	// swiftlint:disable cyclomatic_complexity
	init(
		serverResponse: Int,
		coronaTestType: CoronaTestType
	) {
		switch (serverResponse, coronaTestType) {
		case (0, _):
			self = .pending
		case (1, .pcr):
			self = .negative
		case (2, .pcr):
			self = .positive
		case (3, .pcr):
			self = .invalid
		case (4, .pcr):
			self = .expired
		case (5, .antigen):
			self = .pending
		case (6, .antigen):
			self = .negative
		case (7, .antigen):
			self = .positive
		case (8, .antigen):
			self = .invalid
		case (9, .antigen):
			self = .expired
		default:
			self = .invalid
		}
	}

	// MARK: - Internal

	case pending = 0
	case negative = 1
	case positive = 2
	case invalid = 3
	// On the server it's called "redeemed", but this state means that the test is expired.
	// Actually redeemed tests return a code 400 when registered.
	case expired = 4
}

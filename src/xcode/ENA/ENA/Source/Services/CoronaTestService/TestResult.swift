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

	init?(serverResponse: Int) {
		// Values for antigen tests are pending = 5, negative = 6, ...
		self.init(rawValue: serverResponse % 5)
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

////
// 🦠 Corona-Warn-App
//

import Foundation

enum CoronaTestQRCodeInformation {
	case pcr(String)
	case antigen(RapidTestInformation, String)
	
	// we cant declare the enum type to Int because we have properties inside the cases
	
	var rawValue: Int {
		switch self {
		case .pcr:
			return 0
		case .antigen:
			return 1
		}
	}
}

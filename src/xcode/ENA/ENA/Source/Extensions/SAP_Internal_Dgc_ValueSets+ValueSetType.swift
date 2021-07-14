//
// 🦠 Corona-Warn-App
//

import Foundation

extension SAP_Internal_Dgc_ValueSets {

	enum ValueSetType: String {
		case vaccineOrProphylaxis
		case vaccineMedicinalProduct
		case marketingAuthorizationHolder
		case diseaseOrAgentTargeted
		case typeOfTest
		case rapidAntigenTestNameAndManufacturer
		case testResult
	}

	func valueSet(for type: ValueSetType) -> SAP_Internal_Dgc_ValueSet? {
		switch type {
		case .vaccineOrProphylaxis:
			return hasVp ? vp : nil
		case .vaccineMedicinalProduct:
			return hasMp ? mp : nil
		case .marketingAuthorizationHolder:
			return hasMa ? ma : nil
		case .diseaseOrAgentTargeted:
			return hasTg ? tg : nil
		case .typeOfTest:
			return hasTcTt ? tcTt : nil
		case .rapidAntigenTestNameAndManufacturer:
			return hasTcMa ? tcMa : nil
		case .testResult:
			return hasTcTr ? tcTr : nil
		}
	}

}

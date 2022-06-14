//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import AnyCodable

class CCLServableMock: CCLServable {
	var configurationVersion: String = ""
	
	var dccAdmissionCheckScenariosEnabled: Bool = true
	
	var updateConfigurationCompletionGiven: ((Bool) -> Void)?
	var updateConfigurationCalledExpectation: XCTestExpectation?
	func updateConfiguration(completion: @escaping (Bool) -> Void) {
		updateConfigurationCompletionGiven = completion
		updateConfigurationCalledExpectation?.fulfill()
	}
	
	var dccWalletInfoCertificatesGiven: [DCCWalletCertificate]?
	var dccWalletInfoIdentifierGiven: String?
	var dccWalletInfoReturn: Result<DCCWalletInfo, DCCWalletInfoAccessError>?
	var dccWalletInfoCalledExpectation: XCTestExpectation?
	func dccWalletInfo(for certificates: [DCCWalletCertificate], with identifier: String?) -> Result<DCCWalletInfo, DCCWalletInfoAccessError> {
		dccWalletInfoCertificatesGiven = certificates
		dccWalletInfoIdentifierGiven = identifier
		dccWalletInfoCalledExpectation?.fulfill()
		return dccWalletInfoReturn ?? .failure(.failedFunctionsEvaluation(TestError.error))
	}
	
	var dccAdmissionCheckScenariosReturn: Result<DCCAdmissionCheckScenarios, DCCAdmissionCheckScenariosAccessError>?
	var dccAdmissionCheckScenariosCalledExpectation: XCTestExpectation?
	func dccAdmissionCheckScenarios() -> Result<DCCAdmissionCheckScenarios, DCCAdmissionCheckScenariosAccessError> {
		dccAdmissionCheckScenariosCalledExpectation?.fulfill()
		return dccAdmissionCheckScenariosReturn ?? .failure(.failedFunctionsEvaluation(TestError.error))
	}
	
	var evaluateFunctionWithDefaultValuesNameGiven: String?
	var evaluateFunctionWithDefaultValuesParametersGiven: [String: AnyDecodable]?
	var evaluateFunctionWithDefaultValuesDataReturn: Data = DecodableMock.dataMock
	var evaluateFunctionWithDefaultValuesCalledExpectation: XCTestExpectation?
	func evaluateFunctionWithDefaultValues<T>(name: String, parameters: [String: AnyDecodable]) throws -> T where T: Decodable {
		evaluateFunctionWithDefaultValuesNameGiven = name
		evaluateFunctionWithDefaultValuesParametersGiven = parameters
		evaluateFunctionWithDefaultValuesCalledExpectation?.fulfill()
		return try JSONDecoder().decode(T.self, from: evaluateFunctionWithDefaultValuesDataReturn)
	}
}

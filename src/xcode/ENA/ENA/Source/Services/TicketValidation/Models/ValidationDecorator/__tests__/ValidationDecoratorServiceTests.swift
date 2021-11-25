//
// 🦠 Corona-Warn-App
//

import XCTest
import ENASecurity
@testable import ENA

class ValidationDecoratorServiceTests: XCTestCase {

	// Happy scenario success Case
	
	func test_happyScenario_Return_Identity_Document() {
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(ServiceIdentityDocument.fake())
		])
		let decoratorService = ValidationDecoratorService(restServiceProvider: restServiceProvider)
		
		decoratorService.requestIdentityDocumentOfTheValidationDecorator(urlString: "test") { result in
			switch result {
			case .success(let identityDocument):
				XCTAssertEqual(identityDocument.accessTokenService.id, "test")
			case .failure(let error):
				XCTFail("expected test to succeeds" + error.localizedDescription)
			}
		}
	}
}

////
// 🦠 Corona-Warn-App
//

import XCTest
import CertLogic
@testable import ENA

class ValidationResultCellModelTests: XCTestCase {
	
	func testGIVEN_PassedResult_WHEN_IconImage_THEN_NilIsReturned() throws {
		// GIVEN
		let expectedIcon: UIImage? = nil
		let expectedAcceptanceOpenValidationResult = ValidationResult.fake(
			rule: Rule.fake(),
			result: .passed)
			
		let healthCertificate = HealthCertificate.mock()
		let vaccinationValueSets = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore())
		
		let model = ValidationResultCellModel(
			validationResult: expectedAcceptanceOpenValidationResult,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSets
		)
		
		// WHEN
		let icon = model.iconImage
		
		// THEN
		XCTAssertEqual(icon, expectedIcon)
	}
	
	func testGIVEN_OpenResult_WHEN_IconImage_THEN_OpenImageIsReturned() throws {
		// GIVEN
		let expectedIcon: UIImage? = UIImage(imageLiteralResourceName: "Icon_CertificateValidation_Open")
		let expectedAcceptanceOpenValidationResult = ValidationResult.fake(
			rule: Rule.fake(),
			result: .open)
			
		let healthCertificate = HealthCertificate.mock()
		let vaccinationValueSets = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore())
		
		let model = ValidationResultCellModel(
			validationResult: expectedAcceptanceOpenValidationResult,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSets
		)
		
		// WHEN
		let icon = model.iconImage
		
		// THEN
		XCTAssertEqual(icon, expectedIcon)
	}
	
	func testGIVEN_FailedResult_WHEN_IconImage_THEN_FailedImageIsReturned() throws {
		// GIVEN
		let expectedIcon: UIImage? = UIImage(imageLiteralResourceName: "Icon_CertificateValidation_Failed")
		let expectedAcceptanceOpenValidationResult = ValidationResult.fake(
			rule: Rule.fake(),
			result: .fail)
			
		let healthCertificate = HealthCertificate.mock()
		let vaccinationValueSets = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore())
		
		let model = ValidationResultCellModel(
			validationResult: expectedAcceptanceOpenValidationResult,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSets
		)
		
		// WHEN
		let icon = model.iconImage
		
		// THEN
		XCTAssertEqual(icon, expectedIcon)
	}

	func testGIVEN_LangIsDE_WHEN_RuleDescription_THEN_DescriptionInDEIsReturned() throws {
		// GIVEN
		let expectedDescription = Description(
			lang: "de",
			desc: "Dies ist eine Beschreibung"
		)
		
		let expectedAcceptanceOpenValidationResult = ValidationResult.fake(
			rule: Rule.fake(
				type: "Acceptance",
				description: [expectedDescription]
			),
			result: .open)
			
		let healthCertificate = HealthCertificate.mock()
		let vaccinationValueSets = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore())
		
		let model = ValidationResultCellModel(
			validationResult: expectedAcceptanceOpenValidationResult,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSets
		)
		
		// WHEN
		let description = model.ruleDescription
		
		// THEN
		XCTAssertEqual(description, expectedDescription.desc)
	}
	
	func testGIVEN_LangIsEN_WHEN_RuleDescription_THEN_DescriptionInENIsReturned() throws {
		// GIVEN
		let expectedDescription = Description(
			lang: "en",
			desc: "This is a description"
		)
		
		let expectedAcceptanceOpenValidationResult = ValidationResult.fake(
			rule: Rule.fake(
				type: "Acceptance",
				description: [expectedDescription]
			),
			result: .open)
			
		let healthCertificate = HealthCertificate.mock()
		let vaccinationValueSets = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore())
		
		let model = ValidationResultCellModel(
			validationResult: expectedAcceptanceOpenValidationResult,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSets
		)
		
		// WHEN
		let description = model.ruleDescription
		
		// THEN
		XCTAssertEqual(description, expectedDescription.desc)
	}

	func testGIVEN_LangIsNotSet_WHEN_RuleDescription_THEN_IdentifierIsReturned() throws {
		// GIVEN
		let expectedIdentifier = "ABC"
		let expectedAcceptanceOpenValidationResult = ValidationResult.fake(
			rule: Rule.fake(
				identifier: expectedIdentifier,
				type: "Acceptance",
				description: []
			),
			result: .open)
			
		let healthCertificate = HealthCertificate.mock()
		let vaccinationValueSets = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore())
		
		let model = ValidationResultCellModel(
			validationResult: expectedAcceptanceOpenValidationResult,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSets
		)
		
		// WHEN
		let description = model.ruleDescription
		
		// THEN
		XCTAssertEqual(description, expectedIdentifier)
	}
	
	func testGIVEN_AcceptanceRule_WHEN_RuleTypeDescription_THEN_DescriptionIsReturned() throws {
		// GIVEN
		let expectedCountry = try XCTUnwrap(Country(countryCode: "FR"))
		let expectedResult = String(
			format: AppStrings.HealthCertificate.Validation.Result.acceptanceRule,
			expectedCountry.localizedName
		)
		let expectedAcceptanceOpenValidationResult = ValidationResult.fake(
			rule: Rule.fake(
				type: "Acceptance",
				countryCode: expectedCountry.id
			),
			result: .open)
			
		let healthCertificate = HealthCertificate.mock()
		let vaccinationValueSets = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore())
		
		let model = ValidationResultCellModel(
			validationResult: expectedAcceptanceOpenValidationResult,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSets
		)
		
		// WHEN
		let ruleTypeDescription = model.ruleTypeDescription
		
		// THEN
		XCTAssertEqual(ruleTypeDescription, expectedResult)
	}

	func testGIVEN_AcceptanceRule_WHEN_RuleTypeDescriptionWithNonexistentCountry_THEN_DescriptionIsReturned() throws {
		// GIVEN
		let countryCode = "XX"
		let expectedResult = String(
			format: AppStrings.HealthCertificate.Validation.Result.acceptanceRule,
			countryCode
		)
		let expectedAcceptanceOpenValidationResult = ValidationResult.fake(
			rule: Rule.fake(
				type: "Acceptance",
				countryCode: countryCode
			),
			result: .open)

		let healthCertificate = HealthCertificate.mock()
		let vaccinationValueSets = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore())

		let model = ValidationResultCellModel(
			validationResult: expectedAcceptanceOpenValidationResult,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSets
		)

		// WHEN
		let ruleTypeDescription = model.ruleTypeDescription

		// THEN
		XCTAssertEqual(ruleTypeDescription, expectedResult)
	}
	
	func testGIVEN_InvalidationRule_WHEN_RuleTypeDescription_THEN_DescriptionIsReturned() throws {
		// GIVEN
		let expectedAcceptanceOpenValidationResult = ValidationResult.fake(
			rule: Rule.fake(
				type: "Invalidation"
			),
			result: .open)
			
		let healthCertificate = HealthCertificate.mock()
		let vaccinationValueSets = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore())
		
		let model = ValidationResultCellModel(
			validationResult: expectedAcceptanceOpenValidationResult,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSets
		)
		
		// WHEN
		let ruleTypeDescription = model.ruleTypeDescription
		
		// THEN
		XCTAssertEqual(ruleTypeDescription, AppStrings.HealthCertificate.Validation.Result.invalidationRule)
	}
	
	func testGIVEN_InvalidRule_WHEN_RuleTypeDescription_THEN_DescriptionIsReturned() throws {
		// GIVEN
		let expectedResult = String(
			format: AppStrings.HealthCertificate.Validation.Result.acceptanceRule,
			"Fake"
		)
		let expectedAcceptanceOpenValidationResult = ValidationResult.fake(
			rule: Rule.fake(
				type: "Invalid",
				countryCode: "Fake"
			),
			result: .open)
			
		let healthCertificate = HealthCertificate.mock()
		let vaccinationValueSets = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore())
		
		let model = ValidationResultCellModel(
			validationResult: expectedAcceptanceOpenValidationResult,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSets
		)
		
		// WHEN
		let ruleTypeDescription = model.ruleTypeDescription
		
		// THEN
		XCTAssertEqual(ruleTypeDescription, expectedResult)
	}
}

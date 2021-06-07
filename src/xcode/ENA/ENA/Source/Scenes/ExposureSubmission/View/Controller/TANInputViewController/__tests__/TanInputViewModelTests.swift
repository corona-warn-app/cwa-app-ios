////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TanInputViewModelTests: CWATestCase {

	func testGIVEN_ValidFormattedTanWithValidChecksum_WHEN_isValidIsChecksumValid_THEN_isInvalidChcksumIsValid() {
		// GIVEN
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		
		let viewModel = TanInputViewModel(
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					client: client,
					appConfiguration: appConfiguration
				)
			),
			onSuccess: { _, _ in },
			givenTan: "234567893D"
		)

		// WHEN
		let isValid = viewModel.isNumberOfDigitsReached
		let isChecksumValid = viewModel.isChecksumValid

		// THEN
		XCTAssertTrue(isValid, "tan format is invalid")
		XCTAssertTrue(isChecksumValid, "tan checksum is invalid")
	}

	func testGIVEN_ValidFormattedTanWithInvalidChecksum_WHEN_isValidIsChecksumValid_THEN_isInvalidChcksumIsInvalid() {
		// GIVEN
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let viewModel = TanInputViewModel(
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					client: client,
					appConfiguration: appConfiguration
				)
			),
			onSuccess: { _, _ in },
			givenTan: "ZBYKEVDBNU"
		)

		// WHEN
		let isValid = viewModel.isNumberOfDigitsReached
		let isChecksumValid = viewModel.isChecksumValid

		// THEN
		XCTAssertTrue(isValid, "tan format is invalid")
		XCTAssertFalse(isChecksumValid, "tan checksum is valid")
	}

	func testGIVEN_wrongCharacterTanString_WHEN_isValidCheck_THEN_isInvalidChecksumIsInvalid() {
		// GIVEN
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let viewModel = TanInputViewModel(
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					client: client,
					appConfiguration: appConfiguration
				)
			),
			onSuccess: { _, _ in },
			givenTan: "ZBYKEVDBNL"
		)

		// WHEN
		let isValid = viewModel.isNumberOfDigitsReached
		let isChecksumValid = viewModel.isChecksumValid

		// THEN
		XCTAssertTrue(isValid, "tan format is invalid")
		XCTAssertFalse(isChecksumValid, "tan checksum is valid")
	}

}

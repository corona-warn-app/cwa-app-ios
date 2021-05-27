////
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class HealthCertificateViewModelTests: XCTestCase {

	func testGIVEN_HealthCertificateViewModel_TableViewSection_THEN_SectionsAreCorrect() {

		// THEN
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.numberOfSections, 5)
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.map(0), .headline)
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.map(1), .qrCode)
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.map(2), .topCorner)
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.map(3), .details)
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.map(4), .bottomCorner)
	}

	func testGIVEN_HealthCertificate_WHEN_CreateViewModel_THEN_IsSetup() throws {
		// GIVEN
		let healthCertificate = HealthCertificateMock()
		let certifiedPerson = HealthCertifiedPerson(healthCertificates: [])
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore())

		// WHEN
		let viewModel = HealthCertificateViewModel(
			healthCertifiedPerson: certifiedPerson,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider
		)

		// THEN
		XCTAssertNil(viewModel.headlineCellViewModel.text)
		XCTAssertNotNil(viewModel.headlineCellViewModel.attributedText)

		XCTAssertEqual(viewModel.headlineCellViewModel.backgroundColor, .clear)
		XCTAssertEqual(viewModel.headlineCellViewModel.textAlignment, .center)
		XCTAssertEqual(viewModel.headlineCellViewModel.topSpace, 18.0)
		XCTAssertEqual(viewModel.headlineCellViewModel.font, .enaFont(for: .headline))
		XCTAssertEqual(viewModel.headlineCellViewModel.accessibilityTraits, .staticText)
		XCTAssertEqual(viewModel.numberOfItems(in: .headline), 0)
		XCTAssertEqual(viewModel.numberOfItems(in: .qrCode), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .topCorner), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .details), 2)
		XCTAssertEqual(viewModel.numberOfItems(in: .bottomCorner), 1)
	}

}

struct HealthCertificateMock: HealthCertificateData {

	// MARK: - Init

	init() {
		self.base45 = ""
		self.version = ""
		self.name = Name(
			familyName: "Mustermann",
			givenName: "Max",
			standardizedFamilyName: "die mustermanns",
			standardizedGivenName: "maxi"
		)
		self.dateOfBirth = "1981-12-24"
		self.dateOfBirthDate = Date()
		self.vaccinationCertificates = []
		self.isLastDoseInASeries = false
		self.expirationDate = Date()
		self.dateOfVaccination = Date()
		self.doseNumber = 1
		self.totalSeriesOfDoses = 2
	}

	// MARK: - Internal

	let base45: Base45
	let version: String
	let name: Name
	let dateOfBirth: String
	var dateOfBirthDate: Date?
	let vaccinationCertificates: [VaccinationCertificate]
	let isLastDoseInASeries: Bool
	var expirationDate: Date
	var dateOfVaccination: Date?
	var doseNumber: Int
	var totalSeriesOfDoses: Int

}

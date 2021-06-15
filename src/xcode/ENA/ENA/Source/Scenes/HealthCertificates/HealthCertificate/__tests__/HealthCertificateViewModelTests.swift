////
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class HealthCertificateViewModelTests: CWATestCase {

	func testGIVEN_HealthCertificateViewModel_TableViewSection_THEN_SectionsAreCorrect() {

		// THEN
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.numberOfSections, 6)
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.map(0), .headline)
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.map(1), .qrCode)
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.map(2), .topCorner)
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.map(3), .details)
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.map(4), .bottomCorner)
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.map(5), .additionalInfo)
		XCTAssertNil(HealthCertificateViewModel.TableViewSection.map(6))

	}

	func testGIVEN_HealthCertificate_WHEN_CreateViewModel_THEN_IsSetup() throws {
		// GIVEN
		let healthCertificate = HealthCertificate.mock()
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
		XCTAssertEqual(viewModel.headlineCellViewModel.topSpace, 16.0)
		XCTAssertEqual(viewModel.headlineCellViewModel.font, .enaFont(for: .headline))
		XCTAssertEqual(viewModel.headlineCellViewModel.accessibilityTraits, .staticText)
		XCTAssertEqual(viewModel.numberOfItems(in: .headline), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .qrCode), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .topCorner), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .details), 8)
		XCTAssertEqual(viewModel.numberOfItems(in: .bottomCorner), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .additionalInfo), 2)
		XCTAssertEqual(viewModel.additionalInfoCellViewModels.count, 2)
	}

}

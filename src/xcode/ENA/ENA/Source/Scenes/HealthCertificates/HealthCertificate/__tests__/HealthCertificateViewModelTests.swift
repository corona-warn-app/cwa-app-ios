////
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class HealthCertificateViewModelTests: CWATestCase {

	func testGIVEN_HealthCertificateViewModel_TableViewSection_THEN_SectionsAreCorrect() {

		// THEN
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.numberOfSections, 8)
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.map(0), .headline)
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.map(1), .qrCode)
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.map(2), .topCorner)
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.map(3), .details)
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.map(4), .bottomCorner)
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.map(5), .vaccinationOneOfOneHint)
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.map(6), .expirationDate)
		XCTAssertEqual(HealthCertificateViewModel.TableViewSection.map(7), .additionalInfo)
		XCTAssertNil(HealthCertificateViewModel.TableViewSection.map(8))
	}

	func testGIVEN_Vaccination1Of2_WHEN_CreateViewModel_THEN_IsSetup() throws {
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [
						VaccinationEntry.fake(doseNumber: 1, totalSeriesOfDoses: 2)
					]
				)
			)
		)
		let certifiedPerson = HealthCertifiedPerson(healthCertificates: [])
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore())

		// WHEN
		let viewModel = HealthCertificateViewModel(
			healthCertifiedPerson: certifiedPerson,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			markAsSeenOnDisappearance: true,
			showInfoHit: { }
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
		XCTAssertEqual(viewModel.numberOfItems(in: .details), 12)
		XCTAssertEqual(viewModel.numberOfItems(in: .bottomCorner), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .vaccinationOneOfOneHint), 0)
		XCTAssertEqual(viewModel.numberOfItems(in: .expirationDate), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .additionalInfo), 2)
		XCTAssertEqual(viewModel.additionalInfoCellViewModels.count, 2)
	}

	func testGIVEN_Vaccination1of1_WHEN_CreateViewModel_THEN_IsSetup() throws {
		// GIVEN
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(
				from: DigitalCovidCertificate.fake(
					vaccinationEntries: [
						VaccinationEntry.fake(doseNumber: 1, totalSeriesOfDoses: 1)
					]
				)
			)
		)
		let certifiedPerson = HealthCertifiedPerson(healthCertificates: [])
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore())

		// WHEN
		let viewModel = HealthCertificateViewModel(
			healthCertifiedPerson: certifiedPerson,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			markAsSeenOnDisappearance: true,
			showInfoHit: { }
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
		XCTAssertEqual(viewModel.numberOfItems(in: .details), 12)
		XCTAssertEqual(viewModel.numberOfItems(in: .bottomCorner), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .vaccinationOneOfOneHint), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .expirationDate), 1)
		XCTAssertEqual(viewModel.numberOfItems(in: .additionalInfo), 2)
		XCTAssertEqual(viewModel.additionalInfoCellViewModels.count, 2)
	}

	func testMarkAsSeen() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(vaccinationEntries: [.fake()])),
			isNew: true,
			isValidityStateNew: true
		)

		let certifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)

		let viewModel = HealthCertificateViewModel(
			healthCertifiedPerson: certifiedPerson,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			markAsSeenOnDisappearance: true,
			showInfoHit: { }
		)

		XCTAssertTrue(healthCertificate.isNew)
		XCTAssertTrue(healthCertificate.isValidityStateNew)

		viewModel.markAsSeen()

		XCTAssertFalse(healthCertificate.isNew)
		XCTAssertFalse(healthCertificate.isValidityStateNew)
	}

	func testIsPrimaryFooterButtonEnabledIfInitiallyNotBlocked() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(vaccinationEntries: [.fake()])),
			validityState: .valid
		)

		let certifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)

		let viewModel = HealthCertificateViewModel(
			healthCertifiedPerson: certifiedPerson,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			markAsSeenOnDisappearance: true,
			showInfoHit: { }
		)

		XCTAssertTrue(viewModel.isPrimaryFooterButtonEnabled)

		healthCertificate.validityState = .expiringSoon

		XCTAssertTrue(viewModel.isPrimaryFooterButtonEnabled)

		healthCertificate.validityState = .expired

		XCTAssertTrue(viewModel.isPrimaryFooterButtonEnabled)

		healthCertificate.validityState = .invalid

		XCTAssertTrue(viewModel.isPrimaryFooterButtonEnabled)

		healthCertificate.validityState = .blocked

		XCTAssertFalse(viewModel.isPrimaryFooterButtonEnabled)
	}

	func testIsPrimaryFooterButtonEnabledInitiallyBlocked() throws {
		let healthCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(vaccinationEntries: [.fake()])),
			validityState: .blocked
		)

		let certifiedPerson = HealthCertifiedPerson(healthCertificates: [healthCertificate])

		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(
			client: CachingHTTPClientMock(),
			store: MockTestStore()
		)

		let viewModel = HealthCertificateViewModel(
			healthCertifiedPerson: certifiedPerson,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			markAsSeenOnDisappearance: true,
			showInfoHit: { }
		)

		XCTAssertFalse(viewModel.isPrimaryFooterButtonEnabled)

		healthCertificate.validityState = .valid

		XCTAssertTrue(viewModel.isPrimaryFooterButtonEnabled)
	}

}

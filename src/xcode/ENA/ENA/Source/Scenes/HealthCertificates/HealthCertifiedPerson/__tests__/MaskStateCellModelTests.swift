//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit
import class CertLogic.Description

class MaskStateCellModelTests: XCTestCase {

    func testMaskStateFromWalletInfo_MaskOptional() throws {
		// GIVEN
		
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [])
		
		let titleMock = "Maskenbefreiung"
		let subtitleMock = "Sie sind nicht von der Maskenpflicht ausgenommen"
		let longTextMock = "Von der Maskenpflicht sind alle Personen befreit, die innerhalb der letzten 3 Monate geimpft wurden oder genesen sind oder innerhalb der letzten 24 Stunden negativ getestet wurden."
		let faqAnchorMock = "maskstate"
		
		healthCertifiedPerson.dccWalletInfo = .fake(
			maskState: .fake(
				visible: true,
				badgeText: .fake(string: "Ein-Badge-Text"),
				titleText: .fake(string: titleMock),
				subtitleText: .fake(string: subtitleMock),
				longText: .fake(string: longTextMock),
				faqAnchor: faqAnchorMock,
				identifier: .maskOptional
			)
		)
		
		let fakeCCLService = FakeCCLService()
		
		// WHEN
		
		let sut = MaskStateCellModel(
			healthCertifiedPerson: healthCertifiedPerson,
			cclService: fakeCCLService
		)
		
		// THEN

		XCTAssertEqual(sut.title, titleMock)
		XCTAssertEqual(sut.subtitle, subtitleMock)
		XCTAssertEqual(sut.description, longTextMock)
		XCTAssertEqual(sut.faqLink?.string, AppStrings.HealthCertificate.Person.faqMaskState)
		
		guard
			let badgeImageExpected = UIImage(named: "Badge_nomask")?.pngData(),
			let badgeImageToTest = sut.badgeImage?.pngData()
		else {
			return XCTFail("Expect Badge Image PNG Data not nil")
		}
	
		XCTAssertEqual(badgeImageExpected, badgeImageToTest)
    }
	
	func testMaskStateFromWalletInfo_MaskReqiured() throws {
		
		// GIVEN
		
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [])
		
		let titleMock = "Maskenpflicht"
		let subtitleMock = "Für Sie gilt Maskenpflicht"
		let longTextMock = "Von der Maskenpflicht sind alle Personen befreit, die innerhalb der letzten 3 Monate geimpft wurden oder genesen sind oder innerhalb der letzten 24 Stunden negativ getestet wurden."
		let faqAnchorMock = "maskstate"
		
		healthCertifiedPerson.dccWalletInfo = .fake(
			maskState: .fake(
				visible: true,
				badgeText: .fake(string: "Ein-Badge-Text"),
				titleText: .fake(string: titleMock),
				subtitleText: .fake(string: subtitleMock),
				longText: .fake(string: longTextMock),
				faqAnchor: faqAnchorMock,
				identifier: .maskRequired
			)
		)
		
		let fakeCCLService = FakeCCLService()
		
		// WHEN
		
		let sut = MaskStateCellModel(
			healthCertifiedPerson: healthCertifiedPerson,
			cclService: fakeCCLService
		)
		
		// THEN
		
		XCTAssertEqual(sut.title, titleMock)
		XCTAssertEqual(sut.subtitle, subtitleMock)
		XCTAssertEqual(sut.description, longTextMock)
		XCTAssertEqual(sut.faqLink?.string, AppStrings.HealthCertificate.Person.faqMaskState)
		
		guard
			let badgeImageExpected = UIImage(named: "Badge_mask")?.pngData(),
			let badgeImageToTest = sut.badgeImage?.pngData()
		else {
			return XCTFail("Expect Badge Image PNG Data not nil")
		}
	
		XCTAssertEqual(badgeImageExpected, badgeImageToTest)
	}

}

//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA


class HomeLinkCardViewModelTests: XCTestCase {
	private let pandemicRadarLinkCard: SAP_Internal_Stats_LinkCard = .mock(cardID: HomeLinkCard.pandemicRadar.rawValue)

	func testTitle_pandemicRadar() {
		// Given
		let sut = HomeLinkCardViewModel(for: pandemicRadarLinkCard)
		
		// Then
		XCTAssertEqual(sut.title, AppStrings.Statistics.Card.PandemicRadar.title)
	}
	
	func testSubtitle_pandemicRadar() {
		// Given
		let sut = HomeLinkCardViewModel(for: pandemicRadarLinkCard)
		
		// Then
		XCTAssertEqual(sut.subtitle, AppStrings.Statistics.Card.PandemicRadar.subtitle)
	}
	
	func testDescription_pandemicRadar() {
		// Given
		let sut = HomeLinkCardViewModel(for: pandemicRadarLinkCard)
		
		// Then
		XCTAssertEqual(sut.description, AppStrings.Statistics.Card.PandemicRadar.description)
	}
	
	func testAsset_pandemicRadar() {
		// Given
		let sut = HomeLinkCardViewModel(for: pandemicRadarLinkCard)
		
		// Then
		XCTAssertEqual(sut.image, UIImage(named: "Illu_Radar"))
	}
	
	func testButtonTitle_pandemicRadar() {
		// Given
		let sut = HomeLinkCardViewModel(for: pandemicRadarLinkCard)
		
		// When
		guard let buttonTitle = sut.buttonTitle else {
			return XCTFail("Expect `buttonTitle`.")
		}
		
		// Then
		var textRange = NSRange(
			location: 0,
			length: AppStrings.Statistics.Card.LinkCard.buttonTitle.count
		)
		let attachementRange = NSRange(
			location: textRange.length,
			length: buttonTitle.length
		)
		
		XCTAssertEqual(
			buttonTitle.attributedSubstring(from: textRange).string,
			AppStrings.Statistics.Card.LinkCard.buttonTitle
		)

		XCTAssertTrue(buttonTitle.containsAttachments(in: attachementRange))
		
		XCTAssertEqual(
			buttonTitle.attribute(.font, at: 0, effectiveRange: &textRange) as? UIFont,
			UIFont.enaFont(for: .body, weight: .semibold)
		)
		
		XCTAssertEqual(
			buttonTitle.attribute(.foregroundColor, at: 0, effectiveRange: &textRange) as? UIColor,
			UIColor.enaColor(for: .buttonPrimary)
		)
		
		let buttonTitleImage = buttonTitle.attachmentImage
		XCTAssertNotNil(buttonTitleImage)
		
		let buttonTitleImageSFSymbol = UIImage(named: "export_icon")
		XCTAssertEqual(buttonTitleImage, buttonTitleImageSFSymbol)
	}
	
	func testButtonURL_pandemicRadar() {
		// Given
		let sut = HomeLinkCardViewModel(for: pandemicRadarLinkCard)
		
		// Then
		XCTAssertEqual(sut.buttonURL?.absoluteString, pandemicRadarLinkCard.url)
	}
	
	func testTitleAccessibilityIdentifier_pandemicRadar() {
		// Given
		let sut = HomeLinkCardViewModel(for: pandemicRadarLinkCard)
		
		// Then
		XCTAssertEqual(
			sut.titleAccessibilityIdentifier,
			AccessibilityIdentifiers.LinkCard.PandemicRadar.titleLabel
		)
	}
	
	func testSubtitleAccessibilityIdentifier_pandemicRadar() {
		// Given
		let sut = HomeLinkCardViewModel(for: pandemicRadarLinkCard)
		
		// Then
		XCTAssertEqual(
			sut.subtitleAccessibilityIdentifier,
			AccessibilityIdentifiers.LinkCard.PandemicRadar.subtitleLabel
		)
	}
	
	func testDescriptionAccessibilityIdentifier_pandemicRadar() {
		// Given
		let sut = HomeLinkCardViewModel(for: pandemicRadarLinkCard)
		
		// Then
		XCTAssertEqual(
			sut.descriptionAccessibilityIdentifier,
			AccessibilityIdentifiers.LinkCard.PandemicRadar.descriptionLabel
		)
	}
	
	func testAssetAccessibilityIdentifier_pandemicRadar() {
		// Given
		let sut = HomeLinkCardViewModel(for: pandemicRadarLinkCard)
		
		// Then
		XCTAssertEqual(
			sut.imageAccessibilityIdentifier,
			AccessibilityIdentifiers.LinkCard.PandemicRadar.image
		)
	}
	
	func testButtonAccessibilityIdentifier_pandemicRadar() {
		// Given
		let sut = HomeLinkCardViewModel(for: pandemicRadarLinkCard)
		
		// Then
		XCTAssertEqual(
			sut.buttonAccessibilityIdentifier,
			AccessibilityIdentifiers.LinkCard.PandemicRadar.button
		)
	}
	
	func testInfoButtonAccessibilityIdentifier_pandemicRadar() {
		// Given
		let sut = HomeLinkCardViewModel(for: pandemicRadarLinkCard)
		
		// Then
		XCTAssertEqual(
			sut.infoButtonAccessibilityIdentifier,
			AccessibilityIdentifiers.LinkCard.PandemicRadar.infoButton
		)
	}
	
	func testDeleteButtonAccessibilityIdentifier_pandemicRadar() {
		// Given
		let sut = HomeLinkCardViewModel(for: pandemicRadarLinkCard)
		
		// Then
		XCTAssertEqual(
			sut.deleteButtonAccessibilityIdentifier,
			AccessibilityIdentifiers.LinkCard.PandemicRadar.deleteButton
		)
	}
}

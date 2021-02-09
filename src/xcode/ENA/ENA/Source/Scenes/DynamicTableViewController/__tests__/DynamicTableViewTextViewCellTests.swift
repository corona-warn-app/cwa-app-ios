//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DynamicTableViewTextViewCellTests: XCTestCase {

	func testDataDetectors_DefaultNone() throws {
		let sut = DynamicTableViewTextViewCell()
		let textView = try sut.getTextView()
		XCTAssertEqual(textView.dataDetectorTypes, [])
	}

	func testDataDetectors_Setter() throws {
		let sut = DynamicTableViewTextViewCell()
		let expectedDetectors: UIDataDetectorTypes = [.shipmentTrackingNumber, .phoneNumber]
		sut.configureTextView(dataDetectorTypes: expectedDetectors)

		let textView = try sut.getTextView()
		XCTAssertEqual(textView.dataDetectorTypes, expectedDetectors)
	}

	func testSetup_Colors() throws {
		// `setup` should be called when using the below constructor
		let sut = DynamicTableViewTextViewCell(style: .default, reuseIdentifier: "Foo")

		XCTAssertEqual(sut.backgroundColor, UIColor.enaColor(for: .background))
		XCTAssertEqual(try sut.getTextView().backgroundColor, UIColor.enaColor(for: .background))
		XCTAssertEqual(try sut.getTextView().tintColor, UIColor.enaColor(for: .textTint))
	}

	func testSetup_UITextView_LikeLabel() throws {
		// `setup` should be called when using the below constructor
		let sut = try DynamicTableViewTextViewCell(style: .default, reuseIdentifier: "Foo").getTextView()
		XCTAssertFalse(sut.isScrollEnabled)
		XCTAssertFalse(sut.isEditable)
		XCTAssertEqual(sut.textContainerInset, .zero)
		XCTAssertEqual(sut.textContainer.lineFragmentPadding, .zero)
	}

	func testSetup_UITextView_Margins() {
		// `setup` should be called when using the below constructor
		let sut = DynamicTableViewTextViewCell(style: .default, reuseIdentifier: "Foo")
		sut.testMargins()
	}

	func testPrepareForReuse_Margins() {
		// `setup` should be called when using the below constructor
		let sut = DynamicTableViewTextViewCell(style: .default, reuseIdentifier: "Foo")
		sut.layoutMargins = .zero
		sut.insetsLayoutMarginsFromSafeArea	= true

		sut.prepareForReuse()

		sut.testMargins()
	}

	func testPrepareForReuse_DynamicType() throws {
		// When prepareForReuse is called, defaults should be applied
		let sut = DynamicTableViewTextViewCell()
		sut.configureDynamicType(size: 20, weight: .black, style: .callout)
		sut.configure(text: "Foo", color: .systemRed)

		sut.prepareForReuse()

		try sut.testDefaultConfiguration()
	}

	func testConfigureDynamicType_Customized() throws {
		let sut = DynamicTableViewTextViewCell()
		let expectedFontSize = CGFloat(20)
		let expectedFontWeight = UIFont.Weight.medium
		let expectedFontStyle = UIFont.TextStyle.callout

		sut.configureDynamicType(size: expectedFontSize, weight: expectedFontWeight, style: expectedFontStyle)

		let textView = try sut.getTextView()
		let font = try XCTUnwrap(textView.font)

		XCTAssertEqual(font.pointSize, expectedFontSize, accuracy: 0.1)
		XCTAssertTrue(textView.adjustsFontForContentSizeCategory)
		XCTAssertEqual(
			font,
			UIFont.preferredFont(forTextStyle: expectedFontStyle).scaledFont(size: expectedFontSize, weight: expectedFontWeight)
		)
	}

	func testConfigureDynamicType_Defaults() throws {
		let sut = DynamicTableViewTextViewCell()
		let expectedFontSize = CGFloat(17)
		let expectedFontWeight = UIFont.Weight.regular
		let expectedFontStyle = UIFont.TextStyle.body

		sut.configureDynamicType()

		let textView = try sut.getTextView()
		let font = try XCTUnwrap(textView.font)

		XCTAssertEqual(font.pointSize, expectedFontSize, accuracy: 0.1)
		XCTAssertTrue(textView.adjustsFontForContentSizeCategory)
		XCTAssertEqual(
			font,
			UIFont.preferredFont(forTextStyle: expectedFontStyle).scaledFont(size: expectedFontSize, weight: expectedFontWeight)
		)
	}

	func testConfigure_Customized() throws {
		let sut = DynamicTableViewTextViewCell()
		let expectedText = "Foo"
		let expectedTextColor = UIColor.systemRed

		sut.configure(text: expectedText, color: expectedTextColor)

		let textView = try sut.getTextView()

		XCTAssertEqual(textView.text, expectedText)
		XCTAssertEqual(textView.textColor, expectedTextColor)
	}

	func testConfigure_Defaults() throws {
		let sut = DynamicTableViewTextViewCell()
		let expectedText = "Foo"
		let expectedTextColor = UIColor.enaColor(for: .textPrimary1)

		sut.configure(text: expectedText)

		let textView = try sut.getTextView()

		XCTAssertEqual(textView.text, expectedText)
		XCTAssertEqual(textView.textColor, expectedTextColor)
	}

	func testConfigureAccessibility() throws {
		let sut = DynamicTableViewTextViewCell()
		let expectedLabel = "Foo"
		let expectedIdentifier = "Bar"
		let exptectedTraits = UIAccessibilityTraits.adjustable

		sut.configureAccessibility(label: expectedLabel, identifier: expectedIdentifier, traits: exptectedTraits)

		let textView = try sut.getTextView()

		XCTAssertEqual(textView.accessibilityLabel, expectedLabel)
		XCTAssertEqual(textView.accessibilityIdentifier, expectedIdentifier)
		XCTAssertEqual(sut.accessibilityTraits, exptectedTraits)
	}
}

private extension DynamicTableViewTextViewCell {
	func testMargins() {
		XCTAssertEqual(contentView.layoutMargins, UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
		XCTAssertFalse(contentView.insetsLayoutMarginsFromSafeArea)
	}

	func testDefaultConfiguration() throws {
		// Tests the default cell configuration:
		// - font
		// - adjustsFontForContentSizeCategory
		// - textView text
		// - textColor
		// - empty text
		let textView = try getTextView()
		XCTAssertEqual(textView.font, UIFont.preferredFont(forTextStyle: .body).scaledFont(size: 17, weight: .regular))
		XCTAssertTrue(textView.adjustsFontForContentSizeCategory)
		XCTAssertEqual(textView.text, "")
		XCTAssertEqual(textView.textColor, .enaColor(for: .textPrimary1))
	}
}

// MARK: - Helpers

private extension DynamicTableViewTextViewCell {
	func getTextView() throws -> UITextView {
		return try XCTUnwrap(contentView.subviews.first(where: { $0 is UITextView }) as? UITextView)
	}
}

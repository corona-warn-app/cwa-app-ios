////
// 🦠 Corona-Warn-App
//
// helper functions fur UITests

import Foundation
import XCTest

enum AccessibilityLabels {
	
	// access Localized.strings via UITest bundle
	static func localized(_ key: String) -> String {
		let uiTestBundle = Bundle(for: ENAUITests_01_Home.self)
		return NSLocalizedString(key, bundle: uiTestBundle, comment: "")
	}
	
	// print labels to console
	static func printLabels(_ query: XCUIElementQuery) {
		for (index, value) in labelsOfElement(query).enumerated() {
			print("Label \(index + 1): \(value)")
		}
	}
	
	// print accessibility identifiers to console
	static func printAccIdentifiers(_ query: XCUIElementQuery) {
		for (index, value) in accIdentifiersOfElement(query).enumerated() {
			print("Acc.Id \(index + 1): \(value)")
		}
	}

	// print accessibility labels to console
	static func printAccLabels(_ query: XCUIElementQuery) {
		for (index, value) in accLabelsOfElement(query).enumerated() {
			print("Acc.Label \(index + 1): \(value)")
		}
	}

	// label attributes
	static func labelsOfElement(_ query: XCUIElementQuery) -> [String] {
		var labels = [String]()
		let n = query.count
		if n > 0 {
			for i in 0...(n - 1) {
				labels.append(query.element(boundBy: i).label)
			}
		}
		return labels
	}
	
	// accessibility identifiers
	static func accIdentifiersOfElement(_ query: XCUIElementQuery) -> [String] {
		var identifiers = [String]()
		let n = query.count
		if n > 0 {
			for i in 0...(n - 1) {
				identifiers.append(query.element(boundBy: i).identifier)
			}
		}
		return identifiers
	}
	
	// labels that identifies the accessibility element, in a localized string.
	static func accLabelsOfElement(_ query: XCUIElementQuery) -> [String] {
		var labels = [String]()
		let n = query.count
		if n > 0 {
			for i in 0...(n - 1) {
				labels.append(query.element(boundBy: i).accessibilityLabel ?? "")
			}
		}
		return labels
	}
	
	// title attributes
	static func titleOfElement(_ query: XCUIElementQuery) -> [String] {
		var titles = [String]()
		let n = query.count
		if n > 0 {
			for i in 0...(n - 1) {
				titles.append(query.element(boundBy: i).title)
			}
		}
		return titles
	}
	
	static func find(value searchValue: String, in array: [String]) -> Int? {
		if let index = array.firstIndex(of: searchValue) {
			return index
		} else {
			return nil
		}
	}

}

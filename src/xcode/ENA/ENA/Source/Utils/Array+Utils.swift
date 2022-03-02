//
// 🦠 Corona-Warn-App
//

import Foundation
import OrderedCollections

extension Array where Element: Equatable {
	
	mutating func remove(_ element: Element) {
		if let index = firstIndex(of: element) {
			remove(at: index)
		}
	}
	
	mutating func remove(elements: [Element]) {
		for element in elements {
			remove(element)
		}
	}
	
	mutating func replace(_ element: Element, with otherElement: Element) {
		if let index = firstIndex(of: element) {
			self[index] = otherElement
		}
	}
}

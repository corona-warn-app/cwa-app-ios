//
// 🦠 Corona-Warn-App
//

import Foundation

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
}

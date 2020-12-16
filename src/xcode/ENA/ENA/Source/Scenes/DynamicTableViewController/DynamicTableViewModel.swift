//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct DynamicTableViewModel {

	// MARK: - Init

	init(_ content: [DynamicSection]) {
		self.content = content
	}

	// MARK: - Internal

	static func with(
		creator: (_ model: inout DynamicTableViewModel) -> Void
	) -> DynamicTableViewModel {
		var model = DynamicTableViewModel([])
		creator(&model)
		return model
	}

	var content: [DynamicSection]
	var numberOfSection: Int { content.count }

	func section(_ section: Int) -> DynamicSection {
		content[section]
	}

	func section(at indexPath: IndexPath) -> DynamicSection {
		section(indexPath.section)
	}

	func cell(at indexPath: IndexPath) -> DynamicCell {
		content[indexPath.section].cells[indexPath.row]
	}

	func numberOfRows(section index: Int) -> Int? {
		guard content.indices.contains(index) else {
			return nil
		}
		return section(index).cells.count
	}
	
	func numberOfRows(inSection section: Int, for _: DynamicTableViewController) -> Int {
		self.section(section).cells.count
	}
	
	mutating func add(_ section: DynamicSection) {
		content.append(section)
	}
}

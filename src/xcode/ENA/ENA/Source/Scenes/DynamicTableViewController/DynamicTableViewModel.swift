import Foundation
import UIKit

struct DynamicTableViewModel {
	static func with(
		creator: (_ model: inout DynamicTableViewModel) -> Void
	) -> DynamicTableViewModel {
		var model = DynamicTableViewModel([])
		creator(&model)
		return model
	}

	private var content: [DynamicSection]

	init(_ content: [DynamicSection]) {
		self.content = content
	}

	func section(_ section: Int) -> DynamicSection {
		content[section]
	}

	func section(at indexPath: IndexPath) -> DynamicSection {
		section(indexPath.section)
	}

	func cell(at indexPath: IndexPath) -> DynamicCell {
		content[indexPath.section].cells[indexPath.row]
	}

	var numberOfSection: Int { content.count }
	func numberOfRows(inSection section: Int, for _: DynamicTableViewController) -> Int { self.section(section).cells.count }

	mutating func add(_ section: DynamicSection) {
		content.append(section)
	}
}

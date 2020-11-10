// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

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

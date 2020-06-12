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

struct DynamicSection {
	let header: DynamicHeader
	let footer: DynamicFooter
	let separators: Bool
	private let isHidden: ((DynamicTableViewController) -> Bool)?
	let cells: [DynamicCell]

	func isHidden(for viewController: DynamicTableViewController) -> Bool {
		isHidden?(viewController) ?? false
	}

	private init(header: DynamicHeader, footer: DynamicFooter, separators: Bool, isHidden: ((DynamicTableViewController) -> Bool)?, cells: [DynamicCell]) {
		self.header = header
		self.footer = footer
		self.separators = separators
		self.isHidden = isHidden
		self.cells = cells
	}

	static func section(header: DynamicHeader = .none, footer: DynamicFooter = .none, separators: Bool = false, isHidden: ((DynamicTableViewController) -> Bool)? = nil, cells: [DynamicCell]) -> Self {
		.init(header: header, footer: footer, separators: separators, isHidden: isHidden, cells: cells)
	}
}

extension DynamicSection {
	static func navigationSubtitle(text: String, insets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 8, right: 16), accessibilityIdentifier: String?) -> Self {
		.section(cells: [
			.subheadline(text: text, color: .enaColor(for: .textPrimary2), accessibilityIdentifier: accessibilityIdentifier) { _, cell, _ in
				cell.contentView.preservesSuperviewLayoutMargins = false
				cell.contentView.layoutMargins = insets
				cell.accessibilityIdentifier = accessibilityIdentifier
				cell.accessibilityTraits = .header
			}
		])
	}
}

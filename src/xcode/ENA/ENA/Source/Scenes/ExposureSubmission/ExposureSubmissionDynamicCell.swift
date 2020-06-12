//
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
//

import Foundation
import UIKit

enum ExposureSubmissionDynamicCell {
	static func stepCell(title: String, description: String?, icon: UIImage?, iconTint: UIColor? = nil, hairline: ExposureSubmissionStepCell.Hairline, bottomSpacing: ExposureSubmissionStepCell.Spacing = .large, action: DynamicAction = .none) -> DynamicCell {
		.identifier(ExposureSubmissionSuccessViewController.CustomCellReuseIdentifiers.stepCell, action: action) { _, cell, _ in
			guard let cell = cell as? ExposureSubmissionStepCell else { return }
			cell.configure(title: title, description: description, icon: icon, iconTint: iconTint, hairline: hairline, bottomSpacing: bottomSpacing)
		}
	}

	static func stepCell(style: ENAFont, color: UIColor = .enaColor(for: .textPrimary1), title: String, icon: UIImage? = nil, iconAccessibilityLabel: String? = nil, iconTint: UIColor? = nil, hairline: ExposureSubmissionStepCell.Hairline, bottomSpacing: ExposureSubmissionStepCell.Spacing = .large, action: DynamicAction = .none) -> DynamicCell {
		.identifier(ExposureSubmissionSuccessViewController.CustomCellReuseIdentifiers.stepCell, action: action) { _, cell, _ in
			guard let cell = cell as? ExposureSubmissionStepCell else { return }
			cell.configure(style: style, color: color, title: title, icon: icon, iconTint: iconTint, hairline: hairline, bottomSpacing: bottomSpacing)
			cell.titleLabel.accessibilityLabel = [iconAccessibilityLabel, cell.titleLabel.accessibilityLabel]
				.compactMap({ $0 })
				.joined(separator: ": ")
		}
	}

	static func stepCell(bulletPoint title: String, hairline: ExposureSubmissionStepCell.Hairline = .none, bottomSpacing: ExposureSubmissionStepCell.Spacing = .normal, action: DynamicAction = .none) -> DynamicCell {
		.identifier(ExposureSubmissionSuccessViewController.CustomCellReuseIdentifiers.stepCell, action: action) { _, cell, _ in
			guard let cell = cell as? ExposureSubmissionStepCell else { return }
			cell.configure(bulletPoint: title, hairline: hairline, bottomSpacing: bottomSpacing)
		}
	}
}

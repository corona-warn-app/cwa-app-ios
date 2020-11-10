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

struct ExposureSubmissionQRInfoViewModel {

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					header: .image(
						UIImage(imageLiteralResourceName: "Illu_Submission_QRPrimer"),
						accessibilityLabel: AppStrings.ExposureSubmissionQRInfo.imageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.accImageDescription,
						height: 250
					),
					cells: [
						.icon(
							UIImage(imageLiteralResourceName: "Icons_QR1"),
							text: .string(AppStrings.ExposureSubmissionQRInfo.instruction1)
						),
						.icon(
							UIImage(imageLiteralResourceName: "Icons_QR2"),
							text: .attributedString(
								AppStrings.ExposureSubmissionQRInfo.instruction2
									.inserting(emphasizedString: AppStrings.ExposureSubmissionQRInfo.instruction2HighlightedPhrase)
							)
						),
						.icon(
							UIImage(imageLiteralResourceName: "Icons_QR3"),
							text: .attributedString(
								AppStrings.ExposureSubmissionQRInfo.instruction3
									.inserting(emphasizedString: AppStrings.ExposureSubmissionQRInfo.instruction3HighlightedPhrase)
							)
						),
						.icon(
							UIImage(imageLiteralResourceName: "Icons_QR4"),
							text: .string(AppStrings.ExposureSubmissionQRInfo.instruction4)
						)
					]
				)
			)
		}
	}

}

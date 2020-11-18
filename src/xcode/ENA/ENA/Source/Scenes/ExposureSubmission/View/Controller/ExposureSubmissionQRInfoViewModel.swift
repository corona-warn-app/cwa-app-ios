//
// 🦠 Corona-Warn-App
//

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
							text: .string(AppStrings.ExposureSubmissionQRInfo.instruction3) // will be refactored!
						)
					]
				)
			)
		}
	}

}

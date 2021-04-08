////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct TestOverwriteNoticeViewModel {

	// MARK: - Init

	init(_ testType: CoronaTestType) {
		self.title = AppStrings.ExposureSubmission.OverwriteNotice.title
		self.image = UIImage(imageLiteralResourceName: "Illu_Overwrite_Notice")

		switch testType {
		case .pcr:
			self.headline = AppStrings.ExposureSubmission.OverwriteNotice.Pcr.headline
			self.text = AppStrings.ExposureSubmission.OverwriteNotice.Pcr.text

		case .antigen:
			self.headline = AppStrings.ExposureSubmission.OverwriteNotice.Antigen.headline
			self.text = AppStrings.ExposureSubmission.OverwriteNotice.Antigen.text

		}
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	let image: UIImage
	let title: String
	let headline: String
	let text: String

	// MARK: - Private

}

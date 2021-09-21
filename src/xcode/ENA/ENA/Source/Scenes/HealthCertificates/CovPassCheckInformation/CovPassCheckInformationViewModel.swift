//
// 🦠 Corona-Warn-App
//

import UIKit


final class CovPassCheckInformationViewModel {

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				cells: [
					.headlineWithImage(
						headerText: AppStrings.CovPass.Information.title,
						topInset: 14.0,
						image: UIImage(imageLiteralResourceName: "Illu_CovPass_Check"
									  )
					),
					.space(height: 12.0),
					.body(text: AppStrings.CovPass.Information.body),
					.textWithLinks(text: AppStrings.CovPass.Information.faq, links: [AppStrings.CovPass.Information.faq: AppStrings.CovPass.Information.faqLink]),
					.bulletPoint(
						text: AppStrings.CovPass.Information.section01
					),
					.space(height: 12.0),
					.bulletPoint(
						text: AppStrings.CovPass.Information.section02
					),
					.space(height: 12.0),
					.bulletPoint(
						text: AppStrings.CovPass.Information.section03
					)
				]
			)
		])
	}

}

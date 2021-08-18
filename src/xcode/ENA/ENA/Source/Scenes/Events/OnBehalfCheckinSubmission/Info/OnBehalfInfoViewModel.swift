//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import class CertLogic.ValidationResult

struct OnBehalfInfoViewModel: HealthCertificateValidationResultViewModel {

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				cells: [
					.headlineWithImage(
						headerText: AppStrings.OnBehalfCheckinSubmission.Info.title,
						image: UIImage(imageLiteralResourceName: "OnBehalf_Info_TitleIllu")
					),
					.title2(text: AppStrings.OnBehalfCheckinSubmission.Info.subtitle),
					.subheadline(
						text: AppStrings.OnBehalfCheckinSubmission.Info.description,
						color: .enaColor(for: .textPrimary2)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icon_OnBehalf_Bullet1"),
						text: .string(AppStrings.OnBehalfCheckinSubmission.Info.bulletPoint1),
						alignment: .top
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icon_OnBehalf_Bullet2"),
						text: .string(AppStrings.OnBehalfCheckinSubmission.Info.bulletPoint2),
						alignment: .top
					)
				]
			)
		])
	}

}

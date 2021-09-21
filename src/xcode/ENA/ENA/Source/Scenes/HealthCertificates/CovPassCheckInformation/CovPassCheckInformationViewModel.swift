//
// 🦠 Corona-Warn-App
//

import UIKit


final class CovPassCheckInformationViewModel {

	// MARK: - Init

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				cells: [
					.headlineWithImage(
						headerText: AppStrings.CovPass.Information.title,
						image: UIImage(imageLiteralResourceName: "Illu_CovPass_Check"
									  )
					),
					.space(height: 12.0),
					.body(text: "Dritte können nur mit der CovPassCheck-App verlässlich überprüfen, ob es sich um ein valides Impf-, Genesenen-, oder Testzertifikat handelt."),
					.link(
						text: "FAQ zur Zertifikatsprüfung durch Dritte",
						url: URL(staticString: "https://www.coronawarn.app/de/faq/#eu_dcc_check"),
						accessibilityIdentifier: nil
					),
					.bulletPoint(
						text: "Sie selbst können Zertifikate in der Corona-Warn-App auf Gültigkeit prüfen und benötigen dazu nicht die CovPassCheck-App."
					),
					.space(height: 12.0),
					.bulletPoint(
						text: "Für Dritte reicht eine Sichtprüfung der Zertifikate nicht aus. Sie müssen in Deutschland die CovPassCheck-App nutzen."
					),
					.space(height: 12.0),
					.bulletPoint(
						text: "Bitte beachten Sie, dass in anderen Ländern andere Apps zur Zertifikatsprüfung durch Dritte verwendet werden."
					)
				]
			)
		])
	}

	// MARK: - Private
}

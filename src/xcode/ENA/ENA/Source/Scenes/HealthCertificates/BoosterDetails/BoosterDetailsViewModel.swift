//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class BoosterDetailsViewModel {
	
	// MARK: - Internal
	
	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					header: .image(
						UIImage(named: "Illustration_Datenspendedatenspende_heart"),
						accessibilityLabel: AppStrings.NotificationSettings.imageDescriptionOn,
						accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.DeltaOnboarding.imageOn,
						height: 200
					),
					cells: [
						.title1(text: "Hinweis zur Auffrischimpfung"),
						.subheadline(text: "auf Grundlage Ihrer gespeicherten Zertifikate", color: .enaColor(for: .textPrimary2)) { _, cell, _ in
							cell.contentView.preservesSuperviewLayoutMargins = false
							cell.contentView.layoutMargins.left += 5
							cell.contentView.layoutMargins.top = 0
						}
					]
				)
			)
			$0.add(
				.section(
					cells: [
						.body(text: "Die Ständige Impfkommission (STIKO) empfiehlt allen Personen eine weitere Impfstoffdosis zur Optimierung der Grundimmunisierung, die mit einer Dosis des Janssen-Impfstoffs (Johnson & Johnson) grundimmunisiert wurden, bei denen keine Infektion mit dem Coronavirus SARS-CoV-2 nachgewiesen wurde und wenn ihre Janssen-Impfung über 4 Wochen her ist.\nDa Sie laut Ihrer gespeicherten Zertifikate bald dieser Personengruppe angehören und noch keine weitere Impfung erhalten haben, möchten wir Sie auf diese Empfehlung hinweisen. (Regel BNR-DE-0200)\nDieser Hinweis basiert ausschließlich auf den auf Ihrem Smartphone gespeicherten Zertifikaten. Die Verarbeitung der Daten erfolgte auf Ihrem Smartphone. Es wurden hierbei keine Daten an das RKI oder Dritte übermittelt."),
						.body(text: "Mehr Informationen finden Sie in den FAQ.")
					]
				)
			)
		}
	}
}

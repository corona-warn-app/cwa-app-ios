////
// 🦠 Corona-Warn-App
//

import UIKit

final class ErrorReportDetailInformationViewModel {
	
	// MARK: - Init
	
	init() {

	}
	
	// MARK: - Internal
	
	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			
			$0.add(
				.section(
					cells: [
						.title1(text: "ErrorReport Ausführliche Informationen", accessibilityIdentifier: "AppStrings.DataDonation.DetailedInfo.title"),
						.space(height: 20),
						.custom(
							withIdentifier: DataDonationDetailsViewController.CustomCellReuseIdentifiers.roundedCell,
							configure: { _, cell, _ in
								guard let cell = cell as? DynamicTableViewRoundedCell else { return }
								// grey box with legal text:
								cell.configure(
									title: NSMutableAttributedString(
										string: "AppStrings.ErrorReport.detailedInfo_Headline"
									),
									body: NSMutableAttributedString(
										string: "AppStrings.ErrorReport.detailedInfo_Content"
									),
									textColor: .textPrimary1,
									bgColor: .separator
								)
							}
						),
						.space(height: 20),
						.headline(text: "Prüfung der Echtheit und Drittlandsübermittlung", accessibilityIdentifier: "AppStrings.DataDonation.DetailedInfo.headline"),
						.space(height: 20),
						.body(text: "Um die Echtheit Ihrer App zu bestätigen, erzeugt Ihr Smartphone eine eindeutige Kennung, die Informationen über die Version Ihres Smartphones und der App enthält. Das ist erforderlich, um sicherzustellen, dass nur Nutzer Daten auf diesem Weg an den technischen Support übersenden, die tatsächlich die Corona-Warn-App nutzen und nicht manipulierte Fehlerberichte bereitstellen. Die Kennung wird dafür einmalig an Apple übermittelt. Dabei kann es auch zu einer Datenübermittlung in die USA oder andere Drittländer kommen. Dort besteht möglicherweise kein dem europäischen Recht entsprechendes Datenschutzniveau und Ihre europäischen Datenschutzrechte können eventuell nicht durchgesetzt werden. " +
							"Insbesondere besteht die Möglichkeit, dass Sicherheitsbehörden im Drittland, auch ohne einen konkreten Verdacht, auf die übermittelten Daten bei Apple zugreifen und diese auswerten, beispielsweise indem sie Daten mit anderen Informationen verknüpfen. Dies betrifft nur die an Apple übermittelte Kennung. Die Angaben aus Ihrem Fehlerbericht erhält Apple nicht. Möglicherweise kann Apple jedoch anhand der Kennung auf Ihre Identität schließen und nachvollziehen, dass die Echtheitsprüfung Ihres Smartphones stattgefunden hat.\n\n" +
							"Um die Echtheit Ihrer App zu bestätigen, erzeugt Ihr Smartphone eine eindeutige Kennung, die Informationen über die Version Ihres Smartphones und der App enthält. Das ist erforderlich, um sicherzustellen, dass nur Nutzer Daten auf diesem Weg an den technischen Support übersenden, die tatsächlich die Corona-Warn-App nutzen und nicht manipulierte Fehlerberichte bereitstellen. Die Kennung wird dafür einmalig an Apple übermittelt. Dabei kann es auch zu einer Datenübermittlung in die USA oder andere Drittländer kommen. Dort besteht möglicherweise kein dem europäischen Recht entsprechendes Datenschutzniveau und Ihre europäischen Datenschutzrechte können eventuell nicht durchgesetzt werden. Insbesondere besteht die Möglichkeit, dass Sicherheitsbehörden im Drittland, auch ohne einen konkreten Verdacht, auf die übermittelten Daten bei Apple zugreifen und diese auswerten, beispielsweise indem sie Daten mit anderen Informationen verknüpfen. " +
								"Dies betrifft nur die an Apple übermittelte Kennung. Die Angaben aus Ihrem Fehlerbericht erhält Apple nicht. Möglicherweise kann Apple jedoch anhand der Kennung auf Ihre Identität schließen und nachvollziehen, dass die Echtheitsprüfung Ihres Smartphones stattgefunden hat.\n\n" +
								"Wenn Sie mit der Drittlandsübermittlung nicht einverstanden sind, tippen Sie bitte nicht „Einverstanden und Fehlerbericht senden“ an. Sie können die App weiterhin nutzen, eine Übersendung des Fehlerberichtes über die App ist dann jedoch nicht möglich.",
							  accessibilityIdentifier: "AppStrings.DataDonation.DetailedInfo.paragraph6")
					]
				)
			)
		}
	}
	
}

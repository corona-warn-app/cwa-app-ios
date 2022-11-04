//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class TypeOfTestViewModel {
	
	var dynamicTableViewModel: DynamicTableViewModel {
		.init([
			.section(
				header: .none,
				footer: .none,
				separators: .none,
				isHidden: nil,
				background: .none,
				cells: [
					.body(
						text: "Bitte wählen Sie die Art des Tests aus, auf dessen Grundlage Sie warnen.",
						accessibilityIdentifier: nil
					),
					.custom(
						withIdentifier: ExposureSubmissionSymptomsViewController.CustomCellReuseIdentifiers.optionGroupCell,
						configure: { _, cell, _ in
							guard let cell = cell as? DynamicTableViewOptionGroupCell else {
								return
							}
							
							let options: [OptionGroupViewModel.Option] = self.submissionTypeForChoosing
								.map {
									(title: $0.optionTitle, accessibilityIdentifier: $0.optionAccessibilityIdentifier)
								}
								.filter {
									!$0.title.isEmpty
								}
								.map {
									.option(
										title: $0.title,
										accessibilityIdentifier: $0.accessibilityIdentifier
									)
								}
							
							cell.configure(
								options: options,
								initialSelection: nil
							)
							
							self.optionGroupSelectionSubscription = cell.$selection.sink {
								print($0)
							}
						})
				]
			)
		])
	}
	
	private let submissionTypeForChoosing: [SAP_Internal_SubmissionPayload.SubmissionType] = [
		.srsRat,
		.srsRegisteredPcr,
		.srsUnregisteredPcr,
		.srsRapidPcr,
		.srsOther
	]
	
	private var optionGroupSelectionSubscription: AnyCancellable?
}

fileprivate extension SAP_Internal_SubmissionPayload.SubmissionType {
	var optionTitle: String {
		switch self {
		case .srsSelfTest:
			return "Selbsttest"
		case .srsRat:
			return "Schnelltest"
		case .srsRegisteredPcr:
			return "PCR-Labortest in der App registriert, aber kein Ergebnis erhalten"
		case .srsUnregisteredPcr:
			return "PCR-Labortest nicht in der App registriert"
		case .srsRapidPcr:
			return "PCR-Schnelltest (PoC-NAT-Test)"
		case .srsOther:
			return "Sonstige / keine Angabe"
		default:
			return ""
		}
	}
	
	var optionAccessibilityIdentifier: String? {
		switch self {
		case .srsSelfTest:
			return "srsSelfTest.Identifier"
		case .srsRat:
			return "srsRat.Identifier"
		case .srsRegisteredPcr:
			return "srsRegisteredPcr.Identifier"
		case .srsUnregisteredPcr:
			return "srsUnregisteredPcr.Identifier"
		case .srsRapidPcr:
			return "srsRapidPcr.Identifier"
		case .srsOther:
			return "srsOther.Identifier"
		default:
			return nil
		}
	}
}

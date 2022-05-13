//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

final class AccompanyingCertificatesViewModel {

	// MARK: - Init

	init(certificates: [HealthCertificate], certifiedPerson: HealthCertifiedPerson) {
		self.certificates = certificates
		self.certifiedPerson = certifiedPerson
	}

	// MARK: - Internal

	let title: String = AppStrings.HealthCertificate.Reissuance.Consent.title

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					cells: [
						.title2(text: AppStrings.HealthCertificate.Reissuance.AccompanyingCertificates.title),
						.body(text: AppStrings.HealthCertificate.Reissuance.AccompanyingCertificates.description)
					]
					.compactMap({ $0 })
			   )
			)
			for certificate in certificates {
				$0.add(
					.section(
						cells: [
							.certificate(certificate, certifiedPerson: certifiedPerson)
						]
						.compactMap({ $0 })
					)
				)
			}
		}
	}

	// MARK: - Private

	private let certificates: [HealthCertificate]
	private let certifiedPerson: HealthCertifiedPerson
}

private extension DynamicCell {
	static func certificate(_ certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson) -> Self {
		.custom(withIdentifier: HealthCertificateCell.dynamicTableViewCellReuseIdentifier) { _, cell, _ in
			guard let cell = cell as? HealthCertificateCell else {
				return
			}
			cell.configure(
				HealthCertificateCellViewModel(
					healthCertificate: certificate,
					healthCertifiedPerson: certifiedPerson,
					details: .overviewPlusName
				),
				withDisclosureIndicator: false
			)
		}
	}
}

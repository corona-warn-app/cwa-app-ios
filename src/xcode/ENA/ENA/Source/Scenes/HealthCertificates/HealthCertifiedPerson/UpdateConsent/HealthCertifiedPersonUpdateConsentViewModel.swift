//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

/// Error and ViewModel are dummies for the moment to construct the flow for the moment
/// needed to get replaced in later tasks
///
enum HealthCertifiedPersonUpdateError: Error {
	case UpdateFailedError
}


struct HealthCertifiedPersonUpdateConsentViewModel {

	// MARK: - Init

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	let title: String = AppStrings.HealthCertificate.Person.UpdateConsent.title

	let dynamicTableViewModel: DynamicTableViewModel = {
		DynamicTableViewModel(
			[
				.section(
					cells: [
						.title2(text: AppStrings.HealthCertificate.Person.UpdateConsent.headline),
						.subheadline(text: AppStrings.HealthCertificate.Person.UpdateConsent.subHeadline),
						.body(text: AppStrings.HealthCertificate.Person.UpdateConsent.body_1),
						.body(text: AppStrings.HealthCertificate.Person.UpdateConsent.body_2)
					]
				),
				.section(
					cells: [
						.icon(
							UIImage(imageLiteralResourceName: "more_recycle_bin"),
							text: .string(AppStrings.HealthCertificate.Person.UpdateConsent.deleteNotice),
							alignment: .top
						),
						.icon(
							UIImage(imageLiteralResourceName: "Icons_Certificates_01"),
							text: .string(AppStrings.HealthCertificate.Person.UpdateConsent.cancelNotice),
							alignment: .top
						)
					]
				)
			]
		)
	}()

	func submit(completion: @escaping (Result<Void, HealthCertifiedPersonUpdateError>) -> Void) {
		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5) {
			// let's create a random result
			let success = Bool.random()
			if success {
				completion(.success(()))
			} else {
				completion(.failure(.UpdateFailedError))
			}
		}
	}

	// MARK: - Private

}

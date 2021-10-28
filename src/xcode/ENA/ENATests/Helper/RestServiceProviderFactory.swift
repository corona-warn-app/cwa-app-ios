//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
@testable import ENA

extension CoronaTestService {
	convenience init(
		client: Client,
		store: CoronaTestStoring & CoronaTestStoringLegacy & WarnOthersTimeIntervalStoring,
		eventStore: EventStoringProviding,
		diaryStore: DiaryStoring,
		appConfiguration: AppConfigurationProviding,
		healthCertificateService: HealthCertificateService,
		notificationCenter: UserNotificationCenter = UNUserNotificationCenter.current()
	) {
		self.init(
			client: client,
			restServiceProvider: .coronaTestServiceProvider,
			store: store,
			eventStore: eventStore,
			diaryStore: diaryStore,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			notificationCenter: notificationCenter
		)
	}
}

extension RestServiceProviding where Self == RestServiceProviderStub {

	static var coronaTestServiceProvider: RestServiceProviderStub {
		RestServiceProviderStub(results: [
			.success(
				RegistrationTokenModel(registrationToken: "registrationToken")
			)
		])
	}
}

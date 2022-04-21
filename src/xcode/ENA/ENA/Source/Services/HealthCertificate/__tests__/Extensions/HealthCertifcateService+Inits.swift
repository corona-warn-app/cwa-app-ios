//
// 🦠 Corona-Warn-App
//

import XCTest	
import Foundation
import HealthCertificateToolkit
@testable import ENA

extension HealthCertificateService {
	convenience init(
		store: HealthCertificateStoring,
		dccSignatureVerifier: DCCSignatureVerifying,
		dscListProvider: DSCListProviding,
		appConfiguration: AppConfigurationProviding,
		digitalCovidCertificateAccess: DigitalCovidCertificateAccessProtocol = DigitalCovidCertificateAccess(),
		notificationCenter: UserNotificationCenter = UNUserNotificationCenter.current(),
		cclService: CCLServable,
		recycleBin: RecycleBin
	) {
		self.init(
			store: store,
			dccSignatureVerifier: dccSignatureVerifier,
			dscListProvider: dscListProvider,
			appConfiguration: appConfiguration,
			cclService: cclService,
			recycleBin: recycleBin,
			healthCertificateValidator: HealthCertificateValidatorFake()
		)
	}
}

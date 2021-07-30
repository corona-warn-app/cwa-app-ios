//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

#if DEBUG

struct MockDSCListProvider: DSCListProviding {

	var signingCertificates = CurrentValueSubject<[DCCSigningCertificate], Never>([])

}

#endif

////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

class TraceWarningPackageDownloadTests: XCTestCase {
	
	private lazy var dummyResponseDiscovery: TraceWarningDiscovery = {
		let response = TraceWarningDiscovery(oldest: 1, latest: 1, eTag: "FakeEtag")
		return response
	}()
	
	private lazy var dummyResponseDownload: Int = {
		return 1
	}()

}

////
// 🦠 Corona-Warn-App
//

import Foundation

enum Route {

	// MARK: - Init

	init?(_ stringURL: String?) {
		guard let stringURL = stringURL,
			let url = URL(string: stringURL) else {
			return nil
		}
		self.init(url: url)
	}

	init?(url: URL) {
		#if DEBUG
		// Dev code!
		self = .checkin("BAAREMYIAEJBYQLEOZQW4Y3FMQQE22LDOJXSARDFOZUWGZLTFQQES3TDFYNA2OJVEBHGSZLLN4QEYYLOMUUAAMAADJYQQAISLMYFSMATAYDSVBSIZY6QEAIGBAVIMSGOHUBQCBYDIIAAI45QYSZNOFBBC4ZJG7SOMAZH3Z7YKOBXKFMGY2BVZJHUZSXM3BDT26RSZYVEJHHKO4NSGVYNLJND4LO4AH2CNRPLQUYZACC7N65AHFPBUEDW3VYT4OT7FQWBVRW5D643HDA5EIDAQAIQBAMCG")
		#else
		let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
		guard components?.host?.lowercased() == "e.coronawarn.app",
			let lowercasedPath = components?.path.lowercased(),
			  lowercasedPath.contains("/c1") else {
			return nil
		}
		self = .checkin(url.lastPathComponent)
		#endif
	}

	// MARK: - Internal

	case checkin(String)

}

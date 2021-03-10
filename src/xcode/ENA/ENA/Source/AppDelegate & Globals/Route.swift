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
		let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
		guard components?.host?.lowercased() == "coronawarn.app",
			let lowercasedPath = components?.path.lowercased(),
			  lowercasedPath.contains("/e1") else {
			return nil
		}
		self = .checkin(url.lastPathComponent)
	}

	// MARK: - Internal

	case checkin(String)

}

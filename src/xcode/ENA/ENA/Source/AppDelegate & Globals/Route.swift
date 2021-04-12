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
		guard let host = components?.host?.lowercased() else {
			return nil
		}

		switch host {
		case "s.coronawarn.app":
			self = .rapidAntigen(url.absoluteString)

		case "e.coronawarn.app":
			self = .checkin(url.absoluteString)

		default:
			return nil
		}

	}

	// MARK: - Internal

	case checkin(String)
	case rapidAntigen(String)

}

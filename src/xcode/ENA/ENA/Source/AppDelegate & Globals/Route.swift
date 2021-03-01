////
// 🦠 Corona-Warn-App
//

import Foundation

enum Route {

	// MARK: - Init

	init?(url: URL) {
		let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
		guard let lowercasedPath = components?.path.lowercased(),
			  lowercasedPath.contains("/e1") else {
			return nil
		}
		self = .event(url.lastPathComponent)
	}

	// MARK: - Internal

	case event(String)

}

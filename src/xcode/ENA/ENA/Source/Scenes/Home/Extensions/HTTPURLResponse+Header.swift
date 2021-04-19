////
// 🦠 Corona-Warn-App
//

import UIKit

extension HTTPURLResponse {

	var dateHeader: Date? {
		if let dateString = value(forCaseInsensitiveHeaderField: "Date") {
			return ENAFormatter.httpDateHeaderFormatter.date(from: dateString)
		} else {
			return nil
		}
	}


	/// Returns a header value for a given key.
	///
	///	We can't use `value(forHTTPHeaderField:)` because it's [not available in iOS 12.5](https://developer.apple.com/documentation/foundation/httpurlresponse/3240613-value).
	///
	/// - Parameter headerField: The header fiels to fetch. (case-insensitive, obviously)
	/// - Returns: The value of the given header field, if existing.
	func value(forCaseInsensitiveHeaderField headerField: String) -> String? {
		//  https://bugs.swift.org/browse/SR-2429?focusedCommentId=55490&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-55490
		(allHeaderFields as NSDictionary)[headerField] as? String
	}

}

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

	func value(forCaseInsensitiveHeaderField headerField: String) -> String? {
		/// https://bugs.swift.org/browse/SR-2429?focusedCommentId=55490&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-55490
		(allHeaderFields as NSDictionary)[headerField] as? String
	}

}

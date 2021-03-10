//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification

// These extensions enable some of the errors in our project to have their corresponding
// FAQ links.

extension ExposureSubmissionError {
	/// Returns the correct shortlink based on the underlying EN notification error.
	var faqURL: URL? {
		switch self {
		case .unsupported:
			return URL(string: AppStrings.Links.appFaqENError5)
		case .internal:
			return URL(string: AppStrings.Links.appFaqENError11)
		case .rateLimited:
			return URL(string: AppStrings.Links.appFaqENError13)
		default: return nil
		}
	}
}

extension ENError {
	var faqURL: URL? {
		switch code {
		case .unsupported:
			return URL(string: AppStrings.Links.appFaqENError5)
		case .internal:
			return URL(string: AppStrings.Links.appFaqENError11)
		case .rateLimited:
			return URL(string: AppStrings.Links.appFaqENError13)
		default:
			return URL(string: AppStrings.Links.appFaq)
		}
	}
}

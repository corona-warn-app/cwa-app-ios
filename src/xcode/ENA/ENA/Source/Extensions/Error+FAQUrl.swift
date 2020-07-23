//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
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
		default: return nil
		}
	}
}

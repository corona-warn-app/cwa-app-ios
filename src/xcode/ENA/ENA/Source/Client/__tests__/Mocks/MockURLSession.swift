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

import Foundation

class MockURLSessionDataTask: URLSessionDataTask {
	private let completion: () -> Void

	init(completion: @escaping () -> Void) {
		self.completion = completion
	}

	override func resume() {
		completion()
	}
}

class MockUrlSession: URLSession {
	typealias URLRequestObserver = ((URLRequest) -> Void)
	let data: Data?
	let nextResponse: URLResponse?
	let error: Error?
	let onURLRequestObserver: URLRequestObserver?

	init(
		data: Data?,
		nextResponse: URLResponse?,
		error: Error?,
		urlRequestObserver: URLRequestObserver? = nil
	) {
		self.data = data
		self.nextResponse = nextResponse
		self.error = error
		self.onURLRequestObserver = urlRequestObserver
	}

	override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		onURLRequestObserver?(URLRequest(url: url))

		return MockURLSessionDataTask {
			completionHandler(self.data, self.nextResponse, self.error)
		}
	}

	override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		onURLRequestObserver?(request)

		return MockURLSessionDataTask {
			completionHandler(self.data, self.nextResponse, self.error)
		}
	}
}

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
	var onURLRequestObserver: URLRequestObserver?

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

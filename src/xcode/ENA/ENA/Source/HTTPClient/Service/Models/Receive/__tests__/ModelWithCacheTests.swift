//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
import ZIPFoundation
@testable import ENA

class ModelWithCacheTests: CWATestCase {
	
	func test_GIVEN_ModelWithCache_WHEN_RealModelIsFetchedFreshly_THEN_IsCachedIsFalse() throws {
		// GIVEN
		let expectation = expectation(description: "Expect that we got a completion")
		
		let archiveData = try createSomeCBORArchive()
		
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: [
				"ETag": "Some eTag"
			],
			responseData: archiveData
		)
		
		let resource = ResourceCachingCBORFake()
		resource.receiveResource = CBORReceiveResource(
			signatureVerifier: MockVerifier()
		)
		
		let cache = KeyValueCacheFake()
		
		let serviceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: cache
		)
		
		// WHEN
		serviceProvider.load(resource) { result in
			switch result {
				
			case let .success(cachingModel):
				// THEN
				XCTAssertFalse(cachingModel.isCached)
			case let .failure(error):
				XCTFail("Test should success but failed with error: \(error)")
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func test_GIVEN_ModelWithCache_WHEN_RealModelIsCached_THEN_IsCachedIsTrue() throws {
		// GIVEN
		let expectation = expectation(description: "Expect that we got a completion")
		
		let archiveData = try createSomeCBORArchive()
		
		let stack = MockNetworkStack(
			httpStatus: 304,
			headerFields: [
				"ETag": "Some eTag"
			],
			responseData: archiveData
		)
		
		let resource = ResourceCachingCBORFake()
		resource.receiveResource = CBORReceiveResource(
			signatureVerifier: MockVerifier()
		)
		
		let cache = KeyValueCacheFake()
		cache[resource.locator.hashValue] = CacheData(data: archiveData, eTag: "Some eTag", date: Date())
		
		let serviceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: cache
		)
		
		// WHEN
		serviceProvider.load(resource) { result in
			switch result {
				
			case let .success(cachingModel):
				// THEN
				XCTAssertFalse(cachingModel.isCached)
			case let .failure(error):
				XCTFail("Test should success but failed with error: \(error)")
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}
	
	func test_GIVEN_ModelWithCache_WHEN_NonCachingRestServiceIsUsed_THEN_IsCachedIsFalse() {
	
		// GIVEN
		
		// WHEN
		
		// THEN
		
		
	}
	
	private func createSomeCBORArchive() throws -> Data {
		return try XCTUnwrap(Archive.createArchiveData(
			accessMode: .create,
			cborData: HealthCertificateToolkit.someCBORData
		))
	}
	
}

private struct TestCachingModel: CBORDecoding {
		
	private init(property: String ) {
		self.property = property
	}

	let property: String
	
	static func decode(_ data: Data) -> Result<TestCachingModel, ModelDecodingError> {
		return Result.success(TestCachingModel(property: "Decoded Value"))
	}
}

private class ResourceCachingCBORFake: Resource {
	
	init(
		locator: Locator = .fake(),
		receiveResource: CBORReceiveResource<ModelWithCache<TestCachingModel>> = CBORReceiveResource<ModelWithCache<TestCachingModel>>()
	) {
		self.locator = locator
		self.type = .caching()
		self.sendResource = EmptySendResource()
		self.receiveResource = receiveResource
	}
	
	typealias Send = EmptySendResource
	typealias Receive = CBORReceiveResource<ModelWithCache<TestCachingModel>>
	typealias CustomError = Error
	
	let locator: Locator
	let type: ServiceType
	let sendResource: EmptySendResource
	var receiveResource: CBORReceiveResource<ModelWithCache<TestCachingModel>>
}

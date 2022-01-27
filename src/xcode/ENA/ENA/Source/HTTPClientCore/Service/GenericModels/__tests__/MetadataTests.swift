//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
import ZIPFoundation
@testable import ENA

class MetadataTests: CWATestCase {
	
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
		
		let resource = CBORReceiveTestResource()
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
				XCTAssertFalse(cachingModel.metaData.loadedFromCache)
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
		
		let resource = CBORReceiveTestResource()
		resource.receiveResource = CBORReceiveResource(
			signatureVerifier: MockVerifier()
		)
		
		let cache = KeyValueCacheFake()
		cache[resource.locator.hashValue] = CacheData(data: archiveData, eTag: "Some eTag",date: Date())
		
		let serviceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: cache
		)
		
		// WHEN
		serviceProvider.load(resource) { result in
			switch result {
				
			case let .success(cachingModel):
				// THEN
				XCTAssertTrue(cachingModel.metaData.loadedFromCache)
			case let .failure(error):
				XCTFail("Test should success but failed with error: \(error)")
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}
	
	func test_GIVEN_ModelWithCache_WHEN_NonCachingRestServiceIsUsed_THEN_IsCachedIsFalse() throws {
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
		
		let resource = CBORReceiveTestResource(
			type: .default
		)
		resource.receiveResource = CBORReceiveResource(
			signatureVerifier: MockVerifier()
		)
		
		let cache = KeyValueCacheFake()
		cache[resource.locator.hashValue] = CacheData(data: archiveData, eTag: "Some eTag",date: Date())
		
		let serviceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: cache
		)
		
		// WHEN
		serviceProvider.load(resource) { result in
			switch result {
				
			case let .success(cachingModel):
				// THEN
				XCTAssertFalse(cachingModel.metaData.loadedFromCache)
			case let .failure(error):
				XCTFail("Test should success but failed with error: \(error)")
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}
	
	private func createSomeCBORArchive() throws -> Data {
		return try XCTUnwrap(Archive.createArchiveData(
			accessMode: .create,
			cborData: HealthCertificateToolkit.someCBORData
		))
	}
	
}

private struct CBORDecodingTestModel: CBORDecodable & MetaDataProviding {
	
	// MARK: - Protocol CBORDecoding
	
	static func make(with data: Data) -> Result<CBORDecodingTestModel, ModelDecodingError> {
		return Result.success(CBORDecodingTestModel(property: "Decoded Value"))
	}
	
	// MARK: - Protocol MetaDataProviding

	var metaData: MetaData = MetaData()
	
	// MARK: - Internal
	
	let property: String
	
	// MARK: - Private
	
	private init(property: String ) {
		self.property = property
	}
}

private class CBORReceiveTestResource: Resource {
	
	init(
		locator: Locator = .fake(),
		type: ServiceType = .caching(),
		receiveResource: CBORReceiveResource<CBORDecodingTestModel> = CBORReceiveResource<CBORDecodingTestModel>()
	) {
		self.locator = locator
		self.type = type
		self.sendResource = EmptySendResource()
		self.receiveResource = receiveResource
	}
	
	typealias Send = EmptySendResource
	typealias Receive = CBORReceiveResource<CBORDecodingTestModel>
	typealias CustomError = Error
	
	let locator: Locator
	let type: ServiceType
	let sendResource: EmptySendResource
	var receiveResource: CBORReceiveResource<CBORDecodingTestModel>
}

//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity
import OpenCombine

final class AllowListService {
	
	// MARK: - Init
	
	init(
	    restServiceProvider: RestServiceProviding
	) {
		self.restServiceProvider = restServiceProvider
	}
	
	// MARK: - Private

	private let restServiceProvider: RestServiceProviding
	
	// MARK: - Internal

	@OpenCombine.Published var allowlist: TicketValidationAllowList?

	func fetchAllowList() {
		let resource = AllowListResource()
		restServiceProvider.load(resource) { result in
			switch result {
			case .success(let allowListProtoBuf):
				self.allowlist = allowListProtoBuf.allowlist
			case .failure(let error):
				Log.debug(error.localizedDescription, log: .ticketValidationAllowList)
			}
		}
	}
	
	func checkServerCertificateAgainstAllowlist(
		hostname: String,
		certificateChain: [Data], // can be construct by: Data(base64Encoded: x509String)
		allowlist: [ValidationServiceAllowlistEntry]
	) -> Result<Void, AllowListError> {
		guard let leafCertificate = certificateChain.first else {
			Log.debug("Certificate chain should include at least one certificate", log: .ticketValidationAllowList)
			return .failure(.CERT_PIN_MISMATCH)
		}
		// Find requiredFingerprints: the requiredFingerprints shall be set by mapping each entry in allowlist to their fingerprint256 attribute.

		let requiredFingerprints = allowlist.map({
			$0.fingerprint256
		})
		
		// Compare fingerprints: if the SHA-256 fingerprints of leafCertificate is not included in requiredFingerprints, the operation shall abort with error code CERT_PIN_MISMATCH.
		let leafFingerprint = leafCertificate.sha256().base64EncodedString()
		if requiredFingerprints.contains(where: {
			$0 == leafFingerprint
		}) {
			Log.debug("fingerprints found", log: .ticketValidationAllowList)
		} else {
			return .failure(.CERT_PIN_MISMATCH)
		}
		
		let requiredHostnames: [String] = allowlist.compactMap({
			$0.fingerprint256 == leafFingerprint ? $0.hostname : nil
		})
		if requiredHostnames.contains(where: {
			$0 == hostname
		}) {
			Log.debug("requiredHostnames found", log: .ticketValidationAllowList)
		} else {
			return .failure(.CERT_PIN_HOST_MISMATCH)
		}
		return .success(())
	}
	
	func checkServiceIdentityAgainstServiceProviderAllowlist(
		serviceProviderAllowlist: [Data],
		serviceIdentity: String
	) -> Result<Void, AllowListError> {
		
		if serviceProviderAllowlist.contains(where: {
			$0.sha256().base64EncodedString() == serviceIdentity.sha256()
		}) {
			return .success(())
		} else {
			return .failure(.SP_ALLOWLIST_NO_MATCH)
		}
	}
	
	func filterJWKsAgainstAllowList(allowList: [ValidationServiceAllowlistEntry], jwkSet: [JSONWebKey]) -> ([ValidationServiceAllowlistEntry], [JSONWebKey]) {
		
		var filteredAllowList = [ValidationServiceAllowlistEntry]()
		let filteredJwkSet = jwkSet.filter({
			guard let x509String = $0.x5c.first, let x509Data = Data(base64Encoded: x509String) else {
				return false
			}
			
			return allowList.contains { entry in
				if entry.fingerprint256 == x509Data.sha256().base64EncodedString() {
					filteredAllowList.append(entry)
					return true
				} else {
					return false
				}
			}
		})
		
		return (filteredAllowList, filteredJwkSet)
	}
}

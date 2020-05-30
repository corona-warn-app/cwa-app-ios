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

import ExposureNotification
import UIKit

protocol DMSubmissionStateViewControllerDelegate: AnyObject {
	func submissionStateViewController(
		_ controller: DMSubmissionStateViewController,
		getDiagnosisKeys completionHandler: @escaping ENGetDiagnosisKeysHandler
	)
}

/// This controller allows you to check if a previous submission of keys successfully ended up in the backend.
final class DMSubmissionStateViewController: UITableViewController {
	init(
		client: Client,
		delegate: DMSubmissionStateViewControllerDelegate
	) {
		self.client = client
		self.delegate = delegate
		super.init(style: .plain)
	}
	
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Properties
	
	private weak var delegate: DMSubmissionStateViewControllerDelegate?
	private let client: Client
	
	// MARK: UIViewController
	
	override func viewWillAppear(_: Bool) {
		navigationItem.rightBarButtonItem = UIBarButtonItem(
			title: "Check",
			style: .plain,
			target: self,
			action: #selector(performCheck)
		)
	}
	
	@objc
	func performCheck() {
		let group = DispatchGroup()
		
		group.enter()
		var allPackages = [SAPDownloadedPackage]()
		client.fetch { result in
			allPackages = result.allKeyPackages
			group.leave()
		}
		
		var localKeys = [ENTemporaryExposureKey]()
		
		group.enter()
		delegate?.submissionStateViewController(self) { keys, error in
			precondition(Thread.isMainThread)
			defer { group.leave() }
			
			if let error = error {
				self.present(
					UIAlertController(
						title: "Failed to get local diagnosis keys",
						message: error.localizedDescription,
						preferredStyle: .alert
					),
					animated: true
				)
				return
			}
			localKeys = keys ?? []
		}
		
		group.notify(queue: .main) {
			var remoteKeys = [Apple_TemporaryExposureKey]()
			do {
				for package in allPackages {
					remoteKeys.append(contentsOf: try package.keys())
				}
			} catch {
				logError(message: "Failed to get keys from package due to: \(error)")
			}
			let localKeysFoundRemotly = localKeys.filter { remoteKeys.containsKey($0) }
			let foundOwnKey = localKeysFoundRemotly.isEmpty == false
			let allLocalKeysFoundRemotly = localKeys.count == localKeysFoundRemotly.count
			let resultAlert = UIAlertController(title: "Results", message:
				"""
				# of local keys found remotly: \(localKeysFoundRemotly.count)
				found at least one key: \(foundOwnKey)
				found all keys: \(allLocalKeysFoundRemotly)
				""", preferredStyle: .actionSheet)
			self.present(resultAlert, animated: true, completion: nil)
		}
	}
}

private extension Data {
	// swiftlint:disable:next force_unwrapping
	static let binHeader = "EK Export v1    ".data(using: .utf8)!
	
	var withoutBinHeader: Data {
		let headerRange = startIndex ..< Data.binHeader.count
		
		guard subdata(in: headerRange) == Data.binHeader else {
			return self
		}
		return subdata(in: headerRange.endIndex ..< endIndex)
	}
}

extension SAPDownloadedPackage {
	var binProtobufData: Data {
		bin.withoutBinHeader
	}
	
	func keys() throws -> [Apple_TemporaryExposureKey] {
		let data = binProtobufData
		let export = try Apple_TemporaryExposureKeyExport(serializedData: data)
		return export.keys
	}
}

private extension Array where Element == Apple_TemporaryExposureKey {
	func containsKey(_ key: ENTemporaryExposureKey) -> Bool {
		contains { appleKey in
			appleKey.keyData == key.keyData
		}
	}
}

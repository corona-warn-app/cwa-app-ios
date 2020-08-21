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
import UIKit
@testable import ENA

class MockExposureSubmissionQRScannerViewController: QRScannerViewController {

	// MARK: - Mock callbacks.

	var dismissCallback: ((Bool, (() -> Void)?) -> Void)?
	var presentCallback: ((UIViewController, Bool, (() -> Void)?) -> Void)?

	// MARK: - QRScannerViewController methods.

	weak var delegate: ExposureSubmissionQRScannerDelegate?

	func dismiss(animated: Bool, completion: (() -> Void)?) {
		dismissCallback?(animated, completion)
	}

	func present(_ vc: UIViewController, animated: Bool, completion: (() -> Void)?) {
		presentCallback?(vc, animated, completion)
	}
}

class MockExposureSubmissionQRScannerDelegate: ExposureSubmissionQRScannerDelegate {

	// MARK: - Mock callbacks.

	var onQRScannerDidScan: ((QRScannerViewController, String) -> Void)?
	var onQRScannerError: ((QRScannerViewController, QRScannerError) -> Void)?

	// MARK: - ExposureSubmissionQRScannerDelegate methods.

	func qrScanner(_ viewController: QRScannerViewController, didScan code: String) {
		onQRScannerDidScan?(viewController, code)
	}

	func qrScanner(_ viewController: QRScannerViewController, error: QRScannerError) {
		onQRScannerError?(viewController, error)
	}
}

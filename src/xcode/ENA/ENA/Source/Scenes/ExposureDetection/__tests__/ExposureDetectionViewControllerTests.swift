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
import XCTest
@testable import ENA

class ExposureDetectionViewControllerTests: XCTestCase {

	// MARK: - Setup.

	func createVC(with state: ExposureDetectionViewController.State) -> ExposureDetectionViewController? {
		let vc = AppStoryboard.exposureDetection.initiateInitial { coder -> UIViewController? in
			ExposureDetectionViewController(coder: coder, state: state, delegate: MockExposureDetectionViewControllerDelegate())
		}

		guard let exposureDetectionVC = vc as? ExposureDetectionViewController else {
			XCTFail("Could not load ExposureDetectionViewController.")
			return nil
		}

		return exposureDetectionVC
	}

	// MARK: - Exposure detection model.

	func testHighRiskState() {
		let state = ExposureDetectionViewController.State(
			exposureManagerState: .init(authorized: true, enabled: true, status: .active),
			detectionMode: .automatic,
			isLoading: false,
			risk: .init(level: .increased,
						details: .init(
							daysSinceLastExposure: 1,
							numberOfExposures: 2,
							activeTracing: .init(interval: 14 * 86400),
							exposureDetectionDate: nil
						),
						riskLevelHasChanged: false),
						previousRiskLevel: nil
		)

		guard let vc = createVC(with: state) else { return }
		_ = vc.view
		XCTAssertNotNil(vc.tableView)
	}
}

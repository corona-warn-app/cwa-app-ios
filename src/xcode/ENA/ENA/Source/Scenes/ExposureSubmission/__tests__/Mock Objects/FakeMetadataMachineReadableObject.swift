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

import AVFoundation
import Foundation
@testable import ENA

class FakeMetadataMachineReadableCodeObject: NSObject, MetadataMachineReadableCodeObject {

	init(
		stringValue: String? = nil,
		time: CMTime = CMTime(),
		duration: CMTime = CMTime(),
		bounds: CGRect = .zero,
		type: AVMetadataObject.ObjectType = .qr
	) {
		self.stringValue = stringValue
		self.time = time
		self.duration = duration
		self.bounds = bounds
		self.type = type
	}

	var stringValue: String?

	var time: CMTime
	var duration: CMTime
	var bounds: CGRect
	var type: AVMetadataObject.ObjectType

}

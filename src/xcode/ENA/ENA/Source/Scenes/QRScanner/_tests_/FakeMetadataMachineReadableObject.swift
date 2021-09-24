//
// 🦠 Corona-Warn-App
//

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

import AVFoundation
import Foundation

protocol MetadataObject: NSObjectProtocol {
	var time: CMTime { get }
	var duration: CMTime { get }
	var bounds: CGRect { get }
	var type: AVMetadataObject.ObjectType { get }

}

protocol MetadataMachineReadableCodeObject: MetadataObject {

	var stringValue: String? { get }

}

extension AVMetadataObject: MetadataObject {}
extension AVMetadataMachineReadableCodeObject: MetadataMachineReadableCodeObject {}

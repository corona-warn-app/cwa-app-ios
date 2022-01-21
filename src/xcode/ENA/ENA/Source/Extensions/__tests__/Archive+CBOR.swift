//
// 🦠 Corona-Warn-App
//

import Foundation
import ZIPFoundation

extension Archive {
	
	public static func createArchiveData(accessMode: AccessMode, cborData: Data) throws -> Data {
		guard let archive = Archive(accessMode: accessMode) else {
			throw ArchivingError.creationError
		}
		
		try archive.addEntry(
			with: "export.bin",
			type: .file,
			uncompressedSize: UInt32(cborData.count),
			bufferSize: 4,
			provider: { position, size -> Data in
				return cborData.subdata(in: position..<position + size)
			}
		)
		
		try archive.addEntry(
			with: "export.sig",
			type: .file,
			uncompressedSize: 12,
			bufferSize: 4,
			provider: { position, size -> Data in
				return Data().subdata(in: position..<position + size)
			}
		)
		
		guard let archiveData = archive.data else {
			throw ArchivingError.creationError
		}
		
		return archiveData
	}
	
}

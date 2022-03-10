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
			uncompressedSize: Int64(cborData.count),
			bufferSize: 4,
			provider: { position, size in
				return cborData.subdata(in: Int(position)..<Int(position) + size)
			}
		)
		
		try archive.addEntry(
			with: "export.sig",
			type: .file,
			uncompressedSize: Int64(12),
			bufferSize: 4,
			provider: { position, size in
				return Data().subdata(in: Int(position)..<Int(position) + size)
			}
		)
		
		guard let archiveData = archive.data else {
			throw ArchivingError.creationError
		}
		
		return archiveData
	}
	
}

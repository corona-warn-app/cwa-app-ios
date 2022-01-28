//
// 🦠 Corona-Warn-App
//

import jsonfunctions
import AnyCodable

public struct CCLConfiguration: Codable {
	
	// MARK: - Protocol Decodable
	
	enum CodingKeys: String, CodingKey {
		case identifier = "Identifier"
		case type = "Type"
		case country = "Country"
		case version = "Version"
		case schemaVersion = "SchemaVersion"
		case engine = "Engine"
		case engineVersion = "EngineVersion"
		case validFrom = "ValidFrom"
		case validTo = "ValidTo"
		case logic = "Logic"
	}
	
	// MARK: - Public

    public struct Logic: Codable {
		enum CodingKeys: String, CodingKey {
			case jfnDescriptors = "JfnDescriptors"
		}
		
		let jfnDescriptors: [CCLFunctionDescriptor]
	}
	
    public let identifier: String
    public let type: String
    public let country: String
    public let version: String
    public let schemaVersion: String
    public let engine: String
    public let engineVersion: String
    public let validFrom: String
    public let validTo: String
    public let logic: Logic
}

public struct CCLFunctionDescriptor: Codable {
    let name: String
    let definition: JsonFunctionDefinition
}

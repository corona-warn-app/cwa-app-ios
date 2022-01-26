//
// 🦠 Corona-Warn-App
//

import jsonfunctions

struct CCLConfiguration: Decodable {
	
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
	
	struct Logic: Decodable {
		enum CodingKeys: String, CodingKey {
			case jfnDescriptors = "JfnDescriptors"
		}
		
		let jfnDescriptors: [JsonFunctionDefinition]
	}
	
	let identifier: String
	let type: String
	let country: String
	let version: String
	let schemaVersion: String
	let engine: String
	let engineVersion: String
	let validFrom: String
	let validTo: String
	let logic: Logic
}

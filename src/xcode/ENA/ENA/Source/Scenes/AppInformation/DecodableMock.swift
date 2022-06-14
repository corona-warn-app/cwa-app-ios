//
// 🦠 Corona-Warn-App
//

import Foundation

struct DecodableMock: Decodable {
   var someString: String

  init(someString: String) {
	  self.someString = someString
   }

   enum CodingKeys: String, CodingKey {
	 case someString
   }
	
	static let dataMock: Data = """
		{
			"someString": "Test"
		}
	""".data(using: .utf8) ?? Data()
}

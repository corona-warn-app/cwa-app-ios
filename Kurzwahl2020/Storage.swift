//
//  Storage.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 30.10.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//

//
//  Storage.swift
//  QGrid
//
//  Created by Karol Kulesza on 7/06/19.
//  Copyright © 2019 Q Mobile { http://Q-Mobile.IT }
//
import SwiftUI

var globalNumberOfRows: Int = appdefaults.rows.small
var globalScreenHeight: CGFloat = 0

// display 6 rows at least, even on the small iPhone 5/SE
struct appdefaults {
    struct rows {
    static let small = 5
    static let large = 6
    }
    static var fontsize : CGFloat = 24
    static let font : String = "PingFang TC Medium"
    struct colorScheme{
        struct dark{
            static let opacity : Double = 0.8
            static let cornerRadius : CGFloat = 5
            static let hspacing : CGFloat = 3
            static let vspacing : CGFloat = 1
        }
        struct light{
            static let opacity : Double = 1.0
            static let cornerRadius : CGFloat = 0
            static let hspacing : CGFloat = 3
            static let vspacing : CGFloat = 1
        }
    }
}


final class KurzwahlStore : ObservableObject {

}




struct Person : Codable, Identifiable {
  var id: Int
  var firstName: String
  var lastName: String
  var imageName: String
}

struct TileColor : Codable, Identifiable {
    var id: Int
    var red: String   
    var green: String
    var blue: String
    var alpha: String
    var name: String
}

struct Storage {
  static var people: [Person] = load("people.json")
//  static var colors: [TileColor] = load("Colors.json")
  
  static func load<T: Decodable>(_ file: String) -> T {
    guard let url = Bundle.main.url(forResource: file, withExtension: nil),
          let data = try? Data(contentsOf: url),
          let typedData = try? JSONDecoder().decode(T.self, from: data) else {
      fatalError("Error while loading data from file: \(file)")
    }
    return typedData;
  }
}

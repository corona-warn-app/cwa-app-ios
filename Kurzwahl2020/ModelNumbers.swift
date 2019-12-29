//
//  ModelNumbers.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 29.12.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

enum tileError : Error {
    case badIndex
}


struct tile {
  var id: Int
  var name: String
  var phoneNumber: String
}

struct tileSet : Hashable {
  var id: Int
  var name: String
  var phoneNumber: String
}
    
    
class phoneBook: ObservableObject{
    @Published var tiles: [tile] = []
    
    init(withTile: tile) {
        tiles.append(withTile)
    }
    
    
    func getTile(withId: Int) throws ->tile  {
        if withId <= tiles.count {
            return tiles[withId]
        }
        else {
            throw tileError.badIndex
        }
    }
    
    
    func addTile(withTile: tile) {
        self.tiles.append(withTile)
    }

    
    func modifyTile(withTile: tile) {
        if withTile.id >= 0 {
            tiles[withTile.id] = withTile
        }
    }
    

}


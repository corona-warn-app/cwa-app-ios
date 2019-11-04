//
//  ContentView.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 25.10.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let hsize: CGFloat = 180
    let vsize: CGFloat = 80
    let border: CGFloat = 1
    let fontsize: CGFloat = 26
    
    // draw one tile
    fileprivate func tile(_ name: String, withTileNumber: Int) -> some View {
        return Text(name)
            .font(.system(size: 26))
            .foregroundColor(Color.white)
            .frame(width: hsize, height: vsize, alignment: .center)
            .background(Color.appColor(withTileNumber))
            .cornerRadius(5)
    }
    
    // draw a HStack with two tiles
    fileprivate func hstackTiles(_ lineNumber: Int) -> some View {
        return HStack(spacing: 10) {
            tile("John Appleseed", withTileNumber: lineNumber * 2 )
            tile("Andreas Vogel", withTileNumber: lineNumber * 2 + 1)
        } .padding(.bottom, 10)
    }
    
    
    
    var body: some View {
        VStack(spacing: 0) {
            hstackTiles(0)
            hstackTiles(1)
            hstackTiles(2)
            hstackTiles(3)
            hstackTiles(4)
            hstackTiles(5)
        } //.scaledToFill() .offset(x:0,y:0)
        
    }
}

// https://iosexample.com/the-missing-swiftui-collection-view/

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

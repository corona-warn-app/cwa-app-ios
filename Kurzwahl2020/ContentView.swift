//
//  ContentView.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 25.10.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//
// Cell Geometry     :width , height        View Height
// Phone SE          : 158  , 89,33         548
// iPhone 8          : 185.5, 105.833       647
// iPhone 11         : 205  , 134.333       818
// iPhone 11 Pro     : 185.5, 120.333       734
// iPhone 11 Pro max : 205  , 134.333       818        


import SwiftUI


// the SceneDelegate defines which view is used.
struct ContentView: View {
    @State private var selection = 0
    let border: CGFloat = 1
    let fontsize: CGFloat = 26
    
    
    // draw one tile
    fileprivate func tile(_ name: String, withTileNumber: Int, _ height: CGFloat, _ width: CGFloat) -> some View {
        return Text(name)
            .font(.system(size: 26))
            .foregroundColor(Color.white)
            .frame(width: width, height: height, alignment: .center)
            .background(Color.appColor(withTileNumber))
            .cornerRadius(5)
    }
    
    
    // draw a HStack with two tiles
    fileprivate func hstackTiles(_ lineNumber: Int, _ geometry: GeometryProxy) -> some View {
        let hsize = geometry.size.width / 2 - 2
        let vsize = geometry.size.height / CGFloat(globalNumberOfRows) - 2
        return HStack(spacing: 2) {
            tile("John Appleseed", withTileNumber: lineNumber * 2, vsize, hsize)
            tile("Andreas Vogel", withTileNumber: lineNumber * 2 + 1, vsize, hsize)
        } .padding(.bottom, 2)
    }
    
    
    //draw a VStack. Number of rows = globalNumberOfRows
    var body: some View {
        
        TabView(selection: $selection) {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ForEach((0...(globalNumberOfRows-1)), id: \.self) {
                        self.hstackTiles($0, geometry)
                    }
                } //.scaledToFill() .offset(x:0,y:0)
            }
            .tabItem {
                VStack {
                    Image(systemName: "1.square.fill")
                }
            } .tag(0)
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ForEach((globalNumberOfRows...(2*globalNumberOfRows-1)), id: \.self) {
                        self.hstackTiles($0, geometry)
                    }
                } //.scaledToFill() .offset(x:0,y:0)
            }
            .tabItem {
                VStack {
                    Image(systemName: "2.square.fill")
                }
            }.tag(1)
        }
    }
}

// https://iosexample.com/the-missing-swiftui-collection-view/

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


//
//  ContentView.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 25.10.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//
// Cell Geometry     :width , height        View Height   # rows
// Phone SE          : 158  , 89,33         548           n rows
// iPhone 8          : 185.5, 105.833       647           n rows
// iPhone 11         : 205  , 134.333       818           n+1 rows
// iPhone 11 Pro     : 185.5, 120.333       734           n+1 rows
// iPhone 11 Pro max : 205  , 134.333       818           n+1 rows


import SwiftUI

    
/*
 Task: implement the tap gesture to start a phone call
*/
 
/*
 implement a launch screen:
 https://medium.com/flawless-app-stories/change-splash-screen-in-ios-app-for-dummies-the-better-way-e385327219e
 */
 

// the SceneDelegate defines which view is used.
struct ContentView: View {
    @State private var selection = 0
    @GestureState var isLongPressed = false
    @ObservedObject var model : kurzwahlModel
    
    //detect the dark mode
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    
    fileprivate func hspacing()->CGFloat {
        return (colorScheme == .light ? appdefaults.colorScheme.light.hspacing : appdefaults.colorScheme.dark.hspacing)
    }

    
    fileprivate func vspacing()->CGFloat {
        return (colorScheme == .light ? appdefaults.colorScheme.light.vspacing : appdefaults.colorScheme.dark.vspacing)
    }

    
    //calculate the dimensions of the tile (aspect ratio 1.61)
    fileprivate func dimensions(_ geometry: GeometryProxy)->(CGFloat, CGFloat) {
        let geo = geometry.size.height
        let vMaxSize = geo / CGFloat(globalNumberOfRows) - vspacing() * CGFloat(globalNumberOfRows) + 1
        var hsize = geometry.size.width / 2 - hspacing()
        var vsize = hsize / 1.61
        if (vsize > vMaxSize ) {
            vsize = vMaxSize
            hsize = vsize * 1.61
        }
        return(vsize, hsize)
    }
    

       fileprivate func textLabel(withTileNumber: Int, height: CGFloat, width: CGFloat) -> some View {
        return Text("\(model.getName(withId: withTileNumber))").multilineTextAlignment(.center)
            .font(Font.custom(model.font, size: model.fontSize))
            
            .foregroundColor(Color.white)
            .frame(width: width, height: height, alignment: .center)
            .padding(.horizontal)
            .opacity(colorScheme == .light ? appdefaults.colorScheme.light.opacity : appdefaults.colorScheme.dark.opacity)
        //            .onTapGesture {  //see developer documentation
        //                <#code#>
        //        }
    }
    
    
// draw one tile
    fileprivate func tile(withTileNumber: Int, _ height: CGFloat, _ width: CGFloat) -> some View {
        return self.textLabel(withTileNumber: withTileNumber, height: height, width: width)
            .frame(width: width, height: height)
            .background(Color.appColor(withTileNumber))
            .cornerRadius(colorScheme == .light ? appdefaults.colorScheme.light.cornerRadius : appdefaults.colorScheme.dark.cornerRadius)
    }
    
    
// draw a HStack with two tiles
    fileprivate func hstackTiles(_ lineNumber: Int, _ geometry: GeometryProxy) -> some View {
        return HStack(spacing: self.hspacing()) {
            tile(withTileNumber: lineNumber * 2, self.dimensions(geometry).0, self.dimensions(geometry).1)
            tile(withTileNumber: lineNumber * 2 + 1, self.dimensions(geometry).0, self.dimensions(geometry).1)
        } .padding(.bottom, 2)
    }
    
    
//draw a VStack. Number of rows = globalNumberOfRows
    var body: some View {
// 1st screen
        TabView(selection: $selection) {
            GeometryReader { geometry in
                VStack(spacing: self.vspacing()) {
                    
                    ForEach((0...(globalNumberOfRows-1)), id: \.self) {
                        self.hstackTiles($0, geometry)
                    }
                }
            }
            .tabItem {
                Image(systemName: selection == 0 ? "1.square.fill" : "1.square")
            }.tag(0)
// 2nd screen
            GeometryReader { geometry in
                VStack(spacing: self.vspacing()) {
                    ForEach((globalNumberOfRows...(2*globalNumberOfRows-1)), id: \.self) {
                        self.hstackTiles($0, geometry)
                    }
                }
            }
            .tabItem {
                Image(systemName: selection == 1 ? "2.square.fill" : "2.square")
            }.tag(1)

// settings view
            SettingsView(model: globalDataModel)
            .tabItem {
                Image(systemName: selection == 2 ? "3.square.fill" : "3.square")
            }.tag(3)

        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: globalDataModel)
    }
}


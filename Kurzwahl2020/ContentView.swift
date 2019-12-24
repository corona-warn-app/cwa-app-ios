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


// the SceneDelegate defines which view is used.
struct ContentView: View {
    @State private var selection = 0
    @GestureState var isLongPressed = false
    let border: CGFloat = 1
    let fontsize = appdefaults.fontsize
    
    
// draw one tile
    fileprivate func tile(_ name: String, withTileNumber: Int, _ height: CGFloat, _ width: CGFloat) -> some View {
        return Text(name)
            .font(.system(size: fontsize))
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
                Image(systemName: selection == 0 ? "1.square.fill" : "1.square")

            }.tag(0)
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ForEach((globalNumberOfRows...(2*globalNumberOfRows-1)), id: \.self) {
                        self.hstackTiles($0, geometry)
                    }
                } //.scaledToFill() .offset(x:0,y:0)
            }
            .tabItem {
                Image(systemName: selection == 1 ? "2.square.fill" : "2.square")
            }.tag(1)
// settings view
            VStack {
                Text("Font Size: \(appdefaults.fontsize)")
                NavigationView {
                    NavigationLink(destination: SettingsView()) {
                        Text("Show Detail View")
                    }.navigationBarTitle("")
                }
            }
            .tabItem {
                Image(systemName: selection == 2 ? "3.square.fill" : "3.square")
            }.tag(2)
// settings view
            SettingsView()
            .tabItem {
                Image(systemName: selection == 3 ? "4.square.fill" : "4.square")
            }.tag(3)

        }
    }
}

// https://iosexample.com/the-missing-swiftui-collection-view/

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




// from https://swiftwithmajid.com/2019/07/10/gestures-in-swiftui/
struct DragGestureExample : View {
    @State private var offset: CGSize = .zero

    var body: some View {
        let drag = DragGesture()
            .onChanged { self.offset = $0.translation }
            .onEnded {
                if $0.translation.width < -100 {
                    self.offset = .init(width: -1000, height: 0)
                } else if $0.translation.width > 100 {
                    self.offset = .init(width: 1000, height: 0)
                } else {
                    self.offset = .zero
                }
        }

        return PersonView()
            .background(Color.red)
            .cornerRadius(8)
            .shadow(radius: 8)
            .padding()
            .offset(x: offset.width, y: offset.height)
            .gesture(drag)
            .animation(.interactiveSpring())
    }
}

struct PersonView: View {
    var body: some View {
        VStack( spacing: 0) {
            Rectangle()
                .fill(Color.gray)
                .cornerRadius(8)
                .frame(height: 300)

            Text("Majid Jabrayilov")
                .font(.title)
                .foregroundColor(.white)

            Text("iOS Developer")
                .font(.body)
                .foregroundColor(.white)
        }.padding()
    }
}

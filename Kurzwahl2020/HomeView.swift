//
//  HomeView.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 06.01.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//
// Cell Geometry     :width , height        View Height   # rows
// Phone SE          : 158  , 89,33         548           n rows
// iPhone 8          : 185.5, 105.833       647           n rows
// iPhone 11         : 205  , 134.333       818           n+1 rows
// iPhone 11 Pro     : 185.5, 120.333       734           n+1 rows
// iPhone 11 Pro max : 205  , 134.333       818           n+1 rows
//
// NavigationStack:
// http://codingpills.ioneanu.com/swiftui-custom-navigation/

// Mastering buttons:
// https://swiftwithmajid.com/2020/02/19/mastering-buttons-in-swiftui/

import SwiftUI
import Combine



final class HomeViewState: ObservableObject {
    // store the current tab of HomeView
    @Published var selectedTab: Int = 0
}



struct ContentView2: View {
    var body: some View {
        NavigationHost()
            .environmentObject(NavigationStack( NavigationItem( view: AnyView(HomeView()))))
    }
}


struct HomeView: View {
    @EnvironmentObject var navigation: NavigationStack

    @EnvironmentObject var appState : HomeViewState
    @EnvironmentObject var editViewState : EditViewState
    @GestureState var isLongPressed = false
  
    //detect the dark mode
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    fileprivate func hspacing()->CGFloat {
        return (colorScheme == .light ? appdefaults.colorScheme.light.hspacing : appdefaults.colorScheme.dark.hspacing)
    }

    
    fileprivate func vspacing()->CGFloat {
        return (colorScheme == .light ? appdefaults.colorScheme.light.vspacing : appdefaults.colorScheme.dark.vspacing)
    }
    
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            GeometryReader { geometry in
                VStack(spacing: self.vspacing()) {
                            
                    ForEach((0...(globalNumberOfRows-1)), id: \.self) {
                        self.hstackTiles($0, geometry)
                    }//.background(SwiftUI.Color(red: 0.1, green: 0.1, blue: 0.1))
                }
            }//.background(SwiftUI.Color(red: 0.1, green: 0.1, blue: 0.1))
            .tabItem {
                Image(systemName: appState.selectedTab == 0 ? "1.square.fill" : "1.square")
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
                Image(systemName: appState.selectedTab == 1 ? "2.square.fill" : "2.square")
            }.tag(1)

            // 3nd screen
                GeometryReader { geometry in
                    VStack(spacing: self.vspacing()) {
                        ForEach((2*globalNumberOfRows...(3*globalNumberOfRows-1)), id: \.self) {
                            self.hstackTiles($0, geometry)
                        }
                    }
                }
                .tabItem {
                    Image(systemName: appState.selectedTab == 2 ? "3.square.fill" : "3.square")
                }.tag(2)
            
//        // 4nd screen
            GeometryReader { geometry in
                VStack(spacing: self.vspacing()) {
                    ForEach((3*globalNumberOfRows...(4*globalNumberOfRows-1)), id: \.self) {
                        self.hstackTiles($0, geometry)
                    }
                }
            }
            .tabItem {
                Image(systemName: appState.selectedTab == 3 ? "4.square.fill" : "4.square")
            }.tag(3)


        // settings view
            SettingsView(model: globalDataModel).onDisappear{globalDataModel.persistSettings()}
            .tabItem {
                Image(systemName: appState.selectedTab == 4 ? "gear" : "gear")
                Text("Settings")
            }.tag(4)
        }//.background(SwiftUI.Color(red: 0.2, green: 0.2, blue: 0.2).edgesIgnoringSafeArea(.all))
    }


    
    // draw a HStack with two tiles
    fileprivate func hstackTiles(_ lineNumber: Int, _ geometry: GeometryProxy) -> some View {
        return HStack(spacing: self.hspacing()) {
            tile(withTileNumber: lineNumber * 2, self.dimensions(geometry).0, self.dimensions(geometry).1)
            tile(withTileNumber: lineNumber * 2 + 1, self.dimensions(geometry).0, self.dimensions(geometry).1)
        } .padding(.bottom, 2)
    }
    
    
    
    fileprivate func switchToEditTile(_ withTileNumber: Int) {
        self.editViewState.userSelectedName = globalDataModel.getName(withId: withTileNumber)
        self.editViewState.userSelectedNumber = globalDataModel.getNumber(withId: withTileNumber)
        self.navigation.advance(NavigationItem(
            view: AnyView(
                editTile(tileId: withTileNumber))))
    }
    
    
    
    func clearTile(_ withTileNumber: Int) {
        editViewState.userSelectedName = ""
        editViewState.userSelectedNumber = ""
        editViewState.imageDataAvailable = false
        editViewState.label = ""
        editViewState.thumbnailImageData = Data()
        globalDataModel.modifyTile(withTile: phoneTile.init(id: withTileNumber,
                                                            name: self.editViewState.userSelectedName,
                                                            phoneNumber: self.editViewState.userSelectedNumber,
                                                            backgroundColor: globalDataModel.getColorName(withId: withTileNumber)))
    }

    
    
    // draw one tile
    fileprivate func tile(withTileNumber: Int, _ height: CGFloat, _ width: CGFloat) -> some View {
        return self.textLabel(withTileNumber: withTileNumber, height: height, width: width)
            .frame(width: width, height: height)
            .background(Color(globalDataModel.getUIColor(withId: withTileNumber)))
            .opacity(colorScheme == .light ? appdefaults.colorScheme.light.opacity : appdefaults.colorScheme.dark.opacity)
            .cornerRadius(colorScheme == .light ? appdefaults.colorScheme.light.cornerRadius : appdefaults.colorScheme.dark.cornerRadius)

            .onTapGesture(count: 2) {
                self.switchToEditTile(withTileNumber)
            }
            //        .onLongPressGesture {
            //            self.switchToEditTile(withTileNumber)
            //        }
            .onTapGesture(count: 1) { self.makeCall(withTileNumber)
            }
        .contextMenu {
            Button(action: {
                self.switchToEditTile(withTileNumber)
            }) {
                Text("Edit")
                Image(systemName: "pencil")
            }
            Button(action: {
                self.clearTile(withTileNumber)
            }) {
                Text("Clear")
                Image(systemName: "trash")
            }
                        Button(action: {
                self.makeCall(withTileNumber)
            }) {
                Text("Call number")
                Image(systemName: "phone.circle")
            }
        }
        
    }
    
    
    
    //calculate the dimensions of the tile (aspect ratio 1.61)
    fileprivate func dimensions(_ geometry: GeometryProxy)->(CGFloat, CGFloat) {
        let geo = geometry.size.height
        let vMaxSize = geo / CGFloat(globalNumberOfRows) - vspacing() * CGFloat(globalNumberOfRows) + 1
        var hsize = geometry.size.width / 2 - hspacing()
        
        var vsize : CGFloat = 0
        if DeviceType.IS_IPHONE_SE == false {
            vsize = hsize / appdefaults.tilesize.aspectRatioStandard
        } else {
            vsize = hsize / appdefaults.tilesize.aspectRatioIPhoneSE
        }
        
        if (vsize > vMaxSize ) {
            vsize = vMaxSize
            if DeviceType.IS_IPHONE_SE == false {
                hsize = vsize * appdefaults.tilesize.aspectRatioStandard
            } else {
                hsize = vsize * appdefaults.tilesize.aspectRatioIPhoneSE
            }
        }
        return(vsize, hsize)
    }
    
    

    fileprivate func textLabel(withTileNumber: Int, height: CGFloat, width: CGFloat) -> some View {
        return Text("\(globalDataModel.getName(withId: withTileNumber))").multilineTextAlignment(.center)
            .font(Font.custom(globalDataModel.font, size: globalDataModel.fontSize))
            .foregroundColor(Color.white)
            .frame(width: width, height: height, alignment: .center)
            .padding(.horizontal)
        }
        
    
    
    func makeCall(_ withTileNumber: Int) {
        let scheme : String = "tel://"
        var phoneNumber = globalDataModel.getNumber(withId: withTileNumber).trimmingCharacters(in: .whitespacesAndNewlines)
        phoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
        phoneNumber = phoneNumber.replacingOccurrences(of: "/", with: "")
        //phoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if phoneNumber.count > 0 {
            if phoneNumber[phoneNumber.startIndex] == "+" {
                phoneNumber = phoneNumber.digits
                phoneNumber.insert("+", at: phoneNumber.startIndex)
            } else {
                phoneNumber = phoneNumber.digits
            }
            
            
            let url = URL(string: scheme + phoneNumber)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
    
}  //HomeView


extension String {
    private static var digits = UnicodeScalar("0")..."9"
    var digits: String {
        return String(unicodeScalars.filter(String.digits.contains))
    }
}

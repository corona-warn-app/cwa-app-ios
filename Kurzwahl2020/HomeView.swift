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
    @EnvironmentObject var colorManager : ColorManagement
    @GestureState var isLongPressed = false
    
    //detect the dark mode
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            GeometryReader { geometry in
                VStack(spacing: self.vspacing()) {
                    ForEach((0...(globalNumberOfRows-1)), id: \.self) {
                            self.hstack_with_two_tiles($0, geometry)
                    }
                }
            }
            .tabItem {
                Image(systemName: appState.selectedTab == 0 ? "1.square.fill" : "1.square")
            }.tag(0)
            
            // 2nd screen
            GeometryReader { geometry in
                VStack(spacing: self.vspacing()) {
                    ForEach((globalNumberOfRows...(2*globalNumberOfRows-1)), id: \.self) {
                        self.hstack_with_two_tiles($0, geometry)
                    }
                }
            }
            .tabItem {
                Image(systemName: appState.selectedTab == 1 ? "2.square.fill" : "2.square")
            }.tag(1)
            
            #if CBC36
            // 3nd screen
            GeometryReader { geometry in
                VStack(spacing: self.vspacing()) {
                    ForEach((2*globalNumberOfRows...(3*globalNumberOfRows-1)), id: \.self) {
                        self.hstack_with_two_tiles($0, geometry)
                    }
                }
            }
            .tabItem {
                Image(systemName: appState.selectedTab == 2 ? "3.square.fill" : "3.square")
            }.tag(2)
            #endif
            
            // 4nd screen
            //            GeometryReader { geometry in
            //                VStack(spacing: self.vspacing()) {
            //                    ForEach((3*globalNumberOfRows...(4*globalNumberOfRows-1)), id: \.self) {
            //                        self.hstackTiles($0, geometry)
            //                    }
            //                }
            //            }
            //            .tabItem {
            //                Image(systemName: appState.selectedTab == 3 ? "4.square.fill" : "4.square")
            //            }.tag(3)
            
            // settings view
            SettingsView(model: globalDataModel).onDisappear{globalDataModel.persistSettings()}
                .tabItem {
                    Image(systemName: appState.selectedTab == 4 ? "gear" : "gear")
                    Text(AppStrings.home.settings)
                }.tag(4)
        }
    }
    
    // MARK: - Private
    
    private func makeCall(_ withTileNumber: Int) {
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
    
    private func hspacing()->CGFloat {
        return (colorScheme == .light ? appdefaults.colorScheme.light.hspacing : appdefaults.colorScheme.dark.hspacing)
    }
    
    private func vspacing()->CGFloat {
        return (colorScheme == .light ? appdefaults.colorScheme.light.vspacing : appdefaults.colorScheme.dark.vspacing)
    }
    
    // draw a HStack with two tiles
    private  func hstack_with_two_tiles(_ lineNumber: Int, _ geometry: GeometryProxy) -> some View {
        if globalDataModel.tileGeometry.height == 0 {
            globalDataModel.tileGeometry.height = self.dimensions(geometry).0
        }
        
        if globalDataModel.tileGeometry.width == 0 {
            globalDataModel.tileGeometry.width = self.dimensions(geometry).1
        }
        
        let leading_padding = ( geometry.size.width - hspacing() - 2 * globalDataModel.tileGeometry.width ) / 2

        return HStack(alignment: .center, spacing: self.hspacing()) {
            tile(withTileNumber: lineNumber * 2, globalDataModel.tileGeometry.height, globalDataModel.tileGeometry.width)
            tile(withTileNumber: lineNumber * 2 + 1, globalDataModel.tileGeometry.height, globalDataModel.tileGeometry.width)
        } .padding(.bottom, 2).padding(.leading, leading_padding)
    }
    
    // draw one tile
    private func tile(withTileNumber: Int, _ height: CGFloat, _ width: CGFloat) -> some View {
        return self.textLabel(withTileNumber: withTileNumber, height: height, width: width)
            .frame(width: width, height: height)
            //            .background(Color(globalDataModel.getUIColor(withId: withTileNumber)))
            .background(Color(colorManager.getUIColor(withId: withTileNumber)))
            .opacity(colorScheme == .light ? appdefaults.colorScheme.light.opacity : appdefaults.colorScheme.dark.opacity)
            .cornerRadius(colorScheme == .light ? appdefaults.colorScheme.light.cornerRadius : appdefaults.colorScheme.dark.cornerRadius)
            
            .onTapGesture(count: 2) {
                self.switchToEditTile(withTileNumber)
            }
            .onTapGesture(count: 1) { self.makeCall(withTileNumber)
            }
            .contextMenu {
                Button(action: {
                    self.switchToEditTile(withTileNumber)
                }) {
                    Text(AppStrings.home.edit)
                    Image(systemName: "pencil")
                }
                Button(action: {
                    self.clearTile(withTileNumber)
                }) {
                    Text(AppStrings.home.clear)
                    Image(systemName: "trash")
                }
                Button(action: {
                    self.makeCall(withTileNumber)
                }) {
                    Text(AppStrings.home.callNumber)
                    Image(systemName: "phone.circle")
                }
            }
    }
    
    //calculate the dimensions of the tile (aspect ratio 1.61)
    private func dimensions(_ geometry: GeometryProxy)->(CGFloat, CGFloat) {
        let vMaxSize = geometry.size.height / CGFloat(globalNumberOfRows) - vspacing() * CGFloat(globalNumberOfRows) + 1
        var hsize = geometry.size.width / 2 - hspacing()
        
        var vsize : CGFloat = 0
        if DeviceType.IS_IPHONE_SE == false && DeviceType.IS_IPHONE_7 == false {
            vsize = hsize / appdefaults.tilesize.aspectRatioStandard
        } else {
            vsize = hsize / appdefaults.tilesize.aspectRatioIPhoneSE
        }
        
        if (vsize > vMaxSize ) {
            vsize = vMaxSize
            if DeviceType.IS_IPHONE_SE == false && DeviceType.IS_IPHONE_7 == false {
                hsize = vsize * appdefaults.tilesize.aspectRatioStandard
            } else {
                hsize = vsize * appdefaults.tilesize.aspectRatioIPhoneSE
            }
        }
        return(vsize, hsize)
    }
    
    private func textLabel(withTileNumber: Int, height: CGFloat, width: CGFloat) -> some View {
        return Text("\(globalDataModel.getName(withId: withTileNumber))").multilineTextAlignment(.center)
            //        return Text("Veronica iPhone").multilineTextAlignment(.center)
            .font(Font.custom(globalDataModel.font, size: globalDataModel.fontSize))
            .foregroundColor(Color.white)
            .frame(width: width, height: height, alignment: .center)
            .padding(.horizontal)
    }
    
    private func switchToEditTile(_ withTileNumber: Int) {
        self.editViewState.userSelectedName = globalDataModel.getName(withId: withTileNumber)
        self.editViewState.userSelectedNumber = globalDataModel.getNumber(withId: withTileNumber)
        self.navigation.advance(NavigationItem(
                                    view: AnyView(
                                        editView(tileId: withTileNumber))))
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
        globalDataModel.persist()
    }
    
}  //HomeView


extension String {
    private static var digits = UnicodeScalar("0")..."9"
    var digits: String {
        return String(unicodeScalars.filter(String.digits.contains))
    }
}

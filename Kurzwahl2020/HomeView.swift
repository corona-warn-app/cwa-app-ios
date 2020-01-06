//
//  HomeView.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 06.01.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import SwiftUI


struct ContentView2: View {
    var body: some View {
        NavigationHost()
            .environmentObject(NavigationStack( NavigationItem( view: AnyView(HomeView(model: kurzwahlModel())))))
    }
}


struct HomeView: View {
    @EnvironmentObject var navigation: NavigationStack
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
    
    var body: some View {
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
            }.tag(0).onTapGesture(count: 2) {
                self.navigation.advance(NavigationItem(view: AnyView(editTile(model: kurzwahlModel()))))
            }
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
            SettingsView(model: globalDataModel).onDisappear{self.model.persistSettings()}
            .tabItem {
                Image(systemName: selection == 2 ? "3.square.fill" : "3.square")
            }.tag(3)
        }
    }


    
    // draw a HStack with two tiles
    fileprivate func hstackTiles(_ lineNumber: Int, _ geometry: GeometryProxy) -> some View {
        return HStack(spacing: self.hspacing()) {
            tile(withTileNumber: lineNumber * 2, self.dimensions(geometry).0, self.dimensions(geometry).1)
            tile(withTileNumber: lineNumber * 2 + 1, self.dimensions(geometry).0, self.dimensions(geometry).1)
        } .padding(.bottom, 2)
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
        }
        
        
    // draw one tile
    fileprivate func tile(withTileNumber: Int, _ height: CGFloat, _ width: CGFloat) -> some View {
        return self.textLabel(withTileNumber: withTileNumber, height: height, width: width)
            .frame(width: width, height: height)
            .background(Color.appColor(withTileNumber))
            .cornerRadius(colorScheme == .light ? appdefaults.colorScheme.light.cornerRadius : appdefaults.colorScheme.dark.cornerRadius)
        }
    
}



struct NextView: View {
    @EnvironmentObject var navigation: NavigationStack
  
     var body: some View {
         VStack{
       BackView( title: "Next View",  action:{
           self.navigation.unwind()
              })
       List{
           Text("I am NextView")
       }
   }
    }
}



struct TitleView: View{
    var title: String
    
    var homeAction: ()->Void
    
     var body: some View {
        ZStack{
            Rectangle().fill(Color.gray).frame( height: 40 )
            HStack{
                Spacer()
        Text(title).padding(.leading, 20).font(Font.system(size: 20.0))
                Spacer()
                Button( action: homeAction){
                    Image(uiImage: UIImage(systemName:  "house", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold, scale: .large))! )
                    .padding(.trailing, 20)
                }.foregroundColor(Color.black)
            }
        }
    }
}


struct BackView: View{
    var title: String
    var action: ()->Void
    
    var body: some View {
        ZStack{
            Rectangle().fill(Color.gray).frame( height: 40 )
            HStack{
                Button( action: action){ Text("Cancel").padding(.leading, 20)
                }.foregroundColor(Color.black)
            Spacer()
            }
        }
    }
}

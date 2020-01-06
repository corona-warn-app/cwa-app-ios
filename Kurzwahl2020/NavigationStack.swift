
//
//  NavigationStack.swift
//  Kurzwahl2020
//
//  Created by Andreas Vogel on 06.01.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import SwiftUI

struct NavigationItem{
    var view: AnyView
}


struct NavigationHost: View{
    @EnvironmentObject var navigation: NavigationStack
    var body: some View {
        self.navigation.currentView.view
    }
}


final class NavigationStack: ObservableObject  {
    @Published var viewStack: [NavigationItem] = []
    @Published var currentView: NavigationItem
    init(_ currentView: NavigationItem ){
        self.currentView = currentView
    }
    func unwind(){
        if viewStack.count == 0{
            return
        }
        let last = viewStack.count - 1
        currentView = viewStack[last]
        viewStack.remove(at: last)
    }
    func advance(_ view:NavigationItem){
        viewStack.append( currentView)
        currentView = view
    }
    
    func home( ){
        currentView = NavigationItem( view: AnyView(HomeView()))
        viewStack.removeAll()
    }
}



struct ContentView2: View {
    var body: some View {
        NavigationHost()
            .environmentObject(NavigationStack( NavigationItem( view: AnyView(HomeView()))))
    }
}


struct HomeView: View {
    @EnvironmentObject var navigation: NavigationStack
    @State private var selection = 0
  
    var body: some View {
        TabView(selection: $selection) {
            Text("Click me").onTapGesture(count: 1){
                self.navigation.advance(NavigationItem(view: AnyView(editTile(model: kurzwahlModel()))))
                }
            .tabItem {
                Image(systemName: selection == 0 ? "1.square.fill" : "1.square")
            }.tag(0)

            Text("DoubleTap me").onTapGesture(count: 2){
                self.navigation.advance(NavigationItem(view: AnyView(NextView())))
            }
            .tabItem {
                Image(systemName: selection == 1 ? "2.square.fill" : "2.square")
            }.tag(1)

            Text("Text 3")
                .tabItem {
                    Image(systemName: selection == 2 ? "3.square.fill" : "3.square")
                }.tag(3)
            }
    }
}



struct NextView: View {
    @EnvironmentObject var navigation: NavigationStack
  
     var body: some View {
         VStack{
       BackView( title: "Next View",  action:{
           self.navigation.unwind()
              }, homeAction: {
                 self.navigation.home()
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
    var homeAction: ()->Void
    var body: some View {
        ZStack{
            Rectangle().fill(Color.gray).frame( height: 40 )
            HStack{
                Button( action: action){
          Image(uiImage: UIImage(systemName:  "arrow.turn.down.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large))! )
                    .padding(.leading, 20)
                }.foregroundColor(Color.black)
                
                Spacer()
        Text(title).padding(.leading, 20).font(Font.system(size: 20)).padding(.trailing, 20)
                Spacer()
                Button( action: homeAction){
          Image(uiImage: UIImage(systemName:  "house", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15.0, weight: .bold, scale: .large))! )
                    .padding(.trailing, 20)
                }.foregroundColor(Color.black)
            }
        }
    }
}

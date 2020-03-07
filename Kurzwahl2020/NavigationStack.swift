//
//  NavigationStack.swift
//  Kurzwahl2020
//
//  Created by Andreas Vogel on 06.01.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//
// NavigationStack:
// http://codingpills.ioneanu.com/swiftui-custom-navigation/

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
    func unwind2(){
        if viewStack.count == 0{
            return
        }
        var last = viewStack.count - 1
        currentView = viewStack[last]
        viewStack.remove(at: last)
        if viewStack.count == 0{
            return
        }
        last = viewStack.count - 1
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

//
//  SettingsView.swift
//  Kurzwahl2020
//
//  Created by Andreas Vogel on 12.01.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import SwiftUI
import Combine

struct SettingsView: View {
    @ObservedObject var model : kurzwahlModel
    @EnvironmentObject var navigation: NavigationStack
    
    
    var body: some View {
        NavigationView {
            VStack{
//           TitleView( title: "Settings")
                Form {
                    Section(header: Text("Font Size")) {
                        Stepper(value: $model.fontSize, in: 12...64) {
                            Text("Size: \(model.getFontSizeAsInt())")
                        } //.labelsHidden
                    }.padding(.leading, 2.0)
                    Button(action: {
                        self.navigation.advance(NavigationItem(
                    view: AnyView(AboutView()))) }) {
                        Text("About")
                    }.buttonStyle(PlainButtonStyle())
                }.navigationBarTitle(Text("Settings"))
            }
        }
    }
    
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(model: globalDataModel)
    }
}


// Runtime error
//2020-01-15 15:04:14.455736+0100 Kurzwahl2020[60884:2236203] [TableView] Warning once only: UITableView was told to layout its visible cells and other contents without being in the view hierarchy (the table view or one of its superviews has not been added to a window). This may cause bugs by forcing views inside the table view to load and perform layout without accurate information (e.g. table view bounds, trait collection, layout margins, safe area insets, etc), and will also cause unnecessary performance overhead due to extra layout passes. Make a symbolic breakpoint at UITableViewAlertForLayoutOutsideViewHierarchy to catch this in the debugger and see what caused this to occur, so you can avoid this action altogether if possible, or defer it until the table view has been added to a window. Table view: <_TtC7SwiftUIP33_BFB370BA5F1BADDC9D83021565761A4925UpdateCoalescingTableView: 0x7ff547833800; baseClass = UITableView; frame = (0 0; 414 804); clipsToBounds = YES; autoresize = W+H; gestureRecognizers = <NSArray: 0x600002084a20>; layer = <CALayer: 0x600002e26c00>; contentOffset: {0, 0}; contentSize: {414, 72.5}; adjustedContentInset: {0, 0, 83, 0}; dataSource: (null)>


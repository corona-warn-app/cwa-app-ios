//
//  SelectColorPalette.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 03.03.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import SwiftUI

struct SelectColorPalette: View {
    var screenIndex: Int
    @EnvironmentObject var navigation: NavigationStack
    @EnvironmentObject var colorManager: ColorManagement
    
    var body: some View {
        VStack {
            SingleActionBackView( title: "",
                                  buttonText: AppStrings.color.backButton,
                                  action:{
                                    self.navigation.unwind()
            })
            
            Text(AppStrings.color.selectPalette)
            List {
                ForEach(colorManager.getAllPalettes()) { p in
                    thumbnailRow(colorPalette: p, screenIndex: self.screenIndex)
                }
            }
            Spacer()
        }
    }
}

struct SelectColorPalette_Previews: PreviewProvider {
    static var previews: some View {
        SelectColorPalette(screenIndex: 0)
    }
}



struct thumbnailRow : View {
    @EnvironmentObject var navigation: NavigationStack
    @EnvironmentObject var paletteViewState: PaletteSelectViewState
    @EnvironmentObject var colorManager : ColorManagement
    var colorPalette: palette
    var screenIndex: Int
    
    var body: some View {
        HStack{
            Button(action: {
                self.colorManager.modifyScreenPalette(withIndex: self.screenIndex, name: self.colorPalette.name)
                self.colorManager.setAllColors()
                self.navigation.unwind() })
            {
                Text(self.colorPalette.name)
                Spacer()
                Image(self.colorPalette.thumbnail).resizable().frame(width: 30, height: 57)
            }.buttonStyle(PlainButtonStyle())
        }
    }
}

// When tabbing one of the table lines then the following error message appears on the Xcode console:
// 2020-06-05 19:30:07.807413+0200 Kurzwahl2020[2630:1158516] [TableView] Warning once only: UITableView was told to layout its visible cells and other contents without being in the view hierarchy (the table view or one of its superviews has not been added to a window). This may cause bugs by forcing views inside the table view to load and perform layout without accurate information (e.g. table view bounds, trait collection, layout margins, safe area insets, etc), and will also cause unnecessary performance overhead due to extra layout passes. Make a symbolic breakpoint at UITableViewAlertForLayoutOutsideViewHierarchy to catch this in the debugger and see what caused this to occur, so you can avoid this action altogether if possible, or defer it until the table view has been added to a window. Table view: <_TtC7SwiftUIP33_BFB370BA5F1BADDC9D83021565761A4925UpdateCoalescingTableView: 0x10e00ac00; baseClass = UITableView; frame = (0 0; 375 637.333); clipsToBounds = YES; autoresize = W+H; gestureRecognizers = <NSArray: 0x2838a9950>; layer = <CALayer: 0x2836e49e0>; contentOffset: {0, 0}; contentSize: {375, 0}; adjustedContentInset: {0, 0, 0, 0}; dataSource: (null)>

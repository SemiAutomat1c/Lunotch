//
//  TipStore.swift
//  boringNotch
//
//  Created by Richard Kunkli on 15/09/2024.
//

import SwiftUI
import TipKit

struct HUDsTip: Tip {
    var title: Text {
        Text("Enhance your experience with HUDs")
    }
    
    
    var message: Text? {
        Text("Customize volume and brightness indicators from Settings to make the notch your own.")
    }
    
    
    var image: Image? {
        AppIcon(for: Bundle.main.bundleIdentifier ?? "dev.ryandeniega.lunotch")
    }
    
    var actions: [Action] {
        Action {
            Text("More")
        }
    }
}

struct CBTip: Tip {
    var title: Text {
        Text("Boost your productivity with Clipboard Manager")
    }
    
    
    var message: Text? {
        Text("Keep frequently used content close by, with quick access from the notch.")
    }
    
    
    var image: Image? {
        AppIcon(for: Bundle.main.bundleIdentifier ?? "dev.ryandeniega.lunotch")
    }
    
    var actions: [Action] {
        Action {
            Text("More")
        }
    }
}

struct TipsView: View {
    var hudTip = HUDsTip()
    var cbTip = CBTip()
    var body: some View {
        VStack {
            TipView(hudTip)
            TipView(cbTip)
        }
        .task {
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }
    }
}

#Preview {
    TipsView()
}

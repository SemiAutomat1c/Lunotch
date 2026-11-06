//
//  SoftwareUpdater.swift
//  boringNotch
//
//  Created by Richard Kunkli on 09/08/2024.
//

import SwiftUI

// The personal fork never uses the upstream Sparkle feed.
struct PersonalBuildUpdateNotice: View {
    var body: some View {
        Section("Software updates") {
            Text("This personal build is updated manually from its Xcode project.")
                .foregroundStyle(.secondary)
        }
    }
}

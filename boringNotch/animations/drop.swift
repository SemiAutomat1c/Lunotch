//
//  drop.swift
//  boringNotch
//
//  Created by Harsh Vardhan  Goswami  on  04/08/24.
//

import Foundation
import SwiftUI


public class BoringAnimations {
    @Published var notchStyle: Style = .notch
    
    init() {
        self.notchStyle = .notch
    }
    
    var animation: Animation {
        if #available(macOS 14.0, *), notchStyle == .notch {
            Animation.spring(.bouncy(duration: 0.4))
        } else {
            Animation.timingCurve(0.16, 1, 0.3, 1, duration: 0.7)
        }
    }
    
    // TODO: Move all animations to this file
    
}

/// Motion timings for the personal notch layout. Keep the shell, hover and
/// content transitions related so they feel like parts of the same surface.
enum NotchMotion {
    static let expand = Animation.spring(response: 0.46, dampingFraction: 0.78, blendDuration: 0.08)
    static let collapse = Animation.spring(response: 0.33, dampingFraction: 0.92, blendDuration: 0.06)
    static let hover = Animation.spring(response: 0.26, dampingFraction: 0.85, blendDuration: 0.05)
    static let content = Animation.spring(response: 0.42, dampingFraction: 0.86, blendDuration: 0.06)
    static let hud = Animation.spring(response: 0.34, dampingFraction: 0.86, blendDuration: 0.05)
    static let gesture = Animation.interactiveSpring(response: 0.34, dampingFraction: 0.82, blendDuration: 0.05)
    static let reducedMotion = Animation.easeInOut(duration: 0.16)
}

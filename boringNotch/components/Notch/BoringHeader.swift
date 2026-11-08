//
//  BoringHeader.swift
//  boringNotch
//
//  Created by Harsh Vardhan  Goswami  on 04/08/24.
//

import Defaults
import SwiftUI

struct BoringHeader: View {
    @EnvironmentObject var vm: BoringViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ObservedObject var batteryModel = BatteryStatusViewModel.shared
    @ObservedObject var coordinator = BoringViewCoordinator.shared
    @StateObject var tvm = ShelfStateViewModel.shared

    // The camera cutout occupies the center of the compact header. Leave
    // curved-edge clearance for Home, Shelf and one-tap screenshot capture.
    private var compactWingWidth: CGFloat {
        max(0, (focusedMusicNotchSize.width - 2 * focusedMusicHorizontalInset
            - vm.closedNotchSize.width) / 2)
    }

    private var compactEdgeInset: CGFloat {
        // Two 22pt tabs, the 22pt capture action and two 2pt gaps need 70pt.
        vm.usesFocusedMusicSize ? min(14, max(0, compactWingWidth - 70)) : 0
    }

    // Allow room for a three-digit battery percentage (including the % sign)
    // before displaying an additional shortcut in the compact right wing.
    private var canFitHeaderShortcut: Bool {
        guard vm.usesFocusedMusicSize else { return true }
        let batterySpace: CGFloat = Defaults[.showBatteryIndicator]
            ? (Defaults[.showBatteryPercentage] ? 62 : 22)
            : 0
        let shortcutSpace: CGFloat = 26 + (Defaults[.showBatteryIndicator] ? 2 : 0)
        return compactWingWidth - compactEdgeInset >= batterySpace + shortcutSpace
    }

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: vm.usesFocusedMusicSize ? 2 : 6) {
                if (!tvm.isEmpty || coordinator.alwaysShowTabs) && Defaults[.boringShelf] {
                    TabSelectionView(compact: vm.usesFocusedMusicSize)
                }
                Button {
                    ScreenshotStudio.shared.captureSelection()
                } label: {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: vm.usesFocusedMusicSize ? 12 : 14, weight: .medium))
                        .frame(width: vm.usesFocusedMusicSize ? 22 : 28, height: 26)
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Capture screenshot selection")
                .help("Capture a screenshot to edit in Screenshot Studio")
            }
            .padding(.leading, compactEdgeInset)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(vm.notchState == .closed ? 0 : 1)
            .blur(radius: reduceMotion ? 0 : vm.notchState == .closed ? 12 : 0)
            .zIndex(2)

            if vm.notchState == .open {
                Rectangle()
                    .fill(NSScreen.screen(withUUID: coordinator.selectedScreenUUID)?.safeAreaInsets.top ?? 0 > 0 ? .black : .clear)
                    .frame(width: vm.closedNotchSize.width)
                    .mask {
                        NotchShape()
                    }
            }

            HStack(spacing: vm.usesFocusedMusicSize ? 2 : 4) {
                if vm.notchState == .open {
                    if isHUDType(coordinator.sneakPeek.type) && coordinator.sneakPeek.show && Defaults[.showOpenNotchHUD] {
                        OpenNotchHUD(type: $coordinator.sneakPeek.type, value: $coordinator.sneakPeek.value, icon: $coordinator.sneakPeek.icon)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: reduceMotion ? 1 : 0.96)),
                                removal: .opacity
                            ))
                    } else {
                        if Defaults[.showMirror] && canFitHeaderShortcut {
                            Button(action: {
                                vm.toggleCameraPreview()
                            }) {
                                Capsule()
                                    .fill(.black)
                                    .frame(width: vm.usesFocusedMusicSize ? 26 : 30, height: vm.usesFocusedMusicSize ? 26 : 30)
                                    .overlay {
                                        Image(systemName: "web.camera")
                                            .foregroundColor(.white)
                                            .padding()
                                            .imageScale(.medium)
                                    }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        // The compact island keeps secondary shortcuts out of
                        // the battery's space beside the physical camera notch.
                        if Defaults[.settingsIconInNotch]
                            && (!vm.usesFocusedMusicSize || !Defaults[.showMirror])
                            && canFitHeaderShortcut {
                            Button(action: {
                                DispatchQueue.main.async {
                                    SettingsWindowController.shared.showWindow()
                                }
                                
                            }) {
                                Capsule()
                                    .fill(.black)
                                    .frame(width: vm.usesFocusedMusicSize ? 26 : 30, height: vm.usesFocusedMusicSize ? 26 : 30)
                                    .overlay {
                                        Image(systemName: "gear")
                                            .foregroundColor(.white)
                                            .padding()
                                            .imageScale(.medium)
                                    }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        if Defaults[.showBatteryIndicator] {
                            BoringBatteryView(
                                batteryWidth: vm.usesFocusedMusicSize ? 22 : 30,
                                isCharging: batteryModel.isCharging,
                                isInLowPowerMode: batteryModel.isInLowPowerMode,
                                isPluggedIn: batteryModel.isPluggedIn,
                                levelBattery: batteryModel.levelBattery,
                                maxCapacity: batteryModel.maxCapacity,
                                timeToFullCharge: batteryModel.timeToFullCharge,
                                isForNotification: false
                            )
                        }
                    }
                }
            }
            .font(.system(.headline, design: .rounded))
            .padding(.trailing, compactEdgeInset)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .opacity(vm.notchState == .closed ? 0 : 1)
            .blur(radius: reduceMotion ? 0 : vm.notchState == .closed ? 12 : 0)
            .zIndex(2)
        }
        .foregroundColor(.gray)
        .environmentObject(vm)
    }

    func isHUDType(_ type: SneakContentType) -> Bool {
        switch type {
        case .volume, .brightness, .backlight, .mic:
            return true
        default:
            return false
        }
    }
}

#Preview {
    BoringHeader().environmentObject(BoringViewModel())
}

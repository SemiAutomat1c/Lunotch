// Render the reviewed B2 Dock icon into the existing macOS app icon catalog.
// Run from the repository root: swift brand/render-b2-icon.swift
import AppKit
import Foundation

let source = URL(fileURLWithPath: "brand/lunotch-b2-dock.svg")
let iconSet = URL(fileURLWithPath: "boringNotch/Assets.xcassets/AppIcon.appiconset", isDirectory: true)
guard let image = NSImage(contentsOf: source), let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    fatalError("Could not load B2 SVG: \(source.path)")
}
for size in [16, 32, 64, 128, 256, 512, 1024] {
    guard let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
        fatalError("Could not create bitmap for \(size)px")
    }
    context.interpolationQuality = .high
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size, height: size))
    guard let rendered = context.makeImage(),
          let png = NSBitmapImageRep(cgImage: rendered).representation(using: .png, properties: [:]) else {
        fatalError("Could not encode \(size)px PNG")
    }
    try png.write(to: iconSet.appendingPathComponent("lunotch-\(size).png"), options: .atomic)
}
print("Rendered B2 macOS app icon at 16, 32, 64, 128, 256, 512 and 1024 pixels.")

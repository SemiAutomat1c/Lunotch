// Render the B2 identity into the app icon, in-app marks and menu-bar assets.
// Run from the repository root: swift brand/render-b2-icon.swift
import AppKit
import Foundation

let source = URL(fileURLWithPath: "brand/lunotch-b2-dock.svg")
let iconSet = URL(fileURLWithPath: "boringNotch/Assets.xcassets/AppIcon.appiconset", isDirectory: true)
let menuSource = URL(fileURLWithPath: "brand/lunotch-b2-menubar.svg")
let assetCatalog = URL(fileURLWithPath: "boringNotch/Assets.xcassets", isDirectory: true)

func loadImage(_ source: URL) -> CGImage {
    guard let image = NSImage(contentsOf: source),
          let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        fatalError("Could not load B2 SVG: \(source.path)")
    }
    return cgImage
}

func writePNG(_ image: CGImage, width: Int, height: Int, to destination: URL) throws {
    guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
        fatalError("Could not create bitmap for \(width)×\(height)px")
    }
    context.interpolationQuality = .high
    context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
    guard let rendered = context.makeImage(),
          let png = NSBitmapImageRep(cgImage: rendered).representation(using: .png, properties: [:]) else {
        fatalError("Could not encode \(width)×\(height)px PNG")
    }
    try png.write(to: destination, options: .atomic)
}

let dockImage = loadImage(source)
for size in [16, 32, 64, 128, 256, 512, 1024] {
    try writePNG(dockImage, width: size, height: size,
                 to: iconSet.appendingPathComponent("lunotch-\(size).png"))
}
for asset in ["logo", "logo2"] {
    try writePNG(dockImage, width: 1024, height: 1024,
                 to: assetCatalog.appendingPathComponent("\(asset).imageset/lunotch-mark.png"))
}

let menuImage = loadImage(menuSource)
let menuSet = assetCatalog.appendingPathComponent("LunotchMenuIcon.imageset", isDirectory: true)
try FileManager.default.createDirectory(at: menuSet, withIntermediateDirectories: true)
for scale in [1, 2] {
    try writePNG(menuImage, width: 28 * scale, height: 18 * scale,
                 to: menuSet.appendingPathComponent("lunotch-menu-\(scale)x.png"))
}
print("Rendered B2 app icon, in-app marks and monochrome menu-bar assets.")

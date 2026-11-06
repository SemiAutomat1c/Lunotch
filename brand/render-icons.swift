// Reproducible native macOS app icon renderer for the original Lunotch mark.
// Run from the repository root: swift brand/render-icons.swift
import AppKit
import Foundation

let assetRoot = URL(fileURLWithPath: "boringNotch/Assets.xcassets", isDirectory: true)
let brandRoot = URL(fileURLWithPath: "brand", isDirectory: true)
let canvas: CGFloat = 1024

func rgb(_ hex: UInt32, alpha: CGFloat = 1) -> CGColor {
    CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [
        CGFloat((hex >> 16) & 255) / 255,
        CGFloat((hex >> 8) & 255) / 255,
        CGFloat(hex & 255) / 255,
        alpha
    ])!
}

func gradient(_ colors: [CGColor]) -> CGGradient {
    CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)!
}

func rounded(_ rect: CGRect, radius: CGFloat) -> CGPath {
    CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

func drawMark(in context: CGContext) {
    context.setAllowsAntialiasing(true)
    context.setShouldAntialias(true)

    // A native macOS icon silhouette. The moon/orbit and floating island are one mark.
    let tile = rounded(CGRect(x: 12, y: 12, width: 1000, height: 1000), radius: 230)
    context.saveGState()
    context.addPath(tile)
    context.clip()
    context.drawLinearGradient(
        gradient([rgb(0x0B1022), rgb(0x252044), rgb(0x10162B)]),
        start: CGPoint(x: 90, y: 50), end: CGPoint(x: 950, y: 1040), options: []
    )
    context.drawRadialGradient(
        gradient([rgb(0x716BDE, alpha: 0.26), rgb(0x716BDE, alpha: 0)]),
        startCenter: CGPoint(x: 705, y: 356), startRadius: 5,
        endCenter: CGPoint(x: 705, y: 356), endRadius: 670, options: []
    )
    context.restoreGState()

    let orbit = CGMutablePath()
    orbit.move(to: CGPoint(x: 707, y: 296))
    orbit.addCurve(to: CGPoint(x: 417, y: 265), control1: CGPoint(x: 621, y: 228), control2: CGPoint(x: 506, y: 214))
    orbit.addCurve(to: CGPoint(x: 278, y: 498), control1: CGPoint(x: 321, y: 320), control2: CGPoint(x: 258, y: 407))
    orbit.addCurve(to: CGPoint(x: 448, y: 746), control1: CGPoint(x: 272, y: 614), control2: CGPoint(x: 332, y: 712))
    orbit.addCurve(to: CGPoint(x: 690, y: 659), control1: CGPoint(x: 539, y: 791), control2: CGPoint(x: 644, y: 727))

    context.saveGState()
    context.addPath(orbit)
    context.setLineWidth(87)
    context.setLineCap(.round)
    context.setLineJoin(.round)
    context.replacePathWithStrokedPath()
    context.clip()
    context.drawLinearGradient(
        gradient([rgb(0xE9E6FF), rgb(0xB9B5FF), rgb(0x7889FF)]),
        start: CGPoint(x: 270, y: 245), end: CGPoint(x: 750, y: 755), options: []
    )
    context.restoreGState()

    // A separate floating island that anchors the logo to the product's core interaction.
    let island = rounded(CGRect(x: 418, y: 416, width: 366, height: 148), radius: 74)
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: 20), blur: 32, color: rgb(0x070918, alpha: 0.58))
    context.addPath(island)
    context.setFillColor(rgb(0xD6D1FF))
    context.fillPath()
    context.restoreGState()

    context.addPath(rounded(CGRect(x: 432, y: 431, width: 338, height: 118), radius: 59))
    context.setFillColor(rgb(0x11162D))
    context.fillPath()

    context.addPath(rounded(CGRect(x: 480, y: 487, width: 117, height: 12), radius: 6))
    context.setFillColor(rgb(0xAAA7FF))
    context.fillPath()
    context.addPath(CGPath(ellipseIn: CGRect(x: 704, y: 482, width: 21, height: 21), transform: nil))
    context.setFillColor(rgb(0xE6E9FF))
    context.fillPath()
}

func writeIcon(size: Int, to url: URL) throws {
    let space = CGColorSpaceCreateDeviceRGB()
    guard let bitmap = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8,
                                 bytesPerRow: 0, space: space,
                                 bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
        throw NSError(domain: "LunotchIcon", code: 1)
    }
    // CoreGraphics starts at lower-left; work in our 1024 x 1024 top-left SVG coordinates.
    bitmap.translateBy(x: 0, y: CGFloat(size))
    bitmap.scaleBy(x: CGFloat(size) / canvas, y: -CGFloat(size) / canvas)
    drawMark(in: bitmap)
    guard let image = bitmap.makeImage(),
          let png = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else {
        throw NSError(domain: "LunotchIcon", code: 2)
    }
    try png.write(to: url)
}

let iconSet = assetRoot.appendingPathComponent("AppIcon.appiconset", isDirectory: true)
let entries: [(size: Int, points: Int, scale: Int)] = [
    (16, 16, 1), (32, 16, 2), (32, 32, 1), (64, 32, 2),
    (128, 128, 1), (256, 128, 2), (256, 256, 1),
    (512, 256, 2), (512, 512, 1), (1024, 512, 2)
]
let imageEntries: [[String: String]] = try entries.map { item in
    let filename = "lunotch-\(item.size).png"
    try writeIcon(size: item.size, to: iconSet.appendingPathComponent(filename))
    return ["filename": filename, "idiom": "mac", "scale": "\(item.scale)x", "size": "\(item.points)x\(item.points)"]
}
let iconContents: [String: Any] = ["images": imageEntries, "info": ["author": "xcode", "version": 1]]
let json = try JSONSerialization.data(withJSONObject: iconContents, options: [.prettyPrinted, .sortedKeys])
try json.write(to: iconSet.appendingPathComponent("Contents.json"))

// Existing asset names remain for compatibility with onboarding and any user settings.
for logo in ["logo", "logo2"] {
    let folder = assetRoot.appendingPathComponent("\(logo).imageset", isDirectory: true)
    try writeIcon(size: 1024, to: folder.appendingPathComponent("lunotch-mark.png"))
    let contents: [String: Any] = ["images": [["filename": "lunotch-mark.png", "idiom": "universal"]],
                                   "info": ["author": "xcode", "version": 1]]
    try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
        .write(to: folder.appendingPathComponent("Contents.json"))
}
try writeIcon(size: 1024, to: brandRoot.appendingPathComponent("lunotch-icon-1024.png"))
print("Rendered 10 macOS icon slots, two in-app logo assets and brand/lunotch-icon-1024.png")

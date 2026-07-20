// swift-tools-version: 6.1
// Secondary target: a fast `swift build` compile check. The shipping app is
// built from pushpop.xcodeproj, which is what produces the .app bundle.

import PackageDescription

let package = Package(
    name: "pushpop",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "pushpop",
            exclude: ["Info.plist"],
            resources: [.process("Assets.xcassets")]
        ),
    ]
)

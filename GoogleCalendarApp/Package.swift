// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FreeSlotExporter",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "FreeSlotExporter",
            targets: ["FreeSlotExporter"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/openid/AppAuth-iOS.git", from: "1.6.2")
    ],
    targets: [
        .executableTarget(
            name: "FreeSlotExporter",
            dependencies: [
                .product(name: "AppAuth", package: "AppAuth-iOS"),
                .product(name: "AppAuthCore", package: "AppAuth-iOS")
            ],
            path: "GoogleCalendarApp",
            exclude: ["Info.plist"],
            resources: [
                .process("Config.plist")
            ],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("SwiftUI")
            ]
        )
    ]
)
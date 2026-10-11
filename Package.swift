// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MacPlayer",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "MacPlayer",
            path: "Sources/MacPlayer"
        )
    ]
)

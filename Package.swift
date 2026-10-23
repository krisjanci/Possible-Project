// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "NextStep",
    platforms: [.macOS(.v26)],
    products: [.executable(name: "NextStep", targets: ["NextStep"])],
    targets: [
        .executableTarget(
            name: "NextStep",
            path: "Sources/NextStep"
        )
    ]
)

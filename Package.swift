// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "YandexDeliveryExpressAPI",
    defaultLocalization: "en",
    // iOS 17 / macOS 14: `Observation` is unconditional for SwiftUI consumers, and every
    // `@available` guard the package used to carry disappears. See the DocC `Design` article.
    platforms: [.macOS(.v14), .iOS(.v17), .tvOS(.v17), .watchOS(.v10), .visionOS(.v1)],
    products: [.library(name: "YandexDeliveryExpressAPI", targets: ["YandexDeliveryExpressAPI"])],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.13.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.12.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.3.1"),
        .package(url: "https://github.com/laconicman/OSLogLoggingMiddleware", from: "1.0.0"),
        // Renders the DocC catalog, including the direction articles.
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.3")
    ],
    targets: [
        .target(
            name: "YandexDeliveryExpressAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                .product(name: "OSLogLoggingMiddleware", package: "OSLogLoggingMiddleware")
            ],
            resources: [.process("Resources/Localizable.xcstrings")],
            // The generator is a *plugin*, never a `dependencies:` entry. It finds
            // `openapi.yaml` and `openapi-generator-config.yaml` by scanning the target's
            // files, so those two must stay in the target's sources — not excluded, and not
            // declared as resources (which would copy the YAML into every consuming app).
            // SwiftPM may report them as unhandled; that is expected.
            plugins: [.plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")]
        ),
        .testTarget(
            name: "YandexDeliveryExpressAPITests",
            dependencies: ["YandexDeliveryExpressAPI"]
        )
    ]
)

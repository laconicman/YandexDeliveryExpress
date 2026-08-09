// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "YandexDeliveryExpressAPI",
    defaultLocalization: "en",
    platforms: [.macOS(.v11), .iOS(.v14), .tvOS(.v14), .watchOS(.v7), .visionOS(.v1)],
    products: [.library(name: "YandexDeliveryExpressAPI", targets: ["YandexDeliveryExpressAPI"])],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.9.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.8.2"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.1.0"),
        .package(url: "https://github.com/laconicman/OSLogLoggingMiddleware", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "YandexDeliveryExpressAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                .product(name: "OSLogLoggingMiddleware", package: "OSLogLoggingMiddleware")
            ]
        ),
        .testTarget(name: "YandexDeliveryExpressAPITests",
            dependencies: ["YandexDeliveryExpressAPI"]
        )
    ]
)

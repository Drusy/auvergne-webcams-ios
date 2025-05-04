// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "Dependencies",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AppDependencies",
            targets: ["AppDependencies"]
        ),
        .library(
            name: "WidgetDependencies",
            targets: ["AppDependencies"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/optonaut/ActiveLabel.swift.git", .upToNextMajor(from: "1.1.5")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.4")),
        .package(url: "https://github.com/xmartlabs/Eureka.git", .upToNextMajor(from: "5.4.0")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "10.5.0")),
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "7.6.2")),
        .package(url: "https://github.com/mapbox/mapbox-maps-ios.git", .upToNextMajor(from: "10.11.1")),
        .package(url: "https://github.com/ninjaprox/NVActivityIndicatorView.git", .upToNextMajor(from: "5.1.1")),
        .package(url: "https://github.com/ashleymills/Reachability.swift.git", .upToNextMajor(from: "5.1.0")),
        .package(url: "https://github.com/realm/realm-swift.git", .upToNextMajor(from: "10.36.0")),
        .package(url: "https://github.com/ArtSabintsev/Siren.git", .upToNextMajor(from: "6.1.0")),
        .package(url: "https://github.com/sereivoanyong/SVProgressHUD.git", branch: "master"),
        .package(url: "https://github.com/openium/SwiftiumKit.git", .upToNextMajor(from: "2.1.1")),
        .package(url: "https://github.com/eddiekaiger/SwiftyAttributes.git", .upToNextMajor(from: "5.2.0")),
        .package(url: "https://github.com/sunshinejr/SwiftyUserDefaults.git", .upToNextMajor(from: "5.3.0"))
    ],
    targets: [
        .target(
            name: "AppDependencies",
            dependencies: [
                .product(name: "ActiveLabel", package: "ActiveLabel.swift"),
                "Alamofire",
                "Eureka",
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                "Kingfisher",
                .product(name: "MapboxMaps", package: "mapbox-maps-ios"),
                "NVActivityIndicatorView",
                .product(name: "Reachability", package: "Reachability.swift"),
                .product(name: "RealmSwift", package: "realm-swift"),
                "Siren",
                "SVProgressHUD",
                "SwiftiumKit",
                "SwiftyAttributes",
                "SwiftyUserDefaults"
            ]
        ),
        .target(
            name: "WidgetDependencies",
            dependencies: [
                "Alamofire",
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                "Kingfisher",
                .product(name: "RealmSwift", package: "realm-swift"),
                "SwiftyUserDefaults"
            ]
        )
    ]
)

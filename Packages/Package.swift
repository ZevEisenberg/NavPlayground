// swift-tools-version:5.5

import PackageDescription

extension BuildItem {
    // Infrastructure

    static let autoTCA = BuildItem(
        name: "AutoTCA",
        dependencies: [
            .composableArchitecture,
        ]
    )

    // Features

    static let rootFeature = BuildItem(
        name: "RootFeature",
        dependencies: [
            .splashPage,
            .appFeature,
            .autoTCA,
        ]
    )

    static let splashPage = BuildItem(
        name: "SplashPage",
        resources: [
            .copy("waterdrop.mp4"),
        ])

    static let appFeature = BuildItem(
        name: "AppFeature",
        dependencies: [
            .autoTCA,
            .composableArchitecture,
            .settingsFeature,
            .homeFeature,
//            .colorsFeature,
        ]
    )

    static let homeFeature = BuildItem(
        name: "HomeFeature",
        dependencies: [
            .autoTCA,
            .composableArchitecture,
            .settingsFeature,
//            .colorsFeature,
        ]
    )

    static let settingsFeature = BuildItem(
        name: "SettingsFeature",
        dependencies: [
            .autoTCA,
            .composableArchitecture,
        ]
    )

    static let colorsFeature = BuildItem(
        name: "ColorsFeature",
        dependencies: [
            BuildItem.autoTCA.dependency,
            .composableArchitecture,
            BuildItem.overture.dependency,
        ]
    )

    // MARK: Third Party
    
    static var composableArchitecture: BuildItem {
        .init(name: "ComposableArchitecture", dependency: .product(name: "ComposableArchitecture", package: "swift-composable-architecture"))
    }

    static var overture: BuildItem {
        .init(name: "Overture", dependency: .product(name: "Overture", package: "overture"))
    }
}

let items: [BuildItem] = [
    .splashPage,
    .autoTCA,
    .settingsFeature,
    .colorsFeature,
    .homeFeature,
    .appFeature,
    .rootFeature,
]

let testTargets: [Target] = [
    .testTarget(
        name: "AppFeatureTests",
        dependencies: [
            BuildItem.appFeature.dependency,
            .composableArchitecture,
        ]),
]

extension Target.Dependency {
    static var composableArchitecture: Self {
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    }
}

let package = Package(
    name: "Packages",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: items.map(\.library),
    dependencies: [
        .package(name: "swift-composable-architecture", url: "https://github.com/pointfreeco/swift-composable-architecture", .exact("0.35.0")),
        .package(name: "Overture", url: "https://github.com/pointfreeco/swift-overture", .upToNextMajor(from: "0.5.0")),
    ],
    targets: items.map(\.target) + testTargets
)

// MARK: - Meta

struct BuildItem {
    let name: String
    let dependency: Target.Dependency
    let dependencies: [Target.Dependency]
    let resources: [Resource]?

    init(name: String, dependency: Target.Dependency? = nil, dependencies: [Target.Dependency] = [], resources: [Resource]? = nil) {
        self.name = name
        self.dependency = dependency ?? .init(stringLiteral: name)
        self.dependencies = dependencies
        self.resources = resources
    }

    var library: Product {
        Product.library(name: name, targets: [name])
    }
    var target: Target {
        Target.target(name: name, dependencies: dependencies, resources: resources)
    }
}

extension BuildItem {
    init(name: String, dependencies: [BuildItem]) {
        self.init(name: name, dependency: nil, dependencies: dependencies.map(\.dependency))
    }
}

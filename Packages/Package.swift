// swift-tools-version:5.7

import PackageDescription

extension BuildItem {
    // Features

    static let rootFeature = BuildItem(
        name: "RootFeature",
        dependencies: [
            .splashPage,
            .appFeature,
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
            .composableArchitecture,
            .settingsFeature,
            .homeFeature,
            .colorsFeature,
        ]
    )

    static let homeFeature = BuildItem(
        name: "HomeFeature",
        dependencies: [
            .composableArchitecture,
            .settingsFeature,
            .colorsFeature,
        ]
    )

    static let settingsFeature = BuildItem(
        name: "SettingsFeature",
        dependencies: [
            .composableArchitecture,
        ]
    )

    static let colorsFeature = BuildItem(
        name: "ColorsFeature",
        dependencies: [
            .composableArchitecture,
            BuildItem.overture.dependency,
            BuildItem.swiftUINavigation.dependency,
        ]
    )

    // MARK: Third Party
    
    static var composableArchitecture: BuildItem {
        .init(name: "ComposableArchitecture", dependency: .product(name: "ComposableArchitecture", package: "swift-composable-architecture"))
    }

    static var overture: BuildItem {
        .init(name: "swift-overture", dependency: .product(name: "Overture", package: "swift-overture"))
    }

    static var swiftUINavigation: BuildItem {
        .init(name: "SwiftUINavigation", dependency: .product(name: "SwiftUINavigation", package: "swiftui-navigation"))
    }
}

let items: [BuildItem] = [
    .splashPage,
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
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: items.map(\.library),
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "0.45.0"),
        .package(url: "https://github.com/pointfreeco/swift-overture", exact: "0.5.0"),
        .package(url: "https://github.com/pointfreeco/swiftui-navigation", exact: "0.3.0"),
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

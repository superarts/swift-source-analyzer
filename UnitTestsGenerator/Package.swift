// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UnitTestsGenerator",
    products: [
        .executable(name: "unit-tests-generator", targets: ["UnitTestsGenerator"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(
            url: "https://github.com/apple/swift-argument-parser", 
            .upToNextMinor(from: "0.3.0")
        ),
        Package.Dependency.package(
            name: "SwiftWheel",
            path: "../"
        ),
		/*
        .package(
            name: "SwiftWheel", // <- Not sure why this is needed, help? UPDATE: not needed anymore?
            url: "https://github.com/superarts/swift-source-analyzer/SwiftWheel", 
			.revision("486e1c9256d65cd8078985bab9b1af12430e4b9c")
        ),
		*/
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "UnitTestsGenerator",
            dependencies: [
                .product(
                    name: "SwiftWheel",
                    package: "SwiftWheel"
                ),
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
			]),
        .testTarget(
            name: "UnitTestsGeneratorTests",
            dependencies: ["UnitTestsGenerator"]),
    ]
)

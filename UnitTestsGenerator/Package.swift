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
            name: "SwiftWheel", // <- Without this, `swift build` returns "unknown package 'SwiftWheel' in dependencies of target 'UnitTestsGenerator'"
            url: "https://github.com/superarts/swift-source-analyzer", // <- Until 20210529, sub-directory inside a repo is not supported by SPM - see `SE-0292`
			.revision("49f8e1f000441eb6d2f4a5e3679657a227c56ef3")
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

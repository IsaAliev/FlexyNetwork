// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlexyNetwork",
	platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "FlexyNetwork",
            targets: ["FlexyNetwork"]
		),
    ],
    targets: [
        .target(
            name: "FlexyNetwork",
			path: "FlexyNetwork"
		)
    ]
)

// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "wren-swift",
    
    products: [
      .library(name: "CWren", targets: [ "Wren" ]),
      .library(name: "Wren",  targets: [ "Wren" ])
    ],
    
    targets: [
      .target(name: "CWren", exclude: [ "AUTHORS", "LICENSE" ]),
      .target(name: "Wren",  dependencies: [ "Cwren" ]),
      .testTarget(name: "CWrenTests", dependencies: ["Cwren"]),
      .testTarget(name: "WrenTests",  dependencies: ["Wren"])
    ]
)

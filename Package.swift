// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "wren-swift",
    
    products: [
      .library(name: "CWren", targets: [ "CWren" ]),
      .library(name: "Wren",  targets: [ "Wren"  ])
    ],
    
    targets: [
      .target(name: "CWren", exclude: [ "AUTHORS", "LICENSE" ]),
      .target(name: "Wren",  dependencies: [ "CWren" ]),
      .testTarget(name: "CWrenTests", dependencies: ["CWren"]),
      .testTarget(name: "WrenTests",  dependencies: ["Wren"])
    ]
)

// swift-tools-version: 5.10

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Playground",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .iOSApplication(
            name: "Playground",
            targets: ["AppModule"],
            bundleIdentifier: "FB397E53-24E3-4C25-961A-989412D3D78B",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    
    dependencies: [
        .package(path: "../")
    ],
    
    targets: [
        .executableTarget(
            name: "AppModule",
            
            dependencies: [
                .product(
                    name: "DAWNText2",
                    package: "DAWNText2"
                )
            ],
            
            path: "."
        )
    ]
)

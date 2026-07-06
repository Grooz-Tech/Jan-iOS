// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [:]
    )
#endif

let package = Package(
    name: "Jan",
    dependencies: [
        // Add SPM dependencies here, e.g.:
        // .package(url: "https://github.com/Alamofire/Alamofire", exact: "5.12.0"),
    ]
)

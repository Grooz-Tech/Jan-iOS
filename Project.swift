import ProjectDescription

let teamId = "BWTLDG8C39"

let appBundleId = "kz.jan.app"

let appDisplayName = "Jan"

// MARKETING_VERSION comes from Version.xcconfig (source of truth, bumped per release).
// Build number is supplied by CI via TUIST_CURRENT_PROJECT_VERSION (github.run_number).
let buildNumber = Environment.currentProjectVersion.getString(default: "1")

// Manual signing settings for a target, wiring the "match Development/AppStore <bundleId>"
// provisioning profiles. `extraBase` adds target-specific base build settings.
func signingSettings(
    bundleId: String,
    extraBase: SettingsDictionary = [:]
) -> Settings {
    .settings(
        base: [
            "DEVELOPMENT_TEAM": .string(teamId),
            "CODE_SIGN_STYLE": "Manual",
            "CURRENT_PROJECT_VERSION": .string(buildNumber),
        ].merging(extraBase) { _, new in new },
        configurations: [
            .debug(
                name: "Debug",
                settings: [
                    "CODE_SIGN_IDENTITY": "Apple Development",
                    "PROVISIONING_PROFILE_SPECIFIER": "match Development \(bundleId)",
                ],
                xcconfig: "Version.xcconfig"
            ),
            .release(
                name: "Release",
                settings: [
                    "CODE_SIGN_IDENTITY": "Apple Distribution",
                    "PROVISIONING_PROFILE_SPECIFIER": "match AppStore \(bundleId)",
                ],
                xcconfig: "Version.xcconfig"
            ),
        ]
    )
}

let serviceExtensionBundleId = "\(appBundleId).NotificationService"

let appSigningSettings = signingSettings(
    bundleId: appBundleId,
    extraBase: ["INFOPLIST_KEY_CFBundleDisplayName": .string(appDisplayName)]
)

let serviceExtensionSigningSettings = signingSettings(bundleId: serviceExtensionBundleId)

let project = Project(
    name: "Jan",
    targets: [
        .target(
            name: "Jan",
            destinations: [.iPhone],
            product: .app,
            bundleId: appBundleId,
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "$(INFOPLIST_KEY_CFBundleDisplayName)",
                    "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                    "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                    "ITSAppUsesNonExemptEncryption": false,
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait",
                    ],
                    "UILaunchScreen": [
                        "UIColorName": "LaunchBackground",
                        "UIImageName": "",
                    ],
                ]
            ),
            buildableFolders: [
                "Jan/Sources",
                "Jan/Resources",
            ],
            dependencies: [
                .target(name: "NotificationService"),
            ],
            settings: appSigningSettings
        ),
        .target(
            name: "NotificationService",
            destinations: [.iPhone],
            product: .appExtension,
            bundleId: serviceExtensionBundleId,
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "NotificationService",
                    "NSExtension": [
                        "NSExtensionPointIdentifier": "com.apple.usernotifications.service",
                        "NSExtensionPrincipalClass": "$(PRODUCT_MODULE_NAME).NotificationService",
                    ],
                ]
            ),
            buildableFolders: [
                "NotificationService",
            ],
            settings: serviceExtensionSigningSettings
        ),
        .target(
            name: "JanTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "\(appBundleId).JanTests",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            buildableFolders: [
                "Jan/Tests"
            ],
            dependencies: [.target(name: "Jan")],
            settings: .settings(base: ["DEVELOPMENT_TEAM": .string(teamId)])
        ),
    ]
)

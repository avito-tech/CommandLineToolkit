// swift-tools-version:5.3
import PackageDescription
let package = Package(
    name: "CommandLineToolkit",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        .library(name: "AtomicModels", targets: ["AtomicModels"]),
        .library(name: "CLTExtensions", targets: ["CLTExtensions"]),
        .library(name: "DateProvider", targets: ["DateProvider"]),
        .library(name: "DateProviderTestHelpers", targets: ["DateProviderTestHelpers"]),
        .library(name: "FileSystem", targets: ["FileSystem"]),
        .library(name: "FileSystemTestHelpers", targets: ["FileSystemTestHelpers"]),
        .library(name: "Graphite", targets: ["Graphite"]),
        .library(name: "GraphiteClient", targets: ["GraphiteClient"]),
        .library(name: "IO", targets: ["IO"]),
        .library(name: "JSONStream", targets: ["JSONStream"]),
        .library(name: "LaunchdUtils", targets: ["LaunchdUtils"]),
        .library(name: "Metrics", targets: ["Metrics"]),
        .library(name: "MetricsTestHelpers", targets: ["MetricsTestHelpers"]),
        .library(name: "MetricsUtils", targets: ["MetricsUtils"]),
        .library(name: "ObjCExceptionCatcher", targets: ["ObjCExceptionCatcher"]),
        .library(name: "ObjCExceptionCatcherHelper", targets: ["ObjCExceptionCatcherHelper"]),
        .library(name: "PathLib", targets: ["PathLib"]),
        .library(name: "PlistLib", targets: ["PlistLib"]),
        .library(name: "ProcessController", targets: ["ProcessController"]),
        .library(name: "ProcessControllerTestHelpers", targets: ["ProcessControllerTestHelpers"]),
        .library(name: "SignalHandling", targets: ["SignalHandling"]),
        .library(name: "SocketModels", targets: ["SocketModels"]),
        .library(name: "Statsd", targets: ["Statsd"]),
        .library(name: "String", targets: ["String"]),
        .library(name: "SynchronousWaiter", targets: ["SynchronousWaiter"]),
        .library(name: "TestHelpers", targets: ["TestHelpers"]),
        .library(name: "Timer", targets: ["Timer"]),
        .library(name: "Tmp", targets: ["Tmp"]),
        .library(name: "TmpTestHelpers", targets: ["TmpTestHelpers"]),
        .library(name: "Types", targets: ["Types"]),
        .library(name: "UserDefaultsLib", targets: ["UserDefaultsLib"]),
        .library(name: "UserDefaultsLibTestHelpers", targets: ["UserDefaultsLibTestHelpers"]),
        .library(name: "Waitable", targets: ["Waitable"]),
        .library(name: "XcodeLocator", targets: ["XcodeLocator"]),
        .library(name: "XcodeLocatorModels", targets: ["XcodeLocatorModels"]),
    ],
    dependencies: [
        .package(name: "Glob", url: "https://github.com/Bouke/Glob", .exact("1.0.5")),
        .package(name: "Signals", url: "https://github.com/IBM-Swift/BlueSignals.git", .exact("1.0.21")),
    ],
    targets: [
        .target(
            name: "AtomicModels",
            dependencies: [
            ],
            path: "Sources/AtomicModels"
        ),
        .target(
            name: "CLTExtensions",
            dependencies: [
            ],
            path: "Sources/CLTExtensions"
        ),
        .testTarget(
            name: "CLTExtensionsTests",
            dependencies: [
                "CLTExtensions",
            ],
            path: "Tests/CLTExtensionsTests"
        ),
        .target(
            name: "DateProvider",
            dependencies: [
            ],
            path: "Sources/DateProvider"
        ),
        .target(
            name: "DateProviderTestHelpers",
            dependencies: [
                "DateProvider",
            ],
            path: "Tests/DateProviderTestHelpers"
        ),
        .target(
            name: "FileSystem",
            dependencies: [
                .product(name: "Glob", package: "Glob"),
                "PathLib",
            ],
            path: "Sources/FileSystem"
        ),
        .target(
            name: "FileSystemTestHelpers",
            dependencies: [
                "FileSystem",
                "PathLib",
            ],
            path: "Tests/FileSystemTestHelpers"
        ),
        .testTarget(
            name: "FileSystemTests",
            dependencies: [
                "DateProvider",
                "FileSystem",
                "PathLib",
                "TestHelpers",
                "Tmp",
                "TmpTestHelpers",
            ],
            path: "Tests/FileSystemTests"
        ),
        .target(
            name: "Graphite",
            dependencies: [
                "GraphiteClient",
                "IO",
                "MetricsUtils",
                "SocketModels",
            ],
            path: "Sources/Graphite"
        ),
        .target(
            name: "GraphiteClient",
            dependencies: [
                "AtomicModels",
                "IO",
            ],
            path: "Sources/GraphiteClient"
        ),
        .testTarget(
            name: "GraphiteClientTests",
            dependencies: [
                "AtomicModels",
                "GraphiteClient",
                "IO",
            ],
            path: "Tests/GraphiteClientTests"
        ),
        .target(
            name: "IO",
            dependencies: [
                "AtomicModels",
            ],
            path: "Sources/IO"
        ),
        .testTarget(
            name: "IOTests",
            dependencies: [
                "IO",
                "TestHelpers",
            ],
            path: "Tests/IOTests"
        ),
        .target(
            name: "JSONStream",
            dependencies: [
                "AtomicModels",
            ],
            path: "Sources/JSONStream"
        ),
        .testTarget(
            name: "JSONStreamTests",
            dependencies: [
                "JSONStream",
                "TestHelpers",
            ],
            path: "Tests/JSONStreamTests"
        ),
        .target(
            name: "LaunchdUtils",
            dependencies: [
            ],
            path: "Sources/LaunchdUtils"
        ),
        .testTarget(
            name: "LaunchdUtilsTests",
            dependencies: [
                "LaunchdUtils",
            ],
            path: "Tests/LaunchdUtilsTests"
        ),
        .target(
            name: "Metrics",
            dependencies: [
                "DateProvider",
                "Graphite",
                "Statsd",
            ],
            path: "Sources/Metrics"
        ),
        .target(
            name: "MetricsTestHelpers",
            dependencies: [
                "Graphite",
                "Metrics",
                "Statsd",
            ],
            path: "Tests/MetricsTestHelpers"
        ),
        .testTarget(
            name: "MetricsTests",
            dependencies: [
                "DateProviderTestHelpers",
                "Graphite",
                "Metrics",
                "MetricsTestHelpers",
                "Statsd",
                "TestHelpers",
            ],
            path: "Tests/MetricsTests"
        ),
        .target(
            name: "MetricsUtils",
            dependencies: [
                "IO",
            ],
            path: "Sources/MetricsUtils"
        ),
        .target(
            name: "ObjCExceptionCatcher",
            dependencies: [
                "ObjCExceptionCatcherHelper",
            ],
            path: "Sources/ObjCExceptionCatcher"
        ),
        .target(
            name: "ObjCExceptionCatcherHelper",
            dependencies: [
            ],
            path: "Sources/ObjCExceptionCatcherHelper"
        ),
        .target(
            name: "PathLib",
            dependencies: [
            ],
            path: "Sources/PathLib"
        ),
        .testTarget(
            name: "PathLibTests",
            dependencies: [
                "PathLib",
                "TestHelpers",
            ],
            path: "Tests/PathLibTests"
        ),
        .target(
            name: "PlistLib",
            dependencies: [
            ],
            path: "Sources/PlistLib"
        ),
        .testTarget(
            name: "PlistLibTests",
            dependencies: [
                "PlistLib",
                "TestHelpers",
            ],
            path: "Tests/PlistLibTests"
        ),
        .target(
            name: "ProcessController",
            dependencies: [
                "AtomicModels",
                "DateProvider",
                "FileSystem",
                "ObjCExceptionCatcher",
                "PathLib",
                "SignalHandling",
                "Timer",
            ],
            path: "Sources/ProcessController"
        ),
        .target(
            name: "ProcessControllerTestHelpers",
            dependencies: [
                "ProcessController",
                "SynchronousWaiter",
                "Tmp",
            ],
            path: "Tests/ProcessControllerTestHelpers"
        ),
        .testTarget(
            name: "ProcessControllerTests",
            dependencies: [
                "DateProvider",
                "FileSystem",
                "PathLib",
                "ProcessController",
                "ProcessControllerTestHelpers",
                "SignalHandling",
                "TestHelpers",
                "Tmp",
            ],
            path: "Tests/ProcessControllerTests"
        ),
        .target(
            name: "SignalHandling",
            dependencies: [
                .product(name: "Signals", package: "Signals"),
                "Types",
            ],
            path: "Sources/SignalHandling"
        ),
        .testTarget(
            name: "SignalHandlingTests",
            dependencies: [
                "SignalHandling",
                .product(name: "Signals", package: "Signals"),
            ],
            path: "Tests/SignalHandlingTests"
        ),
        .target(
            name: "SocketModels",
            dependencies: [
                "Types",
            ],
            path: "Sources/SocketModels"
        ),
        .target(
            name: "Statsd",
            dependencies: [
                "AtomicModels",
                "IO",
                "MetricsUtils",
                "SocketModels",
                "Waitable",
            ],
            path: "Sources/Statsd"
        ),
        .testTarget(
            name: "StatsdTests",
            dependencies: [
                "Metrics",
                "Statsd",
            ],
            path: "Tests/StatsdTests"
        ),
        .target(
            name: "String",
            dependencies: [
            ],
            path: "Sources/String"
        ),
        .testTarget(
            name: "StringTests",
            dependencies: [
                "String",
            ],
            path: "Tests/StringTests"
        ),
        .target(
            name: "SynchronousWaiter",
            dependencies: [
                "AtomicModels",
            ],
            path: "Sources/SynchronousWaiter"
        ),
        .testTarget(
            name: "SynchronousWaiterTests",
            dependencies: [
                "SynchronousWaiter",
                "TestHelpers",
            ],
            path: "Tests/SynchronousWaiterTests"
        ),
        .testTarget(
            name: "TemporaryStuffTests",
            dependencies: [
                "PathLib",
                "TestHelpers",
                "Tmp",
            ],
            path: "Tests/TemporaryStuffTests"
        ),
        .target(
            name: "TestHelpers",
            dependencies: [
            ],
            path: "Tests/TestHelpers"
        ),
        .target(
            name: "Timer",
            dependencies: [
            ],
            path: "Sources/Timer"
        ),
        .target(
            name: "Tmp",
            dependencies: [
                "PathLib",
            ],
            path: "Sources/Tmp"
        ),
        .target(
            name: "TmpTestHelpers",
            dependencies: [
                "TestHelpers",
                "Tmp",
            ],
            path: "Tests/TmpTestHelpers"
        ),
        .target(
            name: "Types",
            dependencies: [
            ],
            path: "Sources/Types"
        ),
        .testTarget(
            name: "TypesTests",
            dependencies: [
                "Types",
            ],
            path: "Tests/TypesTests"
        ),
        .target(
            name: "UserDefaultsLib",
            dependencies: [
                "PlistLib",
            ],
            path: "Sources/UserDefaultsLib"
        ),
        .target(
            name: "UserDefaultsLibTestHelpers",
            dependencies: [
                "PlistLib",
                "UserDefaultsLib",
            ],
            path: "Tests/UserDefaultsLibTestHelpers"
        ),
        .target(
            name: "Waitable",
            dependencies: [
            ],
            path: "Sources/Waitable"
        ),
        .testTarget(
            name: "WaitableTests",
            dependencies: [
                "Waitable",
            ],
            path: "Tests/WaitableTests"
        ),
        .target(
            name: "XcodeLocator",
            dependencies: [
                "FileSystem",
                "PathLib",
                "PlistLib",
                "XcodeLocatorModels",
            ],
            path: "Sources/XcodeLocator"
        ),
        .target(
            name: "XcodeLocatorModels",
            dependencies: [
                "PathLib",
            ],
            path: "Sources/XcodeLocatorModels"
        ),
        .testTarget(
            name: "XcodeLocatorTests",
            dependencies: [
                "FileSystem",
                "FileSystemTestHelpers",
                "PlistLib",
                "TestHelpers",
                "TmpTestHelpers",
                "XcodeLocator",
                "XcodeLocatorModels",
            ],
            path: "Tests/XcodeLocatorTests"
        ),
    ]
)

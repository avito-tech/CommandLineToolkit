// swift-tools-version:5.5
import PackageDescription

var targets = [Target]()
// MARK: AtomicModels
targets.append(
    .target(
        name: "AtomicModels",
        dependencies: [
        ],
        path: "Sources/AtomicModels"
    )
)
// MARK: CLTCollections
targets.append(
    .target(
        name: "CLTCollections",
        dependencies: [
            "Types",
        ],
        path: "Sources/CLTCollections"
    )
)
// MARK: CLTExtensions
targets.append(
    .target(
        name: "CLTExtensions",
        dependencies: [
        ],
        path: "Sources/CLTExtensions"
    )
)
// MARK: CLTExtensionsTests
targets.append(
    .testTarget(
        name: "CLTExtensionsTests",
        dependencies: [
            "CLTCollections",
            "CLTExtensions",
            "TestHelpers",
        ],
        path: "Tests/CLTExtensionsTests"
    )
)
// MARK: CLTLogging
targets.append(
    .target(
        name: "CLTLogging",
        dependencies: [
            "AtomicModels",
            "CLTLoggingModels",
            "DateProvider",
            "FileSystem",
            "Kibana",
            "KibanaModels",
            "PathLib",
            "ProcessController",
            "Tmp",
        ],
        path: "Sources/CLTLogging"
    )
)
// MARK: CLTLoggingModels
targets.append(
    .target(
        name: "CLTLoggingModels",
        dependencies: [
        ],
        path: "Sources/CLTLoggingModels"
    )
)
// MARK: CLTLoggingTestHelpers
targets.append(
    .target(
        name: "CLTLoggingTestHelpers",
        dependencies: [
            "CLTLogging",
            "CLTLoggingModels",
        ],
        path: "Tests/CLTLoggingTestHelpers"
    )
)
// MARK: CLTLoggingTests
targets.append(
    .testTarget(
        name: "CLTLoggingTests",
        dependencies: [
            "CLTLogging",
            "CLTLoggingModels",
            "CLTLoggingTestHelpers",
            "DateProviderTestHelpers",
            "Kibana",
            "KibanaTestHelpers",
            "TestHelpers",
            "Tmp",
        ],
        path: "Tests/CLTLoggingTests"
    )
)
// MARK: CLTTypes
targets.append(
    .target(
        name: "CLTTypes",
        dependencies: [
            "CLTExtensions",
        ],
        path: "Sources/CLTTypes"
    )
)
// MARK: Cloc
targets.append(
    .target(
        name: "Cloc",
        dependencies: [
            "FileSystem",
            "PathLib",
            "ProcessController",
        ],
        path: "Sources/Cloc"
    )
)
// MARK: CommandSupport
targets.append(
    .target(
        name: "CommandSupport",
        dependencies: [
            "CLTExtensions",
            "DI",
            "PathLib",
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ],
        path: "Sources/CommandSupport"
    )
)
// MARK: CommandSupportTests
targets.append(
    .testTarget(
        name: "CommandSupportTests",
        dependencies: [
            "CommandSupport",
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ],
        path: "Tests/CommandSupportTests"
    )
)
// MARK: Concurrency
targets.append(
    .target(
        name: "Concurrency",
        dependencies: [
            "PathLib",
        ],
        path: "Sources/Concurrency"
    )
)
// MARK: Console
targets.append(
    .target(
        name: "Console",
        dependencies: [
            "AtomicModels",
            "DI",
            "SignalHandling",
            .product(name: "Logging", package: "swift-log"),
            .product(name: "Yams", package: "Yams"),
        ],
        path: "Sources/Console",
        exclude: [
            "ANSI/README.md",
            "target.json",
        ]
    )
)
// MARK: ConsoleTestHelpers
targets.append(
    .target(
        name: "ConsoleTestHelpers",
        dependencies: [
            "Console",
            .product(name: "Logging", package: "swift-log"),
        ],
        path: "Tests/ConsoleTestHelpers"
    )
)
// MARK: ConsoleTests
targets.append(
    .testTarget(
        name: "ConsoleTests",
        dependencies: [
            "Console",
        ],
        path: "Tests/ConsoleTests"
    )
)
// MARK: DI
targets.append(
    .target(
        name: "DI",
        dependencies: [
        ],
        path: "Sources/DI",
        exclude: [
            "README.md",
            "target.json",
        ]
    )
)
// MARK: DateProvider
targets.append(
    .target(
        name: "DateProvider",
        dependencies: [
            "DI",
        ],
        path: "Sources/DateProvider"
    )
)
// MARK: DateProviderTestHelpers
targets.append(
    .target(
        name: "DateProviderTestHelpers",
        dependencies: [
            "DateProvider",
        ],
        path: "Tests/DateProviderTestHelpers"
    )
)
// MARK: Downloader
targets.append(
    .target(
        name: "Downloader",
        dependencies: [
            "DI",
            "DateProvider",
            "PathLib",
            .product(name: "Alamofire", package: "Alamofire"),
        ],
        path: "Sources/Downloader"
    )
)
// MARK: Environment
targets.append(
    .target(
        name: "Environment",
        dependencies: [
            "CLTExtensions",
            "DI",
            "PathLib",
        ],
        path: "Sources/Environment"
    )
)
// MARK: FileSystem
targets.append(
    .target(
        name: "FileSystem",
        dependencies: [
            "CLTExtensions",
            "DI",
            "PathLib",
            "Types",
            .product(name: "Glob", package: "Glob"),
        ],
        path: "Sources/FileSystem"
    )
)
// MARK: FileSystemTestHelpers
targets.append(
    .target(
        name: "FileSystemTestHelpers",
        dependencies: [
            "FileSystem",
            "PathLib",
            "Types",
        ],
        path: "Tests/FileSystemTestHelpers"
    )
)
// MARK: FileSystemTests
targets.append(
    .testTarget(
        name: "FileSystemTests",
        dependencies: [
            "FileSystem",
            "PathLib",
            "TestHelpers",
            "Tmp",
            "TmpTestHelpers",
        ],
        path: "Tests/FileSystemTests"
    )
)
// MARK: Graphite
targets.append(
    .target(
        name: "Graphite",
        dependencies: [
            "MetricsUtils",
            "SocketModels",
            .product(name: "Socket", package: "Socket"),
        ],
        path: "Sources/Graphite"
    )
)
// MARK: GraphiteTestHelpers
targets.append(
    .target(
        name: "GraphiteTestHelpers",
        dependencies: [
            "Graphite",
        ],
        path: "Tests/GraphiteTestHelpers"
    )
)
// MARK: GraphiteTests
targets.append(
    .testTarget(
        name: "GraphiteTests",
        dependencies: [
            "AtomicModels",
            "Graphite",
            "SocketModels",
            "TestHelpers",
            .product(name: "Socket", package: "Socket"),
        ],
        path: "Tests/GraphiteTests"
    )
)
// MARK: JSONStream
targets.append(
    .target(
        name: "JSONStream",
        dependencies: [
            "AtomicModels",
        ],
        path: "Sources/JSONStream",
        exclude: [
            "README.md",
            "target.json",
        ]
    )
)
// MARK: JSONStreamTests
targets.append(
    .testTarget(
        name: "JSONStreamTests",
        dependencies: [
            "JSONStream",
            "TestHelpers",
        ],
        path: "Tests/JSONStreamTests"
    )
)
// MARK: Kibana
targets.append(
    .target(
        name: "Kibana",
        dependencies: [
            "CLTExtensions",
            "CLTTypes",
            "DateProvider",
            "SocketModels",
        ],
        path: "Sources/Kibana"
    )
)
// MARK: KibanaModels
targets.append(
    .target(
        name: "KibanaModels",
        dependencies: [
            "CLTTypes",
        ],
        path: "Sources/KibanaModels"
    )
)
// MARK: KibanaTestHelpers
targets.append(
    .target(
        name: "KibanaTestHelpers",
        dependencies: [
            "Kibana",
        ],
        path: "Tests/KibanaTestHelpers"
    )
)
// MARK: KibanaTests
targets.append(
    .testTarget(
        name: "KibanaTests",
        dependencies: [
            "DateProviderTestHelpers",
            "Kibana",
            "SocketModels",
            "TestHelpers",
            "URLSessionTestHelpers",
        ],
        path: "Tests/KibanaTests"
    )
)
// MARK: LaunchdUtils
targets.append(
    .target(
        name: "LaunchdUtils",
        dependencies: [
        ],
        path: "Sources/LaunchdUtils"
    )
)
// MARK: LaunchdUtilsTests
targets.append(
    .testTarget(
        name: "LaunchdUtilsTests",
        dependencies: [
            "LaunchdUtils",
        ],
        path: "Tests/LaunchdUtilsTests"
    )
)
// MARK: MetricsRecording
targets.append(
    .target(
        name: "MetricsRecording",
        dependencies: [
            "DateProvider",
            "Graphite",
            "Statsd",
        ],
        path: "Sources/MetricsRecording"
    )
)
// MARK: MetricsTestHelpers
targets.append(
    .target(
        name: "MetricsTestHelpers",
        dependencies: [
            "Graphite",
            "MetricsRecording",
            "Statsd",
        ],
        path: "Tests/MetricsTestHelpers"
    )
)
// MARK: MetricsTests
targets.append(
    .testTarget(
        name: "MetricsTests",
        dependencies: [
            "DateProviderTestHelpers",
            "Graphite",
            "MetricsRecording",
            "MetricsTestHelpers",
            "Statsd",
            "TestHelpers",
        ],
        path: "Tests/MetricsTests"
    )
)
// MARK: MetricsUtils
targets.append(
    .target(
        name: "MetricsUtils",
        dependencies: [
        ],
        path: "Sources/MetricsUtils"
    )
)
// MARK: MutualTLS
targets.append(
    .target(
        name: "MutualTLS",
        dependencies: [
            "DI",
            "Environment",
            "PathLib",
            "ProcessController",
        ],
        path: "Sources/MutualTLS"
    )
)
// MARK: PathLib
targets.append(
    .target(
        name: "PathLib",
        dependencies: [
        ],
        path: "Sources/PathLib"
    )
)
// MARK: PathLibTests
targets.append(
    .testTarget(
        name: "PathLibTests",
        dependencies: [
            "PathLib",
            "TestHelpers",
        ],
        path: "Tests/PathLibTests"
    )
)
// MARK: PlistLib
targets.append(
    .target(
        name: "PlistLib",
        dependencies: [
            "DI",
            "FileSystem",
            "PathLib",
        ],
        path: "Sources/PlistLib",
        exclude: [
            "README.md",
            "target.json",
        ]
    )
)
// MARK: PlistLibTests
targets.append(
    .testTarget(
        name: "PlistLibTests",
        dependencies: [
            "PlistLib",
            "TestHelpers",
        ],
        path: "Tests/PlistLibTests"
    )
)
// MARK: ProcessController
targets.append(
    .target(
        name: "ProcessController",
        dependencies: [
            "AtomicModels",
            "DI",
            "DateProvider",
            "Environment",
            "FileSystem",
            "PathLib",
            "SignalHandling",
            "Timer",
        ],
        path: "Sources/ProcessController"
    )
)
// MARK: ProcessControllerTestHelpers
targets.append(
    .target(
        name: "ProcessControllerTestHelpers",
        dependencies: [
            "ProcessController",
            "SynchronousWaiter",
            "Tmp",
        ],
        path: "Tests/ProcessControllerTestHelpers"
    )
)
// MARK: ProcessControllerTests
targets.append(
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
    )
)
// MARK: RepoRoot
targets.append(
    .target(
        name: "RepoRoot",
        dependencies: [
            "CLTExtensions",
            "DI",
            "Environment",
            "FileSystem",
            "PathLib",
            "ProcessController",
        ],
        path: "Sources/RepoRoot"
    )
)
// MARK: RepoRootTests
targets.append(
    .testTarget(
        name: "RepoRootTests",
        dependencies: [
            "FileSystem",
            "FileSystemTestHelpers",
            "PathLib",
            "RepoRoot",
            "TestHelpers",
        ],
        path: "Tests/RepoRootTests"
    )
)
// MARK: SignalHandling
targets.append(
    .target(
        name: "SignalHandling",
        dependencies: [
            "Types",
            .product(name: "Signals", package: "Signals"),
        ],
        path: "Sources/SignalHandling"
    )
)
// MARK: SignalHandlingTests
targets.append(
    .testTarget(
        name: "SignalHandlingTests",
        dependencies: [
            "SignalHandling",
            .product(name: "Signals", package: "Signals"),
        ],
        path: "Tests/SignalHandlingTests"
    )
)
// MARK: SocketModels
targets.append(
    .target(
        name: "SocketModels",
        dependencies: [
            "Types",
        ],
        path: "Sources/SocketModels"
    )
)
// MARK: Statsd
targets.append(
    .target(
        name: "Statsd",
        dependencies: [
            "AtomicModels",
            "MetricsUtils",
            "SocketModels",
            .product(name: "Socket", package: "Socket"),
        ],
        path: "Sources/Statsd"
    )
)
// MARK: StatsdTests
targets.append(
    .testTarget(
        name: "StatsdTests",
        dependencies: [
            "MetricsRecording",
            "SocketModels",
            "Statsd",
            "TestHelpers",
            .product(name: "Socket", package: "Socket"),
        ],
        path: "Tests/StatsdTests"
    )
)
// MARK: SynchronousWaiter
targets.append(
    .target(
        name: "SynchronousWaiter",
        dependencies: [
            "AtomicModels",
        ],
        path: "Sources/SynchronousWaiter"
    )
)
// MARK: SynchronousWaiterTests
targets.append(
    .testTarget(
        name: "SynchronousWaiterTests",
        dependencies: [
            "SynchronousWaiter",
            "TestHelpers",
        ],
        path: "Tests/SynchronousWaiterTests"
    )
)
// MARK: TeamcityMessaging
targets.append(
    .target(
        name: "TeamcityMessaging",
        dependencies: [
            "CLTExtensions",
            "DI",
        ],
        path: "Sources/TeamcityMessaging"
    )
)
// MARK: TemporaryStuffTests
targets.append(
    .testTarget(
        name: "TemporaryStuffTests",
        dependencies: [
            "PathLib",
            "TestHelpers",
            "Tmp",
        ],
        path: "Tests/TemporaryStuffTests"
    )
)
// MARK: TestHelpers
targets.append(
    .target(
        name: "TestHelpers",
        dependencies: [
            "AtomicModels",
            "CLTExtensions",
            "PathLib",
        ],
        path: "Tests/TestHelpers",
        exclude: [
            "README.md",
            "target.json",
        ]
    )
)
// MARK: Timer
targets.append(
    .target(
        name: "Timer",
        dependencies: [
        ],
        path: "Sources/Timer"
    )
)
// MARK: Tmp
targets.append(
    .target(
        name: "Tmp",
        dependencies: [
            "CLTExtensions",
            "PathLib",
        ],
        path: "Sources/Tmp"
    )
)
// MARK: TmpTestHelpers
targets.append(
    .target(
        name: "TmpTestHelpers",
        dependencies: [
            "TestHelpers",
            "Tmp",
        ],
        path: "Tests/TmpTestHelpers"
    )
)
// MARK: Types
targets.append(
    .target(
        name: "Types",
        dependencies: [
        ],
        path: "Sources/Types"
    )
)
// MARK: TypesTests
targets.append(
    .testTarget(
        name: "TypesTests",
        dependencies: [
            "Types",
        ],
        path: "Tests/TypesTests"
    )
)
// MARK: URLSessionTestHelpers
targets.append(
    .target(
        name: "URLSessionTestHelpers",
        dependencies: [
        ],
        path: "Tests/URLSessionTestHelpers"
    )
)
// MARK: UserDefaultsLib
targets.append(
    .target(
        name: "UserDefaultsLib",
        dependencies: [
            "PlistLib",
        ],
        path: "Sources/UserDefaultsLib",
        exclude: [
            "README.md",
            "target.json",
        ]
    )
)
// MARK: UserDefaultsLibTestHelpers
targets.append(
    .target(
        name: "UserDefaultsLibTestHelpers",
        dependencies: [
            "PlistLib",
            "UserDefaultsLib",
        ],
        path: "Tests/UserDefaultsLibTestHelpers"
    )
)
// MARK: Waitable
targets.append(
    .target(
        name: "Waitable",
        dependencies: [
        ],
        path: "Sources/Waitable"
    )
)
// MARK: WaitableTests
targets.append(
    .testTarget(
        name: "WaitableTests",
        dependencies: [
            "Waitable",
        ],
        path: "Tests/WaitableTests"
    )
)
// MARK: XcodeLocator
targets.append(
    .target(
        name: "XcodeLocator",
        dependencies: [
            "CLTExtensions",
            "DI",
            "FileSystem",
            "PathLib",
            "PlistLib",
            "XcodeLocatorModels",
        ],
        path: "Sources/XcodeLocator"
    )
)
// MARK: XcodeLocatorModels
targets.append(
    .target(
        name: "XcodeLocatorModels",
        dependencies: [
            "PathLib",
        ],
        path: "Sources/XcodeLocatorModels"
    )
)
// MARK: XcodeLocatorTests
targets.append(
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
    )
)

let package = Package(
    name: "CommandLineToolkit",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        .library(name: "AtomicModels", targets: ["AtomicModels"]),
        .library(name: "CLTCollections", targets: ["CLTCollections"]),
        .library(name: "CLTExtensions", targets: ["CLTExtensions"]),
        .library(name: "CLTLogging", targets: ["CLTLogging"]),
        .library(name: "CLTLoggingModels", targets: ["CLTLoggingModels"]),
        .library(name: "CLTLoggingTestHelpers", targets: ["CLTLoggingTestHelpers"]),
        .library(name: "CLTTypes", targets: ["CLTTypes"]),
        .library(name: "Cloc", targets: ["Cloc"]),
        .library(name: "CommandSupport", targets: ["CommandSupport"]),
        .library(name: "Concurrency", targets: ["Concurrency"]),
        .library(name: "Console", targets: ["Console"]),
        .library(name: "ConsoleTestHelpers", targets: ["ConsoleTestHelpers"]),
        .library(name: "DI", targets: ["DI"]),
        .library(name: "DateProvider", targets: ["DateProvider"]),
        .library(name: "DateProviderTestHelpers", targets: ["DateProviderTestHelpers"]),
        .library(name: "Downloader", targets: ["Downloader"]),
        .library(name: "Environment", targets: ["Environment"]),
        .library(name: "FileSystem", targets: ["FileSystem"]),
        .library(name: "FileSystemTestHelpers", targets: ["FileSystemTestHelpers"]),
        .library(name: "Graphite", targets: ["Graphite"]),
        .library(name: "GraphiteTestHelpers", targets: ["GraphiteTestHelpers"]),
        .library(name: "JSONStream", targets: ["JSONStream"]),
        .library(name: "Kibana", targets: ["Kibana"]),
        .library(name: "KibanaModels", targets: ["KibanaModels"]),
        .library(name: "KibanaTestHelpers", targets: ["KibanaTestHelpers"]),
        .library(name: "LaunchdUtils", targets: ["LaunchdUtils"]),
        .library(name: "MetricsRecording", targets: ["MetricsRecording"]),
        .library(name: "MetricsTestHelpers", targets: ["MetricsTestHelpers"]),
        .library(name: "MetricsUtils", targets: ["MetricsUtils"]),
        .library(name: "MutualTLS", targets: ["MutualTLS"]),
        .library(name: "PathLib", targets: ["PathLib"]),
        .library(name: "PlistLib", targets: ["PlistLib"]),
        .library(name: "ProcessController", targets: ["ProcessController"]),
        .library(name: "ProcessControllerTestHelpers", targets: ["ProcessControllerTestHelpers"]),
        .library(name: "RepoRoot", targets: ["RepoRoot"]),
        .library(name: "SignalHandling", targets: ["SignalHandling"]),
        .library(name: "SocketModels", targets: ["SocketModels"]),
        .library(name: "Statsd", targets: ["Statsd"]),
        .library(name: "SynchronousWaiter", targets: ["SynchronousWaiter"]),
        .library(name: "TeamcityMessaging", targets: ["TeamcityMessaging"]),
        .library(name: "TestHelpers", targets: ["TestHelpers"]),
        .library(name: "Timer", targets: ["Timer"]),
        .library(name: "Tmp", targets: ["Tmp"]),
        .library(name: "TmpTestHelpers", targets: ["TmpTestHelpers"]),
        .library(name: "Types", targets: ["Types"]),
        .library(name: "URLSessionTestHelpers", targets: ["URLSessionTestHelpers"]),
        .library(name: "UserDefaultsLib", targets: ["UserDefaultsLib"]),
        .library(name: "UserDefaultsLibTestHelpers", targets: ["UserDefaultsLibTestHelpers"]),
        .library(name: "Waitable", targets: ["Waitable"]),
        .library(name: "XcodeLocator", targets: ["XcodeLocator"]),
        .library(name: "XcodeLocatorModels", targets: ["XcodeLocatorModels"]),
    ],
    dependencies: [
        .package(name: "Alamofire", url: "https://github.com/Alamofire/Alamofire", .exact("5.5.0")),
        .package(name: "Glob", url: "https://github.com/Bouke/Glob", .exact("1.0.5")),
        .package(name: "Signals", url: "https://github.com/IBM-Swift/BlueSignals.git", .exact("1.0.21")),
        .package(name: "Socket", url: "https://github.com/Kitura/BlueSocket.git", .exact("1.0.52")),
        .package(name: "Yams", url: "https://github.com/jpsim/Yams.git", from: "4.0.6"),
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser", from: "1.1.3"),
        .package(name: "swift-log", url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: targets
)

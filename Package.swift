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
            "CLTExtensions",
        ],
        path: "Tests/CLTExtensionsTests"
    )
)
// MARK: CommandSupport
targets.append(
    .target(
        name: "CommandSupport",
        dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            "DI",
            "PathLib",
        ],
        path: "Sources/CommandSupport"
    )
)
// MARK: DI
targets.append(
    .target(
        name: "DI",
        dependencies: [
        ],
        path: "Sources/DI"
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
            .product(name: "Glob", package: "Glob"),
            "PathLib",
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
            "GraphiteClient",
            "IO",
            "MetricsUtils",
            "SocketModels",
        ],
        path: "Sources/Graphite"
    )
)
// MARK: GraphiteClient
targets.append(
    .target(
        name: "GraphiteClient",
        dependencies: [
            "AtomicModels",
            "IO",
        ],
        path: "Sources/GraphiteClient"
    )
)
// MARK: GraphiteClientTests
targets.append(
    .testTarget(
        name: "GraphiteClientTests",
        dependencies: [
            "AtomicModels",
            "GraphiteClient",
            "IO",
        ],
        path: "Tests/GraphiteClientTests"
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
// MARK: IO
targets.append(
    .target(
        name: "IO",
        dependencies: [
            "AtomicModels",
        ],
        path: "Sources/IO"
    )
)
// MARK: IOTests
targets.append(
    .testTarget(
        name: "IOTests",
        dependencies: [
            "IO",
            "TestHelpers",
        ],
        path: "Tests/IOTests"
    )
)
// MARK: JSONStream
targets.append(
    .target(
        name: "JSONStream",
        dependencies: [
            "AtomicModels",
        ],
        path: "Sources/JSONStream"
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
            "IO",
        ],
        path: "Sources/MetricsUtils"
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
        ],
        path: "Sources/PlistLib"
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
            .product(name: "Signals", package: "Signals"),
            "Types",
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
            "IO",
            "MetricsUtils",
            .product(name: "Socket", package: "Socket"),
            "SocketModels",
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
            .product(name: "Socket", package: "Socket"),
            "SocketModels",
            "Statsd",
            "TestHelpers",
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
        ],
        path: "Tests/TestHelpers"
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
// MARK: UserDefaultsLib
targets.append(
    .target(
        name: "UserDefaultsLib",
        dependencies: [
            "PlistLib",
        ],
        path: "Sources/UserDefaultsLib"
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
        .library(name: "CommandSupport", targets: ["CommandSupport"]),
        .library(name: "DI", targets: ["DI"]),
        .library(name: "DateProvider", targets: ["DateProvider"]),
        .library(name: "DateProviderTestHelpers", targets: ["DateProviderTestHelpers"]),
        .library(name: "Environment", targets: ["Environment"]),
        .library(name: "FileSystem", targets: ["FileSystem"]),
        .library(name: "FileSystemTestHelpers", targets: ["FileSystemTestHelpers"]),
        .library(name: "Graphite", targets: ["Graphite"]),
        .library(name: "GraphiteClient", targets: ["GraphiteClient"]),
        .library(name: "GraphiteTestHelpers", targets: ["GraphiteTestHelpers"]),
        .library(name: "IO", targets: ["IO"]),
        .library(name: "JSONStream", targets: ["JSONStream"]),
        .library(name: "LaunchdUtils", targets: ["LaunchdUtils"]),
        .library(name: "MetricsRecording", targets: ["MetricsRecording"]),
        .library(name: "MetricsTestHelpers", targets: ["MetricsTestHelpers"]),
        .library(name: "MetricsUtils", targets: ["MetricsUtils"]),
        .library(name: "PathLib", targets: ["PathLib"]),
        .library(name: "PlistLib", targets: ["PlistLib"]),
        .library(name: "ProcessController", targets: ["ProcessController"]),
        .library(name: "ProcessControllerTestHelpers", targets: ["ProcessControllerTestHelpers"]),
        .library(name: "RepoRoot", targets: ["RepoRoot"]),
        .library(name: "SignalHandling", targets: ["SignalHandling"]),
        .library(name: "SocketModels", targets: ["SocketModels"]),
        .library(name: "Statsd", targets: ["Statsd"]),
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
        .package(name: "Socket", url: "https://github.com/Kitura/BlueSocket.git", .exact("1.0.52")),
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser", from: "1.1.3"),
    ],
    targets: targets
)

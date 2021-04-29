import Foundation

public final class LaunchdJob {
    public enum InetdCompatibility {
        /** Simulation is disabled */
        case disabled
        /** "wait" option of inetd: the listening socket is passed via the stdio file descriptors */
        case enabledWithWait
        /** "nowait" option of inetd: accept is called on behalf of the job, and the result is passed via the stdio descriptors */
        case enabledWithoutWait
    }
    
    public enum LoadSessionType: String {
        /** Has access to all GUI services; much like a login item. This is a default value. */
        case aqua = "Aqua"
        /** Runs only in non-GUI login sessions (most notably, SSH login sessions) */
        case standardIO = "StandardIO"
        /** Runs in a context that's the parent of all contexts for a given user */
        case background = "Background"
        /** Runs in the loginwindow context */
        case loginWindow = "LoginWindow"
    }
    
    /** Unique reverse DNS name of the job */
    public let label: String
    /** This optional key specifies the user to run the job as. This key is only applicable for services that are loaded
     into the privileged system domain. */
    public let username: String?
    /** This optional key specifies the group to run the job as. This key is only applicable for services that are
     loaded into the privileged system domain. If UserName is set and GroupName is not, then the group will be set to
     the primary group of the user. */
    public let groupname: String?
    /** What to invoke: ['ls', '-la', '/Applications'] */
    public let programArguments: [String]
    /** Environment of the program being executed */
    public let environmentVariables: [String: String]?
    /** Working directory */
    public let workingDirectory: String?
    /** Should the job be started by launchd when it loads it */
    public let runAtLoad: Bool?
    /** Indicates if job is enabled or disabled. You still can force load it. */
    public let disabled: Bool?
    /** Where to redirect stdout */
    public let standardOutRedirectionPath: String?
    /** Where to redirect stderr */
    public let standardErrorRedirectionPath: String?
    /** All exposed sockets. Key is your id of the socket, e.g. "sock1". */
    public let sockets: [String: [LaunchdSocket]]?
    /** Simulate inetd-like operation */
    public let inetdCompatibility: InetdCompatibility?
    /** Specifies a particular session type to run your agent in. Default is Aqua. */
    public let sessionType: LoadSessionType?

    public init(
        label: String,
        username: String?,
        groupname: String?,
        programArguments: [String],
        environmentVariables: [String: String],
        workingDirectory: String,
        runAtLoad: Bool,
        disabled: Bool,
        standardOutPath: String?,
        standardErrorPath: String?,
        sockets: [String: [LaunchdSocket]]?,
        inetdCompatibility: InetdCompatibility?,
        sessionType: LoadSessionType
    ) {
        self.label = label
        self.username = username
        self.groupname = groupname
        self.programArguments = programArguments
        self.environmentVariables = environmentVariables
        self.workingDirectory = workingDirectory
        self.runAtLoad = runAtLoad
        self.disabled = disabled
        self.standardOutRedirectionPath = standardOutPath
        self.standardErrorRedirectionPath = standardErrorPath
        self.sockets = sockets
        self.inetdCompatibility = inetdCompatibility
        self.sessionType = sessionType
    }
}

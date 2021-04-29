import Foundation

public final class LaunchdPlist {
    private let job: LaunchdJob

    public init(job: LaunchdJob) {
        self.job = job
    }

    public func createPlistData() throws -> Data {
        let contents = createPlistDict()
        return try PropertyListSerialization.data(fromPropertyList: contents, format: .xml, options: 0)
    }
    
    private func createPlistDict() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary["Label"] = job.label
        dictionary["ProgramArguments"] = job.programArguments
        if let username = job.username {
            dictionary["UserName"] = username
        }
        if let groupname = job.groupname {
            dictionary["GroupName"] = groupname
        }
        if let environmentVariables = job.environmentVariables {
            dictionary["EnvironmentVariables"] = environmentVariables
        }
        if let workingDirectory = job.workingDirectory {
            dictionary["WorkingDirectory"] = workingDirectory
        }
        if let runAtLoad = job.runAtLoad {
            dictionary["RunAtLoad"] = runAtLoad
        }
        if let disabled = job.disabled {
            dictionary["Disabled"] = disabled
        }
        
        if let standardOutRedirectionPath = job.standardOutRedirectionPath {
            dictionary["StandardOutPath"] = standardOutRedirectionPath
        }
        
        if let standardErrorRedirectionPath = job.standardErrorRedirectionPath {
            dictionary["StandardErrorPath"] = standardErrorRedirectionPath
        }
        
        if let jobSockets = job.sockets {
            dictionary["Sockets"] = jobSockets.mapValues { (values: [LaunchdSocket])  in
                values.map { (value: LaunchdSocket) -> NSMutableDictionary in
                    let socket = NSMutableDictionary()
                    if let socketType = value.socketType {
                        socket["SockType"] = socketType.rawValue
                    }
                    if let socketPassive = value.socketPassive {
                        socket["SockPassive"] = (socketPassive == .listen)
                    }
                    if let socketNodeName = value.socketNodeName {
                        socket["SockNodeName"] = socketNodeName
                    }
                    if let socketServiceName = value.socketServiceName {
                        switch socketServiceName {
                        case .name(let name):
                            socket["SockServiceName"] = name
                        case .port(let port):
                            socket["SockServiceName"] = port
                        }
                    }
                    if let socketFamily = value.socketFamily {
                        socket["SockFamily"] = socketFamily.rawValue
                    }
                    if let socketPathName = value.socketPathName {
                        socket["SockPathName"] = socketPathName
                    }
                    if let socketPathMode = value.socketPathMode {
                        socket["SockPathMode"] = socketPathMode
                    }
                    return socket
                }
            }
        }
        
        if let inetdCompatibility = job.inetdCompatibility, inetdCompatibility != .disabled {
            let waitEnabled = inetdCompatibility == .enabledWithWait
            dictionary["inetdCompatibility"] = ["Wait": waitEnabled]
        }
        if let sessionType = job.sessionType {
            dictionary["LimitLoadToSessionType"] = sessionType.rawValue
        }
        return dictionary
    }
}

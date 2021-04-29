import Foundation

public struct LaunchdSocket {
    public enum SocketType: String {
        /** TCP */
        case stream
        /** UDP */
        case dgram
    }
    
    public enum SocketPassivity {
        /** Socket will listen for the new connections */
        case listen
        /** Socket will connect */
        case connect
    }
    
    public enum SockServiceName {
        /** "ssh", "http", etc. */
        case name(String)
        /** 443, 8888, etc. */
        case port(Int)
    }
    
    public enum SocketFamily: String {
        case ipv4 = "IPv4"
        case ipv6 = "IPv6"
        case ipv4v6 = "IPv4v6"
        case unix = "Unix"
    }
    
    public let socketType: SocketType?
    public let socketPassive: SocketPassivity?
    public let socketFamily: SocketFamily?
    public let socketNodeName: String?
    public let socketServiceName: SockServiceName?
    public let socketPathName: String?
    public let socketPathMode: Int?
    
    public init(
        socketType: SocketType? = nil,
        socketPassive: SocketPassivity? = nil,
        socketFamily: SocketFamily? = nil,
        socketNodeName: String? = nil,
        socketServiceName: SockServiceName? = nil,
        socketPathName: String? = nil,
        socketPathMode: Int? = nil
    ) {
        self.socketType = socketType
        self.socketPassive = socketPassive
        self.socketFamily = socketFamily
        self.socketNodeName = socketNodeName
        self.socketServiceName = socketServiceName
        self.socketPathName = socketPathName
        self.socketPathMode = socketPathMode
    }
}

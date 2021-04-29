import Foundation

public enum LaunchdSocketActivation {
    /// Read `man launch_activate_socket`.
    /// - Parameter name: The name of the socket entry in the service's Sockets dictionary.
    /// - Throws:`LaunchdSocketActivationError`
    /// - Returns: a set of file descriptors corresponding to a socket service that launchd(8) has created and advertised on behalf of the job
    public static func activateSocket(name: String) throws -> [Int32] {
        var ld_sockets = UnsafeMutablePointer<Int32>.allocate(capacity: 0)
        defer {
            ld_sockets.deallocate()
        }
        var count: size_t = 0
        
        let err = launch_activate_socket(name, &ld_sockets, &count)
        guard err == 0 else {
            throw LaunchdSocketActivationError.errorCode(err)
        }
        
        var fds = [Int32]()
        for i in 0 ..< count {
            fds.append(ld_sockets[i])
        }
        return fds
    }
}

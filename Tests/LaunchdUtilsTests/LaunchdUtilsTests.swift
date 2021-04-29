import Foundation
import XCTest
@testable import LaunchdUtils

class LaunchdUtilsTests: XCTestCase {
    func testGeneratingPlist() throws {
        let job = LaunchdJob(
            label: "com.example.test",
            username: "username",
            groupname: "groupname",
            programArguments: ["/bin", "arg1", "arg2"],
            environmentVariables: ["ENV": "val"],
            workingDirectory: "~/",
            runAtLoad: true,
            disabled: true,
            standardOutPath: nil,
            standardErrorPath: nil,
            sockets: [
                "sock1": [
                    LaunchdSocket(
                        socketType: .stream,
                        socketPassive: .listen,
                        socketFamily: .ipv4,
                        socketNodeName: "nodename",
                        socketServiceName: .port(4321),
                        socketPathName: "/path",
                        socketPathMode: 438
                    )
                ]
            ],
            inetdCompatibility: .enabledWithoutWait,
            sessionType: .background)
        let plist = LaunchdPlist(job: job)
        let contents = try plist.createPlistData()
        guard let string = String(data: contents, encoding: .utf8) else {
            XCTFail("Unable to convert plist data to string")
            return
        }
        let expectedString = """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Disabled</key>
    <true/>
    <key>EnvironmentVariables</key>
    <dict>
        <key>ENV</key>
        <string>val</string>
    </dict>
    <key>GroupName</key>
    <string>groupname</string>
    <key>Label</key>
    <string>com.example.test</string>
    <key>LimitLoadToSessionType</key>
    <string>Background</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin</string>
        <string>arg1</string>
        <string>arg2</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>Sockets</key>
    <dict>
        <key>sock1</key>
        <array>
            <dict>
                <key>SockFamily</key>
                <string>IPv4</string>
                <key>SockNodeName</key>
                <string>nodename</string>
                <key>SockPassive</key>
                <true/>
                <key>SockPathMode</key>
                <integer>438</integer>
                <key>SockPathName</key>
                <string>/path</string>
                <key>SockServiceName</key>
                <integer>4321</integer>
                <key>SockType</key>
                <string>stream</string>
            </dict>
        </array>
    </dict>
    <key>UserName</key>
    <string>username</string>
    <key>WorkingDirectory</key>
    <string>~/</string>
    <key>inetdCompatibility</key>
    <dict>
        <key>Wait</key>
        <false/>
    </dict>
</dict>
</plist>
"""
        XCTAssertEqual(
            string.components(separatedBy: .whitespacesAndNewlines).joined(),
            expectedString.components(separatedBy: .whitespacesAndNewlines).joined())
    }
}

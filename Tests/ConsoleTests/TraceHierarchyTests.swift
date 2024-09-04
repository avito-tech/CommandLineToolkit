import Foundation
import XCTest
import InlineSnapshotTesting
import Logging
@testable import Console

final class TraceHierarchyTests: XCTestCase {
    override func invokeTest() {
        withSnapshotTesting(record: .never) {
            super.invokeTest()
        }
    }
    
    func testTopLevelInProgressInfoTrace() {
        let component = TraceComponent.normal(level: .info)
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .default)) {
            """
            ╶ Test info trace, options: [] ⠋
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .trace)) {
            """
            ╶ Test info trace, options: [] ⠋
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .verbose)) {
            """
            ╶ Test info trace, options: [] ⠋
            """
        }
    }
    
    func testTopLevelInProgressDebugTrace() {
        let component = TraceComponent.normal(level: .debug)
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .default)) {
            """
            ╶ Test debug trace, options: [] ⠋
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .trace)) {
            """
            ╶ Test debug trace, options: [] ⠋
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .verbose)) {
            """
            ╶ Test debug trace, options: [] ⠋
            """
        }
    }
    
    func testTopLevelSuccessInfoTrace() {
        let component = TraceComponent.normal(level: .info, result: .success(()))
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .default)) {
            """
            ╶ Test info trace, options: [] ✔
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .trace)) {
            """
            ╶ Test info trace, options: [] ✔
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .verbose)) {
            """
            ╶ Test info trace, options: [] ✔
            """
        }
    }
    
    func testTopLevelSuccessDebugTrace() {
        let component = TraceComponent.normal(level: .debug, result: .success(()))
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .default)) {
            """
            ╶ Test debug trace, options: [] ✔
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .trace)) {
            """
            ╶ Test debug trace, options: [] ✔
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .verbose)) {
            """
            ╶ Test debug trace, options: [] ✔
            """
        }
    }
    
    func testTopLevelFailureDebugTrace() {
        let component = TraceComponent.normal(level: .debug, result: .failure("error"))
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .default)) {
            """
            ╶ Test debug trace, options: [] ✘
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .trace)) {
            """
            ╶ Test debug trace, options: [] ✘
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .verbose)) {
            """
            ╶ Test debug trace, options: [] ✘
            """
        }
    }
    
    func testTopLevelFailureInfoTrace() {
        let component = TraceComponent.normal(level: .info, result: .failure("error"))
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .default)) {
            """
            ╶ Test info trace, options: [] ✘
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .trace)) {
            """
            ╶ Test info trace, options: [] ✘
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .verbose)) {
            """
            ╶ Test info trace, options: [] ✘
            """
        }
    }
    
    func testExternalNormalNestedRunning() {
        let component = TraceComponent.normal(level: .info) {
            TraceComponent.normal(level: .info)
            TraceComponent.normal(level: .debug)
            
            TraceComponent.normal(level: .info) {
                TraceComponent.normal(level: .info)
                TraceComponent.normal(level: .debug)
            }
            
            TraceComponent.normal(level: .debug) {
                TraceComponent.normal(level: .info)
                TraceComponent.normal(level: .debug)
            }
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .verbose)) {
            """
            ╭ Test info trace, options: [] ⠋
            │ ╶ Test info trace, options: [] ⠋
            │ ╶ Test debug trace, options: [] ⠋
            │ ╭ Test info trace, options: [] ⠋
            │ │ ╶ Test info trace, options: [] ⠋
            │ │ ╶ Test debug trace, options: [] ⠋
            │ ╰
            │ ╭ Test debug trace, options: [] ⠋
            │ │ ╶ Test info trace, options: [] ⠋
            │ │ ╶ Test debug trace, options: [] ⠋
            │ ╰
            ╰
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .trace)) {
            """
            ╭ Test info trace, options: [] ⠋
            │ ╶ Test info trace, options: [] ⠋
            │ ╶ Test debug trace, options: [] ⠋
            │ ╭ Test info trace, options: [] ⠋
            │ │ ╶ Test info trace, options: [] ⠋
            │ │ ╶ Test debug trace, options: [] ⠋
            │ ╰
            │ ╭ Test debug trace, options: [] ⠋
            │ │ ╶ Test info trace, options: [] ⠋
            │ │ ╶ Test debug trace, options: [] ⠋
            │ ╰
            ╰
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .default)) {
            """
            ╭ Test info trace, options: [] ⠋
            │ ╶ Test info trace, options: [] ⠋
            │ ╭ Test info trace, options: [] ⠋
            │ │ ╶ Test info trace, options: [] ⠋
            │ ╰
            │ ╭ Test debug trace, options: [] ⠋
            │ │ ╶ Test info trace, options: [] ⠋
            │ ╰
            ╰
            """
        }
    }
    
    func testExternalVerboseNestedSuccess() {
        let component = TraceComponent.normal(level: .info) {
            TraceComponent.normal(level: .info, result: .success(()))
            TraceComponent.normal(level: .debug, result: .success(()))
            
            TraceComponent.normal(level: .info) {
                TraceComponent.normal(level: .info, result: .success(()))
                TraceComponent.normal(level: .debug, result: .success(()))
            }
            
            TraceComponent.normal(level: .debug) {
                TraceComponent.normal(level: .info, result: .success(()))
                TraceComponent.normal(level: .debug, result: .success(()))
            }
            
            TraceComponent.normal(level: .debug) {
                TraceComponent.normal(level: .debug, result: .success(()))
            }
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .verbose)) {
            """
            ╭ Test info trace, options: [] ⠋
            │ ╶ Test info trace, options: [] ✔
            │ ╶ Test debug trace, options: [] ✔
            │ ╭ Test info trace, options: [] ⠋
            │ │ ╶ Test info trace, options: [] ✔
            │ │ ╶ Test debug trace, options: [] ✔
            │ ╰
            │ ╭ Test debug trace, options: [] ⠋
            │ │ ╶ Test info trace, options: [] ✔
            │ │ ╶ Test debug trace, options: [] ✔
            │ ╰
            │ ╭ Test debug trace, options: [] ⠋
            │ │ ╶ Test debug trace, options: [] ✔
            │ ╰
            ╰
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .trace)) {
            """
            ╭ Test info trace, options: [] ⠋
            │ ╶ Test info trace, options: [] ✔
            │ ╶ Test debug trace, options: [] ✔
            │ ╭ Test info trace, options: [] ⠋
            │ │ ╶ Test info trace, options: [] ✔
            │ │ ╶ Test debug trace, options: [] ✔
            │ ╰
            │ ╭ Test debug trace, options: [] ⠋
            │ │ ╶ Test info trace, options: [] ✔
            │ │ ╶ Test debug trace, options: [] ✔
            │ ╰
            │ ╭ Test debug trace, options: [] ⠋
            │ │ ╶ Test debug trace, options: [] ✔
            │ ╰
            ╰
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .default)) {
            """
            ╭ Test info trace, options: [] ⠋
            │ ╶ Test info trace, options: [] ✔
            │ ╭ Test info trace, options: [] ⠋
            │ │ ╶ Test info trace, options: [] ✔
            │ ╰
            │ ╭ Test debug trace, options: [] ⠋
            │ │ ╶ Test info trace, options: [] ✔
            │ ╰
            ╰
            """
        }
    }
    
    func testExternalCollapseNestedRunning() {
        let component = TraceComponent.collapse(level: .info) {
            TraceComponent.normal(level: .info)
            TraceComponent.normal(level: .debug)
            
            TraceComponent.collapse(level: .info) {
                TraceComponent.normal(level: .info)
                TraceComponent.normal(level: .debug)
            }
            
            TraceComponent.collapse(level: .debug) {
                TraceComponent.normal(level: .info)
                TraceComponent.normal(level: .debug)
            }
            
            TraceComponent.collapse(level: .debug) {
                TraceComponent.normal(level: .debug)
            }
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .verbose)) {
            """
            ╭ Test info trace, options: [collapseFinished] ⠋
            │ ╶ Test info trace, options: [] ⠋
            │ ╶ Test debug trace, options: [] ⠋
            │ ╭ Test info trace, options: [collapseFinished] ⠋
            │ │ ╶ Test info trace, options: [] ⠋
            │ │ ╶ Test debug trace, options: [] ⠋
            │ ╰
            │ ╭ Test debug trace, options: [collapseFinished] ⠋
            │ │ ╶ Test info trace, options: [] ⠋
            │ │ ╶ Test debug trace, options: [] ⠋
            │ ╰
            │ ╭ Test debug trace, options: [collapseFinished] ⠋
            │ │ ╶ Test debug trace, options: [] ⠋
            │ ╰
            ╰
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .trace)) {
            """
            ╭ Test info trace, options: [collapseFinished] ⠋
            │ ╶ Test info trace, options: [] ⠋
            │ ╶ Test debug trace, options: [] ⠋
            │ ╭ Test info trace, options: [collapseFinished] ⠋
            │ │ ╶ Test info trace, options: [] ⠋
            │ │ ╶ Test debug trace, options: [] ⠋
            │ ╰
            │ ╭ Test debug trace, options: [collapseFinished] ⠋
            │ │ ╶ Test info trace, options: [] ⠋
            │ │ ╶ Test debug trace, options: [] ⠋
            │ ╰
            │ ╭ Test debug trace, options: [collapseFinished] ⠋
            │ │ ╶ Test debug trace, options: [] ⠋
            │ ╰
            ╰
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .default)) {
            """
            ╭ Test info trace, options: [collapseFinished] ⠋
            │ ╶ Test info trace, options: [] ⠋
            │ ╭ Test info trace, options: [collapseFinished] ⠋
            │ │ ╶ Test info trace, options: [] ⠋
            │ ╰
            │ ╭ Test debug trace, options: [collapseFinished] ⠋
            │ │ ╶ Test info trace, options: [] ⠋
            │ ╰
            ╰
            """
        }
    }
    
    func testExternalCollapseNestedSuccess() {
        let component = TraceComponent.collapse(level: .info) {
            TraceComponent.normal(level: .info, result: .success(()))
            TraceComponent.normal(level: .trace, result: .success(()))
            
            TraceComponent.collapse(level: .info) {
                TraceComponent.normal(level: .info, result: .success(()))
                TraceComponent.normal(level: .trace, result: .success(()))
            }
            
            TraceComponent.collapse(level: .trace) {
                TraceComponent.normal(level: .info, result: .success(()))
                TraceComponent.normal(level: .trace, result: .success(()))
            }
            
            TraceComponent.collapse(level: .trace) {
                TraceComponent.normal(level: .trace, result: .success(()))
            }
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .verbose)) {
            """
            ╭ Test info trace, options: [collapseFinished] ⠋
            │ ╶ Test info trace, options: [] ✔
            │ ╶ Test trace trace, options: [] ✔
            │ ╭ Test info trace, options: [collapseFinished] ⠋
            │ │ ╶ Test info trace, options: [] ✔
            │ │ ╶ Test trace trace, options: [] ✔
            │ ╰
            │ ╭ Test trace trace, options: [collapseFinished] ⠋
            │ │ ╶ Test info trace, options: [] ✔
            │ │ ╶ Test trace trace, options: [] ✔
            │ ╰
            │ ╭ Test trace trace, options: [collapseFinished] ⠋
            │ │ ╶ Test trace trace, options: [] ✔
            │ ╰
            ╰
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .trace)) {
            """
            ╭ Test info trace, options: [collapseFinished] ⠋
            │ ╶ Test info trace, options: [collapseFinished] ⠋
            │ ╭ Test trace trace, options: [collapseFinished] ⠋
            │ │ ╶ Test info trace, options: [] ✔
            │ ╰
            │ ╶ Test trace trace, options: [collapseFinished] ⠋
            ╰
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .default)) {
            """
            ╭ Test info trace, options: [collapseFinished] ⠋
            │ ╶ Test info trace, options: [collapseFinished] ⠋
            │ ╭ Test trace trace, options: [collapseFinished] ⠋
            │ │ ╶ Test info trace, options: [] ✔
            │ ╰
            ╰
            """
        }
    }
    
    func testExternalCollapseNestedFailure() {
        let component = TraceComponent.collapse(level: .info) {
            TraceComponent.normal(level: .info, result: .failure("error"))
            TraceComponent.normal(level: .debug, result: .failure("error"))
            
            TraceComponent.collapse(level: .info) {
                TraceComponent.normal(level: .info, result: .failure("error"))
                TraceComponent.normal(level: .debug, result: .failure("error"))
            }
            
            TraceComponent.collapse(level: .debug) {
                TraceComponent.normal(level: .info, result: .failure("error"))
                TraceComponent.normal(level: .debug, result: .failure("error"))
            }
            
            TraceComponent.collapse(level: .debug) {
                TraceComponent.normal(level: .debug, result: .failure("error"))
            }
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .verbose)) {
            """
            ╭ Test info trace, options: [collapseFinished] ⠋
            │ ╶ Test info trace, options: [] ✘
            │ ╶ Test debug trace, options: [] ✘
            │ ╭ Test info trace, options: [collapseFinished] ⠋
            │ │ ╶ Test info trace, options: [] ✘
            │ │ ╶ Test debug trace, options: [] ✘
            │ ╰
            │ ╭ Test debug trace, options: [collapseFinished] ⠋
            │ │ ╶ Test info trace, options: [] ✘
            │ │ ╶ Test debug trace, options: [] ✘
            │ ╰
            │ ╭ Test debug trace, options: [collapseFinished] ⠋
            │ │ ╶ Test debug trace, options: [] ✘
            │ ╰
            ╰
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .trace)) {
            """
            ╭ Test info trace, options: [collapseFinished] ⠋
            │ ╶ Test info trace, options: [] ✘
            │ ╶ Test debug trace, options: [] ✘
            │ ╭ Test info trace, options: [collapseFinished] ⠋
            │ │ ╶ Test info trace, options: [] ✘
            │ │ ╶ Test debug trace, options: [] ✘
            │ ╰
            │ ╭ Test debug trace, options: [collapseFinished] ⠋
            │ │ ╶ Test info trace, options: [] ✘
            │ │ ╶ Test debug trace, options: [] ✘
            │ ╰
            │ ╭ Test debug trace, options: [collapseFinished] ⠋
            │ │ ╶ Test debug trace, options: [] ✘
            │ ╰
            ╰
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .default)) {
            """
            ╭ Test info trace, options: [collapseFinished] ⠋
            │ ╶ Test info trace, options: [] ✘
            │ ╶ Test debug trace, options: [] ✘
            │ ╭ Test info trace, options: [collapseFinished] ⠋
            │ │ ╶ Test info trace, options: [] ✘
            │ │ ╶ Test debug trace, options: [] ✘
            │ ╰
            │ ╭ Test debug trace, options: [collapseFinished] ⠋
            │ │ ╶ Test info trace, options: [] ✘
            │ │ ╶ Test debug trace, options: [] ✘
            │ ╰
            │ ╭ Test debug trace, options: [collapseFinished] ⠋
            │ │ ╶ Test debug trace, options: [] ✘
            │ ╰
            ╰
            """
        }
    }
    
    func testExternalCollapseNestedFailureShouldUnfoldOnlyErrorBranch() {
        let component = TraceComponent.collapse(level: .info, result: .failure("error")) {
            TraceComponent.collapse(level: .info, result: .success(())) {
                TraceComponent.normal(level: .info, result: .success(()))
            }
            TraceComponent.collapse(level: .trace, result: .success(())) {
                TraceComponent.normal(level: .trace, result: .success(()))
            }
            
            TraceComponent.collapse(level: .trace, result: .failure("error")) {
                TraceComponent.collapse(level: .trace, result: .success(())) {
                    LogComponent(state: .init(level: .trace, message: "Trace message", metadata: [:], source: "", file: "", function: "", line: 0))
                    LogComponent(state: .init(level: .info, message: "Info message", metadata: [:], source: "", file: "", function: "", line: 0))
                    LogStreamComponent(state: .init(level: .trace, name: "Trace process", lines: ["message"], result: .failure(.init(statusCode: 1))))
                    LogStreamComponent(state: .init(level: .info, name: "Info process", lines: ["message"]))
                }
                TraceComponent.collapse(level: .trace, result: .failure("error")) {
                    LogComponent(state: .init(level: .trace, message: "Trace message", metadata: [:], source: "", file: "", function: "", line: 0))
                    LogComponent(state: .init(level: .info, message: "Info message", metadata: [:], source: "", file: "", function: "", line: 0))
                    LogStreamComponent(state: .init(level: .trace, name: "Trace process", lines: ["message"], result: .failure(.init(statusCode: 1))))
                    LogStreamComponent(state: .init(level: .info, name: "Info process", lines: ["message"]))
                }
            }
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .verbose)) {
            """
            ╭ Test info trace, options: [collapseFinished] ✘
            │ ╭ Test info trace, options: [collapseFinished] ✔
            │ │ ╶ Test info trace, options: [] ✔
            │ ╰
            │ ╭ Test trace trace, options: [collapseFinished] ✔
            │ │ ╶ Test trace trace, options: [] ✔
            │ ╰
            │ ╭ Test trace trace, options: [collapseFinished] ✘
            │ │ ╭ Test trace trace, options: [collapseFinished] ✔
            │ │ │ ╶ Trace message
            │ │ │ ╶ Info message
            │ │ │ ╭ Trace process ✘
            │ │ │ │ message
            │ │ │ ╰
            │ │ │ ╭ Info process ⠋
            │ │ │ │ message
            │ │ │ ╰
            │ │ ╰
            │ │ ╭ Test trace trace, options: [collapseFinished] ✘
            │ │ │ ╶ Trace message
            │ │ │ ╶ Info message
            │ │ │ ╭ Trace process ✘
            │ │ │ │ message
            │ │ │ ╰
            │ │ │ ╭ Info process ⠋
            │ │ │ │ message
            │ │ │ ╰
            │ │ ╰
            │ ╰
            ╰
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .trace)) {
            """
            ╭ Test info trace, options: [collapseFinished] ✘
            │ ╶ Test info trace, options: [collapseFinished] ✔
            │ ╶ Test trace trace, options: [collapseFinished] ✔
            │ ╭ Test trace trace, options: [collapseFinished] ✘
            │ │ ╭ Test trace trace, options: [collapseFinished] ✔
            │ │ │ ╶ Info message
            │ │ │ ╭ Trace process ✘
            │ │ │ │ message
            │ │ │ ╰
            │ │ │ ╭ Info process ⠋
            │ │ │ │ message
            │ │ │ ╰
            │ │ ╰
            │ │ ╭ Test trace trace, options: [collapseFinished] ✘
            │ │ │ ╶ Trace message
            │ │ │ ╶ Info message
            │ │ │ ╭ Trace process ✘
            │ │ │ │ message
            │ │ │ ╰
            │ │ │ ╭ Info process ⠋
            │ │ │ │ message
            │ │ │ ╰
            │ │ ╰
            │ ╰
            ╰
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .default)) {
            """
            ╭ Test info trace, options: [collapseFinished] ✘
            │ ╶ Test info trace, options: [collapseFinished] ✔
            │ ╶ Test trace trace, options: [collapseFinished] ✔
            │ ╭ Test trace trace, options: [collapseFinished] ✘
            │ │ ╭ Test trace trace, options: [collapseFinished] ✔
            │ │ │ ╶ Info message
            │ │ │ ╭ Trace process ✘
            │ │ │ │ message
            │ │ │ ╰
            │ │ │ ╭ Info process ⠋
            │ │ │ │ message
            │ │ │ ╰
            │ │ ╰
            │ │ ╭ Test trace trace, options: [collapseFinished] ✘
            │ │ │ ╶ Trace message
            │ │ │ ╶ Info message
            │ │ │ ╭ Trace process ✘
            │ │ │ │ message
            │ │ │ ╰
            │ │ │ ╭ Info process ⠋
            │ │ │ │ message
            │ │ │ ╰
            │ │ ╰
            │ ╰
            ╰
            """
        }
    }
}

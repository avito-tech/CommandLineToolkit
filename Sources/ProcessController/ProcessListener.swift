import Foundation

public typealias Unsubscribe = () -> ()
public typealias SignalListener = (ProcessController, Int32, @escaping Unsubscribe) -> ()
public typealias StartListener = (ProcessController, @escaping Unsubscribe) -> ()
public typealias StderrListener = (ProcessController, Data, @escaping Unsubscribe) -> ()
public typealias StdoutListener = (ProcessController, Data, @escaping Unsubscribe) -> ()
public typealias TerminationListener = (ProcessController, @escaping Unsubscribe) -> ()

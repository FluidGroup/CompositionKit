
import os.log

enum Log {
  
  static func debug(
    file: StaticString = #file,
    line: UInt = #line,
    _ log: OSLog,
    _ object: @autoclosure () -> Any
  ) {
    os_log(.default, log: log, "%{public}@\n%{public}@:%{public}@", "\(object())", "\(file)", "\(line.description)")
  }
  
  static func error(
    file: StaticString = #file,
    line: UInt = #line,
    _ log: OSLog,
    _ object: @autoclosure () -> Any
  ) {
    os_log(.error, log: log, "%{public}@\n%{public}@:%{public}@", "\(object())", "\(file)", "\(line.description)")
  }
  
}

extension OSLog {
  
  @inline(__always)
  private static func makeOSLogInDebug(isEnabled: Bool = true, _ factory: () -> OSLog) -> OSLog {
#if DEBUG
    return factory()
#else
    return .disabled
#endif
  }
  
  static let generic: OSLog = makeOSLogInDebug { OSLog.init(subsystem: "group.fluid.CompositionKit", category: "generic") }
  
  static let dynamicCompositionalLayoutView: OSLog = makeOSLogInDebug { OSLog.init(subsystem: "group.fluid.CompositionKit", category: "DynamicCompositionalLayoutView") }
}

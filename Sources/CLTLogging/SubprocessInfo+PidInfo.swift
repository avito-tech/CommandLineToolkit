/*
 * Copyright (c) Avito Tech LLC
 */

import CLTLoggingModels
import Foundation
import ProcessController

extension SubprocessInfo {
    public var pidInfo: PidInfo {
        PidInfo(pid: subprocessId, name: subprocessName)
    }
}

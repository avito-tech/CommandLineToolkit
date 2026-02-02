/*
 * Copyright (c) Avito Tech LLC
 */

import Foundation

extension FileHandle: @retroactive TextOutputStream {
    public func write(_ string: String) {
        self.write(Data(string.utf8))
    }
}

/*
 * Copyright (c) Avito Tech LLC
 */

import Foundation

class FakeFileHandle: FileHandle {
    
    var isClosed = false
    var closeCounter = 0

    override init(fileDescriptor fd: Int32 = 0, closeOnDealloc closeopt: Bool = true) {
        super.init(fileDescriptor: fd, closeOnDealloc: closeopt)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func closeFile() {
        isClosed = true
        closeCounter += 1
    }
}

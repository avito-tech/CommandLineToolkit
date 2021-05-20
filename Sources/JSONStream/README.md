#  JSONStream

JSONStream API allows you to parse JSON stream on the fly.

```swift

// This class will process all parsed JSON objects
class MyStreamObjectHandler: JSONReaderEventStream {
    func newArray(_ array: NSArray, data: Data) {
        // My stream does not have arrays, so I can just ignore this callback
    }

    func newObject(_ object: NSDictionary, data: Data) {
        // My stream has objects. I can use provided `Data` to `JSONDecode` it into my Swift models,
        // or I can use provided `NSDictionary` to access its fields.
    }
}

let queue = OperationQueue()

// create stream parts
let streamParts = JSONStreamFactory.create(eventStream: MyStreamObjectHandler())

// read bytes in background and feed them into streamParts.appendableStream
queue.addOperation {
    let inputFileHandle = FileHandle... // imagine we have something to read from
    while true {
        let data = inputFileHandle.availableData     // this will block until new data is available
        if data.isEmpty {                            // no data means EOF
            streamParts.appendableStream.close()     // we mark stream as closed - no new data will be appended!
            break
        } else {
            streamParts.appendableStream.append(data)
        }
    }
}

// parse JSON stream in background too
queue.addOperation {
    do {
        try streamParts.jsonReader.start()
    } catch {
        print("JSON stream error: \(error)")
    }
}

queue.waitUntilAllOperationsAreFinished()

```


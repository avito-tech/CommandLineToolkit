import Foundation

/// JSON reader that utilizes JSONStream to parse the JSON stream on the fly.
public final class JSONReader {
    private let inputStream: JSONStream
    private let eventStream: JSONReaderEventStream
    private var context = [ParsingContext.root]
    
    private let anyCharacterSet = CharacterSet([]).inverted
    private let numberChars = CharacterSet(charactersIn: "-1234567890")
    private let whiteCharacters = CharacterSet.whitespacesAndNewlines
    public private(set) var collectedBytes = [UInt8]()
    
    private enum SpecialSymbols {
        static let quotationMark: UInt8 = 0x22 // "
        static let leftSquareBracket: UInt8 = 0x5b // [
        static let leftCurlyBracket: UInt8 = 0x7b // {
        static let rightSquareBracket: UInt8 = 0x5d // ]
        static let rightCurlyBracket: UInt8 = 0x7d // }
        static let comma: UInt8 = 0x2c // ,
        static let colon: UInt8 = 0x3a // :
        static let reverseSolidus: UInt8 = 0x5c // \
        static let digits: ClosedRange<UInt8> = 0x30 ... 0x39 // 0123456789
        static let hypenMinus: UInt8 = 0x2d // -
    }
    
    public init(inputStream: JSONStream, eventStream: JSONReaderEventStream) {
        self.inputStream = inputStream
        self.eventStream = eventStream
    }
    
    /// Starts a continous and blocking parse operation.
    /// It runs it until error occurs, or stream is closed and all non-root objects are parsed successfully.
    /// - Throws: `JSONReaderError` if reader detects an error in the incoming byte stream.
    /// It will NOT throw an error only when stream is closed at the root context.
    public func start() throws {
        try readAndThrowErrorOnFailure()
    }
    
    private func readAndThrowErrorOnFailure() throws {
        do {
            try readRecursively()
        } catch {
            if let readerError = error as? JSONReaderError, case JSONReaderError.streamEndedAtRootContext = readerError {
                return
            } else {
                throw error
            }
        }
    }
    
    private func readRecursively() throws {
        while true {
            switch currentContext {
            case .root:
                try validateRootContext()
            case let .inObject(key, storage):
                try validateObjectContext(key, storage)
            case let .inArray(key, storage):
                try validateArrayContext(key, storage)
            case let .inKey(keyStorage):
                try validateKeyContext(keyStorage as Data)
            case let .inValue(key):
                try validateValueForKeyContext(key)
            case let .inStringValue(_, mutableData):
                try validateStringContext(mutableData)
            case let .inStringObject(storage):
                try validateStringContext(storage)
            case .inNullValue:
                try validateNullContext()
            case .inTrueValue:
                try validateTrueContext()
            case .inFalseValue:
                try validateFalseContext()
            case let .inNumericValue(key, storage):
                try validateNumericContext(key, storage)
            }
        }
    }
    
    private func validateRootContext() throws {
        let readResult = read(untilAnyCharacterFrom: anyCharacterSet, ignoreCharacters: whiteCharacters)
        guard let byte = readResult.matchingByte else { throw JSONReaderError.streamEndedAtRootContext }
        
        switch byte {
        case SpecialSymbols.leftSquareBracket:
            pushContext(.inArray(key: nil, storage: NSMutableArray()))
        case SpecialSymbols.leftCurlyBracket:
            pushContext(.inObject(key: nil, storage: NSMutableDictionary()))
        default:
            throw JSONReaderError.unexpectedCharacter(byte)
        }
    }
    
    private func validateObjectContext(
        _ key: String?,
        _ storage: NSMutableDictionary,
        expectingAnotherKeyValue: Bool = false) throws {
        // {  "key": "value"}, {"key": []}, {"key": {}  }
        //  ^
        let readResult = read(untilAnyCharacterFrom: anyCharacterSet, ignoreCharacters: whiteCharacters)
        guard let byte = readResult.matchingByte else { throw JSONReaderError.streamHasNoData }
        
        switch byte {
        case SpecialSymbols.rightCurlyBracket:
            if !expectingAnotherKeyValue {
                try popContext()
            } else {
                throw JSONReaderError.unexpectedCharacter(byte)
            }
        case SpecialSymbols.quotationMark:
            pushContext(.inKey(NSMutableData()))
        case SpecialSymbols.comma:
            // swiftlint:disable:next empty_count
            if storage.count == 0 || expectingAnotherKeyValue {
                throw JSONReaderError.unexpectedCharacter(byte)
            }
            try validateObjectContext(key, storage, expectingAnotherKeyValue: true)
        default:
            throw JSONReaderError.unexpectedCharacter(byte)
        }
    }
    
    private func validateKeyContext(_ keyStorage: Data) throws {
        // "key" :
        //  ^ we're here
        var readResult = read(untilAnyCharacterFrom: CharacterSet(["\""]))
        guard readResult.matchingByte == SpecialSymbols.quotationMark else { throw JSONReaderError.streamHasNoData }
        
        var keyData = Data()
        keyData.append(contentsOf: readResult.passedBytes)
        
        // "key" :
        //      ^ we're here
        readResult = read(untilAnyCharacterFrom: CharacterSet([":"]), ignoreCharacters: whiteCharacters)
        guard readResult.passedBytes.isEmpty else { throw JSONReaderError.unexpectedCharacter(readResult.passedBytes[0]) }
        guard let byte = readResult.matchingByte else { throw JSONReaderError.streamHasNoData }
        guard byte == SpecialSymbols.colon else { throw JSONReaderError.unexpectedCharacter(byte) }
        
        guard let key = String(data: keyData, encoding: .utf8) else {
            throw JSONReaderError.invalidStringData(keyData)
        }
        
        try popContext()
        pushContext(.inValue(key: key))
    }
    
    private func validateValueForKeyContext(_ key: String) throws {
        // "key":  _____
        //       ^ we're here
        let readResult = read(untilAnyCharacterFrom: anyCharacterSet, ignoreCharacters: whiteCharacters)
        guard let byte = readResult.matchingByte else { throw JSONReaderError.streamHasNoData }
        
        try popContext()
        
        switch byte {
        case SpecialSymbols.leftSquareBracket:
            pushContext(.inArray(key: key, storage: NSMutableArray()))
        case SpecialSymbols.leftCurlyBracket:
            pushContext(.inObject(key: key, storage: NSMutableDictionary()))
        case SpecialSymbols.quotationMark:
            pushContext(.inStringValue(key: key, storage: NSMutableData()))
        case 0x6e: // "n"
            pushContext(.inNullValue(key: key))
        case 0x74: // "t"
            pushContext(.inTrueValue(key: key))
        case 0x66: // "f"
            pushContext(.inFalseValue(key: key))
        case SpecialSymbols.digits, SpecialSymbols.hypenMinus:
            pushContext(.inNumericValue(key: key, storage: NumericStorage(Data([byte]))))
        default:
            throw JSONReaderError.unexpectedCharacter(byte)
        }
    }
    
    private func validateStringContext(_ storage: NSMutableData) throws {
        // "some string"
        //  ^ we're here
        var data = Data()
        var expectedEscapedValue = false
        while true {
            guard let byte = readByte() else { throw JSONReaderError.streamHasNoData }
            
            if byte == SpecialSymbols.reverseSolidus && !expectedEscapedValue {
                expectedEscapedValue = true
            } else if expectedEscapedValue {
                expectedEscapedValue = false
            } else if !expectedEscapedValue && byte == SpecialSymbols.quotationMark {
                break
            }
            data.append(byte)
        }
        storage.setData(data)
        
        try popContext()
    }
    
    private func validateArrayContext(
        _ key: String?,
        _ storage: NSMutableArray,
        expectingAnotherObject: Bool = false) throws
    {
        // [   "object", {}, [], -12.4e4 ]
        //   ^ we're here
        var expectedChars = CharacterSet(["]", "\"", "{", "[", ",", "n", "f", "t"])
        expectedChars.formUnion(numberChars)
        
        let readResult = read(untilAnyCharacterFrom: expectedChars, ignoreCharacters: whiteCharacters)
        guard readResult.passedBytes.isEmpty else { throw JSONReaderError.unexpectedCharacter(readResult.passedBytes[0]) }
        guard let byte = readResult.matchingByte else { throw JSONReaderError.streamHasNoData }
        
        switch byte {
        case SpecialSymbols.rightSquareBracket:
            if !expectingAnotherObject {
                try popContext()
            } else {
                throw JSONReaderError.unexpectedCharacter(byte)
            }
        case SpecialSymbols.quotationMark:
            pushContext(.inStringObject(storage: NSMutableData()))
        case SpecialSymbols.leftCurlyBracket:
            pushContext(.inObject(key: nil, storage: NSMutableDictionary()))
        case SpecialSymbols.leftSquareBracket:
            pushContext(.inArray(key: nil, storage: NSMutableArray()))
        case SpecialSymbols.comma:
            // swiftlint:disable:next empty_count
            if storage.count == 0 || expectingAnotherObject {
                throw JSONReaderError.unexpectedCharacter(byte)
            }
            try validateArrayContext(key, storage, expectingAnotherObject: true)
        case 0x6E: // "n"
            pushContext(.inNullValue(key: nil))
        case 0x74: // "t"
            pushContext(.inTrueValue(key: nil))
        case 0x66: // "f"
            pushContext(.inFalseValue(key: nil))
        case SpecialSymbols.digits, SpecialSymbols.hypenMinus:
            pushContext(.inNumericValue(key: nil, storage: NumericStorage(Data([byte]))))
        default:
            throw JSONReaderError.unexpectedCharacter(byte)
        }
    }
    
    private func validateNullContext() throws {
        // null
        //  ^
        try readAndValidateBytes([0x75, 0x6C, 0x6C])
        try popContext()
    }
    
    private func validateTrueContext() throws {
        // true
        //  ^
        try readAndValidateBytes([0x72, 0x75, 0x65])
        try popContext()
    }
    
    private func validateFalseContext() throws {
        // false
        //  ^
        try readAndValidateBytes([0x61, 0x6C, 0x73, 0x65])
        try popContext()
    }
    
    private func validateNumericContext(_ key: String?, _ storage: NumericStorage) throws {
        // first symbol ('-' or digit) is part of storage already, so we read the rest
        // 1234.56e-21
        //  ^
        let endOfContainerContextScalar: Unicode.Scalar
        if key == nil {
            // nil key means this number is part of array
            endOfContainerContextScalar = "]"
        } else {
            // non-nil key means this number is part of object key->number
            endOfContainerContextScalar = "}"
        }
        let readBreakers = Set<Unicode.Scalar>([",", endOfContainerContextScalar])
        
        while true {
            guard let nextByte = inputStream.touch() else { throw JSONReaderError.streamHasNoData }
            let nextScalar = Unicode.Scalar(nextByte)
            if readBreakers.contains(nextScalar) || whiteCharacters.contains(nextScalar) { break }
            
            guard let byte = readByte() else { throw JSONReaderError.streamHasNoData }
            storage.bytes.append(byte)
        }
        
        guard let stringRepresentation = String(data: Data(storage.bytes), encoding: .utf8) else {
            throw JSONReaderError.invalidNumberValue(storage.bytes)
        }
        storage.parsedNumber = try NumberValidator.validateStringRepresentationOfNumber(stringRepresentation)
        
        try popContext()
    }
    
    private func read(times: Int) throws -> [UInt8] {
        var result = [UInt8]()
        for _ in 0 ..< times {
            guard let byte = readByte() else { throw JSONReaderError.streamHasNoData }
            result.append(byte)
        }
        return result
    }
    
    private func readAndValidateBytes(_ expectedBytes: [UInt8]) throws {
        let actualBytes = try read(times: expectedBytes.count)
        guard actualBytes == expectedBytes else {
            throw JSONReaderError.unexpectedCharacters(actualBytes, expected: expectedBytes)
        }
    }
    
    private func readByte() -> UInt8? {
        guard let byte = inputStream.read() else { return nil }
        collectedBytes.append(byte)
        return byte
    }
    
    /*
     * Reads the input stream up until any scalar from the given set of characters is met.
     * Returns tuple of all scalars that were read from the stream, excluding any characters from ignoreCharacters set,
     * and the scalar that interrupted the read operation.
     * If stream ends, matching scalar will be nil.
     */
    private func read(
        untilAnyCharacterFrom characterSet: CharacterSet,
        ignoreCharacters: CharacterSet? = nil)
        -> (passedBytes: [UInt8], matchingByte: UInt8?)
    {
        var passedBytes = [UInt8]()
        while true {
            guard let inputByte = readByte() else { break }
            let inputScalar = Unicode.Scalar(inputByte)
            if ignoreCharacters?.contains(inputScalar) == true { continue }
            
            if characterSet.contains(inputScalar) {
                return (passedBytes: passedBytes, matchingByte: inputByte)
            } else {
                passedBytes.append(inputByte)
            }
        }
        return (passedBytes: passedBytes, matchingByte: nil)
    }
    
    // MARK: - Context
    
    private func pushContext(_ context: ParsingContext) {
        self.context.append(context)
    }
    
    private var currentContext: ParsingContext {
        // swiftlint:disable:next force_unwrapping
        return self.context.last!
    }
    
    private func popContext() throws {
        let popedContext = self.context.removeLast()
        
        switch (popedContext, currentContext) {
            
            /**
             * When parent context is object
             */
        case (.inKey, .inObject):
            break
        case (.inValue, .inObject):
            break
        case let (.inStringValue(key, data), .inObject(_, object)):
            // case: {"key": "stringValue"}
            guard let key = key else { throw JSONReaderFatalError.objectMustHaveKey(parent: currentContext, child: popedContext) }
            guard let stringValue = String(data: data as Data, encoding: .utf8) else { throw JSONReaderError.invalidStringData(Data(data)) }
            object[key] = stringValue
        case let (.inObject(key, objectValue), .inObject(_, object)):
            // case: {"key": {...}}
            guard let key = key else { throw JSONReaderFatalError.objectMustHaveKey(parent: currentContext, child: popedContext) }
            object[key] = objectValue
        case let (.inArray(key, array), .inObject(_, object)):
            // case: {"key": []]}
            guard let key = key else { throw JSONReaderFatalError.objectMustHaveKey(parent: currentContext, child: popedContext) }
            object[key] = array
        case let (.inNullValue(key), .inObject(_, object)):
            // case: {"key": null}
            guard let key = key else { throw JSONReaderFatalError.objectMustHaveKey(parent: currentContext, child: popedContext) }
            object[key] = NSNull()
        case let (.inTrueValue(key), .inObject(_, object)):
            // case: {"key": true}
            guard let key = key else { throw JSONReaderFatalError.objectMustHaveKey(parent: currentContext, child: popedContext) }
            object[key] = true
        case let (.inFalseValue(key), .inObject(_, object)):
            // case: {"key": false}
            guard let key = key else { throw JSONReaderFatalError.objectMustHaveKey(parent: currentContext, child: popedContext) }
            object[key] = false
        case let (.inNumericValue(key, storage), .inObject(_, object)):
            // case: {"key": -123.45e-3}
            guard let key = key else { throw JSONReaderFatalError.objectMustHaveKey(parent: currentContext, child: popedContext) }
            guard let parsedNumber = storage.parsedNumber else { throw JSONReaderError.invalidNumberValue(storage.bytes) }
            object[key] = parsedNumber
            
            /**
             * When parent context is array
             */
        case let (.inStringObject(data), .inArray(_, array)):
            guard let stringValue = String(data: data as Data, encoding: .utf8) else { throw JSONReaderError.invalidStringData(Data(data)) }
            // case: ["string"]
            array.add(stringValue)
        case let (.inObject(key, object), .inArray(_, array)):
            // case: [{}]
            // arrays do not have keys so key must be nil
            guard key == nil else { throw JSONReaderFatalError.arrayCannotHaveKeys(parent: currentContext, child: popedContext) }
            array.add(object)
        case let (.inArray(key, subarray), .inArray(_, array)):
            // case: [[]]
            // arrays do not have keys so key must be nil
            guard key == nil else { throw JSONReaderFatalError.arrayCannotHaveKeys(parent: currentContext, child: popedContext) }
            array.add(subarray)
        case let (.inNullValue(key), .inArray(_, array)):
            // case: [null]
            // arrays do not have keys so key must be nil
            guard key == nil else { throw JSONReaderFatalError.arrayCannotHaveKeys(parent: currentContext, child: popedContext) }
            array.add(NSNull())
        case let (.inTrueValue(key), .inArray(_, array)):
            // case: [true]
            // arrays do not have keys so key must be nil
            guard key == nil else { throw JSONReaderFatalError.arrayCannotHaveKeys(parent: currentContext, child: popedContext) }
            array.add(true)
        case let (.inFalseValue(key), .inArray(_, array)):
            // case: [false]
            // arrays do not have keys so key must be nil
            guard key == nil else { throw JSONReaderFatalError.arrayCannotHaveKeys(parent: currentContext, child: popedContext) }
            array.add(false)
        case let (.inNumericValue(key, storage), .inArray(_, array)):
            // case: [-123.45e-3]
            // arrays do not have keys so key must be nil
            guard key == nil, let parsedNumber = storage.parsedNumber else { throw JSONReaderError.invalidNumberValue(storage.bytes) }
            array.add(parsedNumber)
            
            /**
             * When parent context is root, we expect specific child contexts
             */
        case let (.inObject(_, object), .root):
            eventStream.newObject(NSDictionary(dictionary: object), data: Data(collectedBytes))
            collectedBytes.removeAll()
        case let (.inArray(_, array), .root):
            eventStream.newArray(NSArray(array: array), data: Data(collectedBytes))
            collectedBytes.removeAll()
        default:
            throw JSONReaderFatalError.unhandledContextCombination(parent: currentContext, child: popedContext)
        }
    }
}

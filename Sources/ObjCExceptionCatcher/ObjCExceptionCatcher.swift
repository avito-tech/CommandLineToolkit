import Foundation
import ObjCExceptionCatcherHelper

public final class ObjCExceptionCatcher {
    public static func tryClosure(
        tryClosure: () -> (),
        catchClosure: (NSException) -> (),
        finallyClosure: () -> () = {}
    ) {
        ObjCExceptionCatcherHelper.`try`(tryClosure, catch: catchClosure, finally: finallyClosure)
    }
}

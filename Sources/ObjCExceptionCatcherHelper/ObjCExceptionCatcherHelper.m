#import "ObjCExceptionCatcherHelper.h"

@implementation ObjCExceptionCatcherHelper

+ (void)try:(NS_NOESCAPE void(^)(void))tryBlock
      catch:(NS_NOESCAPE void(^)(NSException *))catchBlock
    finally:(NS_NOESCAPE void(^)(void))finallyBlock
{
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        catchBlock(exception);
    }
    @finally {
        finallyBlock();
    }
}

@end

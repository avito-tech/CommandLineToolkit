#import <Foundation/Foundation.h>

@interface ObjCExceptionCatcherHelper: NSObject

+ (void)try:(nonnull NS_NOESCAPE void(^)(void))tryBlock
      catch:(nonnull NS_NOESCAPE void(^)(NSException * _Nonnull))catchBlock
    finally:(nonnull NS_NOESCAPE void(^)(void))finallyBlock;

@end

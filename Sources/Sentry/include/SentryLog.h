#import <Foundation/Foundation.h>

#import "SentryDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface SentryLog : NSObject

- (instancetype)initWithMinLevel:(SentryLogLevel)minLevel;
- (void)logWithMessage:(NSString *)message andLevel:(SentryLogLevel)level;

@end

NS_ASSUME_NONNULL_END

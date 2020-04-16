#import "SentryClient.h"
#import "SentryLog.h"
#import "SentrySDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface SentryLog ()

@property(readonly, nonatomic, assign) SentryLogLevel logLevel;

@end

@implementation SentryLog


- (instancetype)initWithMinLevel:(SentryLogLevel)minLevel {
    self = [super init];
    if (self) {
        _logLevel = minLevel;
    }
    return self;
}

- (void)logWithMessage:(NSString *)message andLevel:(SentryLogLevel)level {
    SentryLogLevel defaultLevel = kSentryLogLevelError;
    if (_logLevel > 0) {
        defaultLevel = SentrySDK.logLevel;
    }
    if (_logLevel <= defaultLevel && _logLevel != kSentryLogLevelNone) {
        NSLog(@"Sentry - %@:: %@", [self.class logLevelToString:level], message);
    }
}

+ (NSString *)logLevelToString:(SentryLogLevel)level {
    switch (level) {
        case kSentryLogLevelDebug:
            return @"Debug";
        case kSentryLogLevelVerbose:
            return @"Verbose";
        default:
            return @"Error";
    }
}
@end

NS_ASSUME_NONNULL_END

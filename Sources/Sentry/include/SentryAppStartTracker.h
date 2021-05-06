#import "SentryDefines.h"
#import "SentryCurrentDateProvider.h"

@class SentryOptions;

NS_ASSUME_NONNULL_BEGIN

@interface SentryAppStartTracker : NSObject
SENTRY_NO_INIT

- (instancetype)initWithOptions:(SentryOptions *)options currentDateProvider:(id<SentryCurrentDateProvider>)currentDateProvider;

- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END

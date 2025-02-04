#import "SentryDefines.h"
#import "SentryScopeObserver.h"

@class SentryFileManager;

NS_ASSUME_NONNULL_BEGIN

/**
 * This scope observer is used by the Out of Memory integration to write breadcrumbs to disk.
 * The overhead is ~0.015 seconds for 1000 breadcrumbs.
 * This class doesn't need to be thread safe as the scope already calls the scope observers in a
 * thread safe manner.
 */
@interface SentryOutOfMemoryScopeObserver : NSObject <SentryScopeObserver>
SENTRY_NO_INIT

- (instancetype)initWithMaxBreadcrumbs:(NSInteger)maxBreadcrumbs
                           fileManager:(SentryFileManager *)fileManager;

@end

NS_ASSUME_NONNULL_END

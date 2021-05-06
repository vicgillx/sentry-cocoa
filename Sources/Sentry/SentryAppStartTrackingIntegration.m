#import <Foundation/Foundation.h>
#import "SentryAppStartTrackingIntegration.h"
#import "SentryAppStartTracker.h"
#import "SentryDefaultCurrentDateProvider.h"

@interface SentryAppStartTrackingIntegration()

@property (nonatomic, strong) SentryAppStartTracker *tracker;

@end

@implementation SentryAppStartTrackingIntegration


- (void)installWithOptions:(SentryOptions *)options
{
    self.tracker = [[SentryAppStartTracker alloc] initWithOptions:options currentDateProvider:[[SentryDefaultCurrentDateProvider alloc] init]];
    [self.tracker start];
}

- (void)uninstall
{
    [self stop];
}

- (void)stop
{
    if (nil != self.tracker) {
        [self.tracker stop];
    }
}

@end

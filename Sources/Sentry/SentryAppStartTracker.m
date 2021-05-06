#import <Foundation/Foundation.h>
#import <SentryAppStartTracker.h>
#import <SentryInternalNotificationNames.h>
#import <SentryCurrentDateProvider.h>
#import <SentryLog.h>
#import <SentrySDK+Private.h>
#import <SentrySpan.h>

#if SENTRY_HAS_UIKIT
#    import <UIKit/UIKit.h>
#endif

static NSDate *appStart = nil;

@interface SentryAppStartTracker ()

@property (nonatomic, strong) SentryOptions *options;
@property (nonatomic, strong) id<SentryCurrentDateProvider> currentDateProvider;
@property (nonatomic, strong) SentrySpan *appStartTransaction;
@property (nonatomic, strong) SentrySpan *appInit;
@property (nonatomic, strong) SentrySpan *enterForeground;
@property (nonatomic, strong) SentrySpan *gettingActive;

@end

@implementation SentryAppStartTracker : NSObject

+ (void)load {
    appStart = [NSDate date];
}

- (instancetype)initWithOptions:(SentryOptions *)options currentDateProvider:(id<SentryCurrentDateProvider>)currentDateProvider {
    if (self = [super init]) {
        self.options = options;
        self.currentDateProvider = currentDateProvider;
    }
    return self;
}

- (void)start {
#if SENTRY_HAS_UIKIT
    
    self.appStartTransaction = [SentrySDK startTransactionWithName:@"App Launch" operation:@"App Launch" bindToScope:NO];
    [self.appStartTransaction setStartTimestamp:appStart];
    SentrySpan *beforeSenryInit = [self.appStartTransaction startChildWithOperation:@"Runtime Load Sentry -> SentrySDK.start"];
    [beforeSenryInit setStartTimestamp:appStart];
    [beforeSenryInit finish];
    
    self.enterForeground = [self.appStartTransaction startChildWithOperation:@"SentrySDK.start -> WillEnterForeground"];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(willEnterForeground)
                                               name:UIApplicationWillEnterForegroundNotification
                                             object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(didBecomeActive)
                                               name:UIApplicationDidBecomeActiveNotification
                                             object:nil];
    

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(didBecomeActive)
                                               name:SentryHybridSdkDidBecomeActiveNotificationName
                                             object:nil];
#else
    [SentryLog logWithMessage:@"NO UIKit -> SentryAppStartTracker will not track app start up time."
                     andLevel:kSentryLevelInfo];
    return;
#endif
}

- (void)willEnterForeground
{
    [self.enterForeground finish];
    self.gettingActive = [self.appStartTransaction startChildWithOperation:@"WillEnterForeground -> DidBecomeActive"];
}

/**
 * It is called when an App. is receiving events / It is in the foreground and when we receive a
 * SentryHybridSdkDidBecomeActiveNotification.
 */
- (void)didBecomeActive
{
    [self.gettingActive finish];
    [self.appStartTransaction finish];
}


- (void)stop {
#if SENTRY_HAS_UIKIT
    [NSNotificationCenter.defaultCenter removeObserver:self];
#endif
}

@end

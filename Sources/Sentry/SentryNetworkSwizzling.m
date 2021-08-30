#import "SentryNetworkSwizzling.h"
#import "SentryNetworkTracker.h"
#import "SentrySwizzle.h"

@implementation SentryNetworkSwizzling

+ (void)start
{
    [SentryNetworkTracker.sharedInstance enable];
    [self swizzleURLSessionTaskResume];
    [self swizzleNSURLSessionConfiguration];
    [self swizzleURLConnectionInit];
}

+ (void)stop
{
    [SentryNetworkTracker.sharedInstance disable];
}

// SentrySwizzleInstanceMethod declaration shadows a local variable. The swizzling is working
// fine and we accept this warning.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wshadow"

+ (void)swizzleURLSessionTaskResume
{
    SEL selector = NSSelectorFromString(@"resume");
    SentrySwizzleInstanceMethod(NSURLSessionTask.class, selector, SentrySWReturnType(void),
        SentrySWArguments(), SentrySWReplacement({
            [SentryNetworkTracker.sharedInstance urlSessionTaskResume:self];
            SentrySWCallOriginal();
        }),
        SentrySwizzleModeOncePerClassAndSuperclasses, (void *)selector);
}

+ (void)swizzleNSURLSessionConfiguration
{
    SEL httpAdditionalHeadersSelector = NSSelectorFromString(@"HTTPAdditionalHeaders");
    SentrySwizzleInstanceMethod(NSURLSessionConfiguration.class, httpAdditionalHeadersSelector,
        SentrySWReturnType(NSDictionary *), SentrySWArguments(), SentrySWReplacement({
            return [SentryNetworkTracker.sharedInstance addTraceHeader:SentrySWCallOriginal()];
        }),
        SentrySwizzleModeOncePerClassAndSuperclasses, (void *)httpAdditionalHeadersSelector);
}

+ (void)swizzleURLConnectionInit
{
    SEL initSelector = NSSelectorFromString(@"initWithRequest:delegate:");
    SentrySwizzleInstanceMethod(NSURLConnection.class, initSelector,
        SentrySWReturnType(NSURLConnection *),
        SentrySWArguments(NSURLRequest * request, id delegate), SentrySWReplacement({
            NSURLRequest *newRequest =
                [SentryNetworkTracker.sharedInstance addTraceHeaderToRequest:request];
            return SentrySWCallOriginal(newRequest, delegate);
        }),
        SentrySwizzleModeOncePerClassAndSuperclasses, (void *)initSelector);

    SEL initStartImmediatelySelector
        = NSSelectorFromString(@"initWithRequest:delegate:startImmediately:");
    SentrySwizzleInstanceMethod(NSURLConnection.class, initStartImmediatelySelector,
        SentrySWReturnType(NSURLConnection *),
        SentrySWArguments(NSURLRequest * request, id delegate, BOOL startImmediately),
        SentrySWReplacement({
            NSURLRequest *newRequest =
                [SentryNetworkTracker.sharedInstance addTraceHeaderToRequest:request];
            return SentrySWCallOriginal(newRequest, delegate, initStartImmediatelySelector);
        }),
        SentrySwizzleModeOncePerClassAndSuperclasses, (void *)initStartImmediatelySelector);
}

#pragma clang diagnostic pop
@end

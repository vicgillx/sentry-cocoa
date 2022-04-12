#import "SentryTransportAdapter.h"
#import "SentryClientReport.h"
#import "SentryDataCategoryMapper.h"
#import "SentryDiscardReasonMapper.h"
#import "SentryDiscardedEvent.h"
#import "SentryDispatchQueueWrapper.h"
#import "SentryDsn.h"
#import "SentryEnvelope+Private.h"
#import "SentryEnvelope.h"
#import "SentryEnvelopeItemType.h"
#import "SentryEnvelopeRateLimit.h"
#import "SentryEvent.h"
#import "SentryFileContents.h"
#import "SentryFileManager.h"
#import "SentryHttpTransport.h"
#import "SentryLog.h"
#import "SentryNSURLRequest.h"
#import "SentryNSURLRequestBuilder.h"
#import "SentryOptions.h"
#import "SentrySerialization.h"
#import "SentryTraceState.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface
SentryTransportAdapter ()

@property (nonatomic, strong) id<SentryTransport> transport;
@property (nonatomic, strong) SentryOptions *options;

@end

@implementation SentryTransportAdapter

- (instancetype)initWithTransport:(id<SentryTransport>)transport options:(SentryOptions *)options
{
    if (self = [super init]) {
        self.transport = transport;
        self.options = options;
    }

    return self;
}

- (void)sendEvent:(SentryEvent *)event attachments:(NSArray<SentryAttachment *> *)attachments
{
    [self sendEvent:event traceState:nil attachments:attachments];
}

- (void)sendEvent:(SentryEvent *)event
      withSession:(SentrySession *)session
      attachments:(NSArray<SentryAttachment *> *)attachments
{
    [self sendEvent:event withSession:session traceState:nil attachments:attachments];
}

- (void)sendEvent:(SentryEvent *)event
       traceState:(nullable SentryTraceState *)traceState
      attachments:(NSArray<SentryAttachment *> *)attachments
{
    [self sendEvent:event
                     traceState:traceState
                    attachments:attachments
        additionalEnvelopeItems:@[]];
}

- (void)sendEvent:(SentryEvent *)event
                 traceState:(nullable SentryTraceState *)traceState
                attachments:(NSArray<SentryAttachment *> *)attachments
    additionalEnvelopeItems:(NSArray<SentryEnvelopeItem *> *)additionalEnvelopeItems
{
    NSMutableArray<SentryEnvelopeItem *> *items = [self buildEnvelopeItems:event
                                                               attachments:attachments];
    [items addObjectsFromArray:additionalEnvelopeItems];

    SentryEnvelopeHeader *envelopeHeader = [[SentryEnvelopeHeader alloc] initWithId:event.eventId
                                                                         traceState:traceState];
    SentryEnvelope *envelope = [[SentryEnvelope alloc] initWithHeader:envelopeHeader items:items];

    [self sendEnvelope:envelope];
}

- (void)sendEvent:(SentryEvent *)event
      withSession:(SentrySession *)session
       traceState:(nullable SentryTraceState *)traceState
      attachments:(NSArray<SentryAttachment *> *)attachments
{
    NSMutableArray<SentryEnvelopeItem *> *items = [self buildEnvelopeItems:event
                                                               attachments:attachments];
    [items addObject:[[SentryEnvelopeItem alloc] initWithSession:session]];

    SentryEnvelopeHeader *envelopeHeader = [[SentryEnvelopeHeader alloc] initWithId:event.eventId
                                                                         traceState:traceState];

    SentryEnvelope *envelope = [[SentryEnvelope alloc] initWithHeader:envelopeHeader items:items];

    [self sendEnvelope:envelope];
}

- (void)sendUserFeedback:(SentryUserFeedback *)userFeedback
{
    SentryEnvelope *envelope = [[SentryEnvelope alloc] initWithUserFeedback:userFeedback];
    [self sendEnvelope:envelope];
}

- (void)sendEnvelope:(SentryEnvelope *)envelope
{
    [self.transport sendEnvelope:envelope];
}

- (void)recordLostEvent:(SentryDataCategory)category reason:(SentryDiscardReason)reason
{
    [self.transport recordLostEvent:category reason:reason];
}

- (NSMutableArray<SentryEnvelopeItem *> *)buildEnvelopeItems:(SentryEvent *)event
                                                 attachments:
                                                     (NSArray<SentryAttachment *> *)attachments
{
    NSMutableArray<SentryEnvelopeItem *> *items = [NSMutableArray new];
    [items addObject:[[SentryEnvelopeItem alloc] initWithEvent:event]];

    for (SentryAttachment *attachment in attachments) {
        SentryEnvelopeItem *item =
            [[SentryEnvelopeItem alloc] initWithAttachment:attachment
                                         maxAttachmentSize:self.options.maxAttachmentSize];
        // The item is nil, when creating the envelopeItem failed.
        if (nil != item) {
            [items addObject:item];
        }
    }

    return items;
}

@end

NS_ASSUME_NONNULL_END

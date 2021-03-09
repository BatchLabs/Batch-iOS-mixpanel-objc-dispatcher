#import <Batch/BatchEventDispatcher.h>

@interface BatchPayloadDispatcherTest : NSObject <BatchEventDispatcherPayload>

@property (nullable) NSString *trackingId;
@property (nullable) NSString *deeplink;
@property (nullable) NSString *webViewAnalyticsIdentifier;
@property BOOL isPositiveAction;
@property (nullable) BatchInAppMessage *inAppPayload;
@property (nullable) NSDictionary *pushPayload;

@property (nullable) NSDictionary<NSString *, id> *customPayload;

@end

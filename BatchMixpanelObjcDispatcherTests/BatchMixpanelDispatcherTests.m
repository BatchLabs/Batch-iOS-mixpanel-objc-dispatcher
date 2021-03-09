#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Mixpanel/Mixpanel.h>

#import "BatchMixpanelObjcDispatcher.h"
#import "BatchPayloadDispatcherTests.h"

@interface BatchMixpanelDispatcherTests : XCTestCase

@property (nonatomic) id helperMock;
@property (nonatomic) BatchMixpanelObjcDispatcher *dispatcher;

@end

@implementation BatchMixpanelDispatcherTests

- (void)setUp
{
    [super setUp];

    _dispatcher = [BatchMixpanelObjcDispatcher instance];
    
    _helperMock = OCMClassMock([Mixpanel class]);
    OCMStub([_helperMock track:[OCMArg any] properties:[OCMArg any]]);
    
    _dispatcher.mixpanelInstance = _helperMock;
}

- (void)tearDown
{
    [super tearDown];
    
    [_helperMock stopMocking];
    _helperMock = nil;
}

- (void)testPushNoData
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen payload:testPayload];
    
    NSString *expectedName = @"batch_notification_open";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"$source": @"batch",
        @"utm_medium": @"push"
    };
    OCMVerify([_helperMock track:expectedName properties:expectedParameters]);
}

- (void)testNotificationDeeplinkQueryVars
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com?utm_source=batchsdk&utm_medium=push-batch&utm_campaign=yoloswag&utm_content=button1";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen payload:testPayload];
    
    NSString *expectedName = @"batch_notification_open";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"utm_campaign": @"yoloswag",
        @"utm_medium": @"push-batch",
        @"utm_content": @"button1",
        @"utm_source": @"batchsdk",
        @"$source": @"batch",
    };
    OCMVerify([_helperMock track:expectedName properties:expectedParameters]);
}

- (void)testNotificationDeeplinkQueryVarsEncode
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com?utm_source=%5Bbatchsdk%5D&utm_medium=push-batch&utm_campaign=yoloswag&utm_content=button1";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen payload:testPayload];
    
    NSString *expectedName = @"batch_notification_open";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"utm_campaign": @"yoloswag",
        @"utm_medium": @"push-batch",
        @"utm_content": @"button1",
        @"utm_source": @"[batchsdk]",
        @"$source": @"batch",
    };
    OCMVerify([_helperMock track:expectedName properties:expectedParameters]);
}

- (void)testNotificationDeeplinkFragmentVars
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com#utm_source=batch-sdk&utm_medium=pushbatch01&utm_campaign=154879548754&utm_content=notif001";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen payload:testPayload];
    
    NSString *expectedName = @"batch_notification_open";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"utm_campaign": @"154879548754",
        @"utm_medium": @"pushbatch01",
        @"utm_content": @"notif001",
        @"utm_source": @"batch-sdk",
        @"$source": @"batch",
    };
    OCMVerify([_helperMock track:expectedName properties:expectedParameters]);
}

- (void)testNotificationDeeplinkNonTrimmed
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"    \n     https://batch.com#utm_source=batch-sdk&utm_medium=pushbatch01&utm_campaign=154879548754&utm_content=notif001     \n    ";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen payload:testPayload];
    
    NSString *expectedName = @"batch_notification_open";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"utm_campaign": @"154879548754",
        @"utm_medium": @"pushbatch01",
        @"utm_content": @"notif001",
        @"utm_source": @"batch-sdk",
        @"$source": @"batch",
    };
    OCMVerify([_helperMock track:expectedName properties:expectedParameters]);
}

- (void)testNotificationDeeplinkFragmentVarsEncode
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com/test#utm_source=%5Bbatch-sdk%5D&utm_medium=pushbatch01&utm_campaign=154879548754&utm_content=notif001";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen payload:testPayload];
    
    NSString *expectedName = @"batch_notification_open";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"utm_campaign": @"154879548754",
        @"utm_medium": @"pushbatch01",
        @"utm_content": @"notif001",
        @"utm_source": @"[batch-sdk]",
        @"$source": @"batch",
    };
    OCMVerify([_helperMock track:expectedName properties:expectedParameters]);
}

- (void)testNotificationCustomPayload
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com#utm_source=batch-sdk&utm_medium=pushbatch01&utm_campaign=154879548754&utm_content=notif001";
    testPayload.customPayload = @{
        @"utm_medium": @"654987",
        @"utm_source": @"jesuisuntest",
        @"utm_campaign": @"heinhein",
        @"utm_content": @"allo118218",
    };
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen payload:testPayload];
    
    NSString *expectedName = @"batch_notification_open";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"utm_medium": @"654987",
        @"utm_source": @"jesuisuntest",
        @"utm_campaign": @"heinhein",
        @"utm_content": @"notif001",
        @"$source": @"batch",
    };
    OCMVerify([_helperMock track:expectedName properties:expectedParameters]);
}

- (void)testNotificationDeeplinkPriority
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com?utm_source=batchsdk&utm_campaign=yoloswag#utm_source=batch-sdk&utm_medium=pushbatch01&utm_campaign=154879548754&utm_content=notif001";
    testPayload.customPayload = @{
        @"utm_medium": @"654987",
    };
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen payload:testPayload];
    
    NSString *expectedName = @"batch_notification_open";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"utm_medium": @"654987",
        @"utm_source": @"batchsdk",
        @"utm_campaign": @"yoloswag",
        @"utm_content": @"notif001",
        @"$source": @"batch",
    };
    OCMVerify([_helperMock track:expectedName properties:expectedParameters]);
}

- (void)testInAppNoData
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingShow payload:testPayload];
    
    NSString *expectedName = @"batch_in_app_show";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"$source": @"batch",
        @"utm_medium": @"in-app",
    };
    OCMVerify([_helperMock track:expectedName properties:expectedParameters]);
}

- (void)testInAppTrackingID
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.trackingId = @"jesuisuntrackingid";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingShow payload:testPayload];
    
    NSString *expectedName = @"batch_in_app_show";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"utm_campaign": @"jesuisuntrackingid",
        @"$source": @"batch",
        @"utm_medium": @"in-app",
        @"batch_tracking_id": @"jesuisuntrackingid"
    };
    OCMVerify([_helperMock track:expectedName properties:expectedParameters]);
}

- (void)testInAppDeeplinkContentQueryVars
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com/test-ios?utm_content=yoloswag";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingClick payload:testPayload];
    
    NSString *expectedName = @"batch_in_app_click";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"$source": @"batch",
        @"utm_medium": @"in-app",
        @"utm_content": @"yoloswag"
    };
    OCMVerify([_helperMock track:expectedName properties:expectedParameters]);
}

- (void)testInAppDeeplinkContentQueryVarsUppercase
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com/test-ios?UtM_coNTEnt=yoloswag";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingClick payload:testPayload];
    
    NSString *expectedName = @"batch_in_app_click";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"$source": @"batch",
        @"utm_medium": @"in-app",
        @"utm_content": @"yoloswag"
    };
    OCMVerify([_helperMock track:expectedName properties:expectedParameters]);
}


- (void)testInAppDeeplinkFragmentQueryVars
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com/test-ios#utm_content=yoloswag2";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingClick payload:testPayload];
    
    NSString *expectedName = @"batch_in_app_click";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"$source": @"batch",
        @"utm_medium": @"in-app",
        @"utm_content": @"yoloswag2"
    };
    OCMVerify([_helperMock track:expectedName properties:expectedParameters]);
}

- (void)testInAppDeeplinkFragmentQueryVarsUppercase
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com/test-ios#uTm_CoNtEnT=yoloswag2";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingClick payload:testPayload];
    
    NSString *expectedName = @"batch_in_app_click";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"$source": @"batch",
        @"utm_medium": @"in-app",
        @"utm_content": @"yoloswag2"
    };
    OCMVerify([_helperMock track:expectedName properties:expectedParameters]);
}

- (void)testInAppDeeplinkContentPriority
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com/test-ios?utm_content=testprio#utm_content=yoloswag2";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingClose payload:testPayload];
    
    NSString *expectedName = @"batch_in_app_close";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"$source": @"batch",
        @"utm_medium": @"in-app",
        @"utm_content": @"testprio"
    };
    OCMVerify([_helperMock track:expectedName properties:expectedParameters]);
}

- (void)testInAppDeeplinkContentNoId
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com?utm_content=jesuisuncontent";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingClose payload:testPayload];
    
    NSString *expectedName = @"batch_in_app_close";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"$source": @"batch",
        @"utm_medium": @"in-app",
        @"utm_content": @"jesuisuncontent"
    };
    OCMVerify([_helperMock track:expectedName properties:expectedParameters]);
}

- (void)testInAppCloseError
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingCloseError payload:testPayload];
    
    NSString *expectedName = @"batch_in_app_close_error";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"$source": @"batch",
        @"utm_medium": @"in-app"
    };
    OCMVerify([_helperMock track:expectedName properties:expectedParameters]);
}

- (void)testInAppWebViewClickAnalyticsIdentifier
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.webViewAnalyticsIdentifier = @"test1234";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeMessagingWebViewClick payload:testPayload];
    
    NSString *expectedName = @"batch_in_app_webview_click";
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"$source": @"batch",
        @"utm_medium": @"in-app",
        @"batch_webview_analytics_id": @"test1234"
    };
    OCMVerify([_helperMock track:expectedName properties:expectedParameters]);
}

@end

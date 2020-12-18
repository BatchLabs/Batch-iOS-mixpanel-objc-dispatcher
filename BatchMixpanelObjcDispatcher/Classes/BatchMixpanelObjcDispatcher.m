#import <Foundation/Foundation.h>
#import <Mixpanel/Mixpanel.h>

#import "BatchMixpanelObjcDispatcher.h"

NSString* const BatchMixpanelUtmCampaign = @"utm_campaign";
NSString* const BatchMixpanelUtmSource = @"utm_source";
NSString* const BatchMixpanelUtmMedium = @"utm_medium";
NSString* const BatchMixpanelUtmContent = @"utm_content";

NSString* const BatchMixpanelCampaign = @"utm_campaign";
NSString* const BatchMixpanelSource = @"utm_source";
NSString* const BatchMixpanelIntegrationId = @"$source";
NSString* const BatchMixpanelMedium = @"utm_medium";
NSString* const BatchMixpanelContent = @"utm_content";

NSString* const BatchMixpanelTrackingId = @"batch_tracking_id";

@implementation BatchMixpanelObjcDispatcher
{
    BOOL _warnedAboutNil;
}

+ (instancetype)instance
{
    static BatchMixpanelObjcDispatcher *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BatchMixpanelObjcDispatcher alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mixpanelInstance = nil;
        _warnedAboutNil = false;
    }
    return self;
}

- (void)dispatchEventWithType:(BatchEventDispatcherType)type payload:(nonnull id<BatchEventDispatcherPayload>)payload
{
    NSDictionary<NSString *, id> *parameters = nil;
    if ([BatchEventDispatcher isNotificationEvent:type]) {
        parameters = [self notificationParamsFromPayload:payload];
    } else if ([BatchEventDispatcher isMessagingEvent:type]) {
        parameters = [self inAppParamsFromPayload:payload];
    }
    
    if (!_warnedAboutNil && self.mixpanelInstance == nil) {
        _warnedAboutNil = true;
        NSLog(@"BatchMixpanelObjcDispatcher - Cannot send event to Mixpanel as no instance has been configured. Did you set the mixpanelInstance property to your Mixpanel instance?");
    }
    
    [self.mixpanelInstance track:[self stringFromEventType:type] properties:parameters];
}

-(nullable NSDictionary<NSString *, id> *)inAppParamsFromPayload:(nonnull id<BatchEventDispatcherPayload>)payload
{
    NSMutableDictionary<NSString *, id> *parameters = [NSMutableDictionary dictionary];
    
    // Init with default values
    [parameters setValue:@"batch" forKey:BatchMixpanelIntegrationId];
    [parameters setValue:payload.trackingId forKey:BatchMixpanelCampaign];
    [parameters setValue:@"in-app" forKey:BatchMixpanelMedium];
    [parameters setValue:payload.trackingId forKey:BatchMixpanelTrackingId];
    
    NSString *deeplink = payload.deeplink;
    if (deeplink != nil) {
        deeplink = [deeplink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSURL *url = [NSURL URLWithString:deeplink];
        if (url != nil) {
            NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:false];
            if (components != nil) {
                
                // Override with values from URL fragment parameters
                if (components.fragment != nil) {
                    NSDictionary *fragments = [self dictFragment:components.fragment];
                    [self addParam:parameters fromFragment:fragments fromKey:BatchMixpanelUtmContent outKey:BatchMixpanelContent];
                }
                
                // Override with values from URL query parameters
                [self addParam:parameters fromUrl:components fromKey:BatchMixpanelUtmContent outKey:BatchMixpanelContent];
            }
        }
    }
    
    // Override with values from custom payload
    [self addParam:parameters fromPayload:payload fromKey:BatchMixpanelUtmCampaign outKey:BatchMixpanelCampaign];
    [self addParam:parameters fromPayload:payload fromKey:BatchMixpanelUtmSource outKey:BatchMixpanelSource];
    [self addParam:parameters fromPayload:payload fromKey:BatchMixpanelUtmMedium outKey:BatchMixpanelMedium];
    return parameters;
}

-(nullable NSDictionary<NSString *, id> *)notificationParamsFromPayload:(nonnull id<BatchEventDispatcherPayload>)payload
{
    NSMutableDictionary<NSString *, id> *parameters = [NSMutableDictionary dictionary];
    
    // Init with default values
    [parameters setValue:@"batch" forKey:BatchMixpanelIntegrationId];
    [parameters setValue:@"push" forKey:BatchMixpanelMedium];
    
    NSString *deeplink = payload.deeplink;
    if (deeplink != nil) {
        deeplink = [deeplink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSURL *url = [NSURL URLWithString:deeplink];
        if (url != nil) {
            NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:false];
            if (components != nil) {
            
                // Override with values from URL fragment parameters
                if (components.fragment != nil) {
                    NSDictionary *fragments = [self dictFragment:components.fragment];
                    [self addParam:parameters fromFragment:fragments fromKey:BatchMixpanelUtmCampaign outKey:BatchMixpanelCampaign];
                    [self addParam:parameters fromFragment:fragments fromKey:BatchMixpanelUtmSource outKey:BatchMixpanelSource];
                    [self addParam:parameters fromFragment:fragments fromKey:BatchMixpanelUtmMedium outKey:BatchMixpanelMedium];
                    [self addParam:parameters fromFragment:fragments fromKey:BatchMixpanelUtmContent outKey:BatchMixpanelContent];
                }
            
                // Override with values from URL query parameters
                [self addParam:parameters fromUrl:components fromKey:BatchMixpanelUtmCampaign outKey:BatchMixpanelCampaign];
                [self addParam:parameters fromUrl:components fromKey:BatchMixpanelUtmSource outKey:BatchMixpanelSource];
                [self addParam:parameters fromUrl:components fromKey:BatchMixpanelUtmMedium outKey:BatchMixpanelMedium];
                [self addParam:parameters fromUrl:components fromKey:BatchMixpanelUtmContent outKey:BatchMixpanelContent];
            }
        }
    }
    
    // Override with values from custom payload
    [self addParam:parameters fromPayload:payload fromKey:BatchMixpanelUtmCampaign outKey:BatchMixpanelCampaign];
    [self addParam:parameters fromPayload:payload fromKey:BatchMixpanelUtmSource outKey:BatchMixpanelSource];
    [self addParam:parameters fromPayload:payload fromKey:BatchMixpanelUtmMedium outKey:BatchMixpanelMedium];
    return parameters;
}

-(NSDictionary*)dictFragment:(nonnull NSString*)fragment
{
    NSMutableDictionary<NSString *, id> *fragments = [NSMutableDictionary dictionary];
    NSArray *fragmentComponents = [fragment componentsSeparatedByString:@"&"];
    for (NSString *keyValuePair in fragmentComponents) {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[[pairComponents firstObject] stringByRemovingPercentEncoding] lowercaseString];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];

        [fragments setObject:value forKey:key];
    }
    return fragments;
}

-(void)addParam:(nonnull NSMutableDictionary<NSString *, id> *)parameters
   fromFragment:(nonnull NSDictionary*)fragments
        fromKey:(nonnull NSString*)fromKey
         outKey:(nonnull NSString*)outKey
{
    NSObject *value = [fragments objectForKey:fromKey];
    if (value != nil) {
        [parameters setValue:value forKey:outKey];
    }
}

-(void)addParam:(nonnull NSMutableDictionary<NSString *, id> *)parameters
        fromUrl:(nonnull NSURLComponents*)components
        fromKey:(nonnull NSString*)fromKey
         outKey:(nonnull NSString*)outKey
{
    for (NSURLQueryItem *item in components.queryItems) {
        if ([fromKey caseInsensitiveCompare:item.name] == NSOrderedSame) {
            [parameters setValue:item.value forKey:outKey];
            return;
        }
    }
}

-(void)addParam:(nonnull NSMutableDictionary<NSString *, id> *)parameters
    fromPayload:(nonnull id<BatchEventDispatcherPayload>)payload
        fromKey:(nonnull NSString*)fromKey
         outKey:(nonnull NSString*)outKey
{
    NSObject *value = [payload customValueForKey:fromKey];
    if (value != nil) {
        [parameters setValue:value forKey:outKey];
    }
}

- (nonnull NSString*)stringFromEventType:(BatchEventDispatcherType)eventType
{
    switch (eventType) {
        case BatchEventDispatcherTypeNotificationOpen:
            return @"batch_notification_open";
        case BatchEventDispatcherTypeMessagingShow:
            return @"batch_in_app_show";
        case BatchEventDispatcherTypeMessagingClose:
            return @"batch_in_app_close";
        case BatchEventDispatcherTypeMessagingAutoClose:
            return @"batch_in_app_auto_close";
        case BatchEventDispatcherTypeMessagingClick:
            return @"batch_in_app_click";
        default:
            return @"batch_unknown";
    }
}

@end


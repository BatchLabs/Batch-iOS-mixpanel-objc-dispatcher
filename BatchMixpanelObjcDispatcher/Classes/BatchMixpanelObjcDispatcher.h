#import <Batch/Batch.h>
#import <Batch/BatchEventDispatcher.h>
#import <Mixpanel/Mixpanel.h>

@interface BatchMixpanelObjcDispatcher : NSObject <BatchEventDispatcherDelegate>

@property (nonatomic, strong, readwrite, nullable) Mixpanel *mixpanelInstance;

+ (nonnull instancetype)instance;

@end

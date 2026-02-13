#import "DemoResult.h"

@implementation DemoResult

+ (instancetype)resultWithTitle:(NSString *)title detail:(NSString *)detail success:(BOOL)success {
    DemoResult *result = [[DemoResult alloc] init];
    result.title = title;
    result.detail = detail;
    result.success = success;
    return result;
}

@end
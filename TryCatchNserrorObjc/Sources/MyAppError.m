#import "MyAppError.h"

NSString *const MyAppErrorDomain = @"com.myapp.error";

NSError *MakeError(MyAppErrorCode code, NSString *description, NSError *underlying) {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NSLocalizedDescriptionKey] = description;
    if (underlying) {
        userInfo[NSUnderlyingErrorKey] = underlying;
    }
    return [NSError errorWithDomain:MyAppErrorDomain code:code userInfo:userInfo];
}
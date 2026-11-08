#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MyAppErrorCode) {
    MyAppErrorCodeUnknown = 0,
    MyAppErrorCodeFileMissing = 1,
    MyAppErrorCodeOperationFailed = 2,
};

FOUNDATION_EXPORT NSString *const MyAppErrorDomain;

FOUNDATION_EXPORT NSError *MakeError(MyAppErrorCode code, NSString *description, NSError *underlying);
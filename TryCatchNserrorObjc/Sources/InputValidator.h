#import <Foundation/Foundation.h>

@interface InputValidator : NSObject

@property (nonatomic, copy) NSString *name;

- (void)validateInput:(NSString *)input;
- (BOOL)validateInputSafely:(NSString *)input error:(NSError **)error;

@end
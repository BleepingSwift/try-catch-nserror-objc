#import "InputValidator.h"

@implementation InputValidator

- (void)validateInput:(NSString *)input {
    if (input.length == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Input cannot be empty"
                                     userInfo:nil];
    }
}

- (BOOL)validateInputSafely:(NSString *)input error:(NSError **)error {
    if (input.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:@"ValidationError"
                                         code:100
                                     userInfo:@{NSLocalizedDescriptionKey: @"Input cannot be empty"}];
        }
        return NO;
    }
    return YES;
}

- (void)setName:(NSString *)name {
    NSParameterAssert(name != nil);
    _name = [name copy];
}

@end
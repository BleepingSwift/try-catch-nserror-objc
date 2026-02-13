#import "FileProcessor.h"

@implementation FileProcessor

- (BOOL)processFile:(NSString *)path error:(NSError **)error {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if (!handle) {
        if (error) {
            *error = [NSError errorWithDomain:@"FileError"
                                         code:1
                                     userInfo:@{NSLocalizedDescriptionKey: @"Cannot open file"}];
        }
        return NO;
    }

    BOOL success = [self processHandle:handle error:error];
    [handle closeFile];
    return success;
}

- (BOOL)processHandle:(NSFileHandle *)handle error:(NSError **)error {
    NSData *data = [handle availableData];
    if (data.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:@"FileError"
                                         code:2
                                     userInfo:@{NSLocalizedDescriptionKey: @"File is empty"}];
        }
        return NO;
    }
    return YES;
}

@end
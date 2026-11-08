#import "ErrorDemo.h"
#import "MyAppError.h"
#import "Tracker.h"

@implementation ErrorDemo {
    NSMutableString *_log;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("com.myapp.loader", DISPATCH_QUEUE_SERIAL);
        _log = [NSMutableString string];
    }
    return self;
}

#pragma mark - Exceptions

- (void)riskyOperation {
    NSArray *items = @[@"a", @"b"];
    // Index out of bounds raises NSRangeException: a programmer error.
    NSLog(@"%@", items[(NSUInteger)items.count + 3]);
}

- (void)cleanup {
    [_log appendString:@"@finally: cleanup ran\n"];
}

- (NSString *)runTryCatchDemo {
    [_log setString:@""];
    @try {
        [self riskyOperation];
    }
    @catch (NSException *exception) {
        NSLog(@"Caught: %@", exception.reason);
        [_log appendFormat:@"Caught %@:\n%@\n", exception.name, exception.reason];
    }
    @finally {
        [self cleanup];
    }
    return [_log copy];
}

- (NSString *)runLeakDemo {
    [Tracker resetCount];
    @autoreleasepool {
        @try {
            frameHoldingObject();
        }
        @catch (NSException *exception) {
            NSLog(@"Caught: %@", exception.reason);
        }
    }
    int count = [Tracker deallocCount];
    return [NSString stringWithFormat:
            @"Tracker deallocs after unwinding: %d\n\n%@",
            count,
            count == 0
            ? @"Leaked. ARC does not release objects on frames unwound by @throw unless the file is built with -fobjc-arc-exceptions."
            : @"Released. This file was built with -fobjc-arc-exceptions."];
}

#pragma mark - NSError

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

    [handle closeFile];
    return YES;
}

- (NSString *)runProcessFileDemo {
    NSString *missing = [NSTemporaryDirectory() stringByAppendingPathComponent:@"does-not-exist.txt"];
    NSError *error;
    if (![self processFile:missing error:&error]) {
        return [NSString stringWithFormat:@"processFile failed\ndomain: %@\ncode: %ld\n%@",
                error.domain, (long)error.code, error.localizedDescription];
    }
    return @"processFile succeeded";
}

- (NSString *)runReadDataDemo {
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"missing-data.bin"];
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];
    if (!data) {
        NSLog(@"Failed: %@", error.localizedDescription);
        return [NSString stringWithFormat:@"Failed: %@\n(check the return value, not the error)",
                error.localizedDescription];
    }
    return [NSString stringWithFormat:@"Read %lu bytes", (unsigned long)data.length];
}

- (NSString *)runCustomErrorDemo {
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"config.json"];
    NSError *underlying;
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&underlying];
    if (data) {
        return @"Config loaded";
    }
    NSError *error = MakeError(MyAppErrorCodeFileMissing, @"The configuration file is missing.", underlying);
    NSError *cause = error.userInfo[NSUnderlyingErrorKey];
    return [NSString stringWithFormat:@"%@ (%ld)\n%@\n\nUnderlying: %@ %ld",
            error.domain, (long)error.code, error.localizedDescription,
            cause.domain, (long)cause.code];
}

#pragma mark - Async

// Anti-pattern from the article: the block runs after this method returns,
// so *error points at a stack slot that no longer exists. Never call this.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wblock-capture-autoreleasing"
- (void)loadDataAsync:(NSError **)error {
    dispatch_async(self.queue, ^{
        NSError *loadError;
        if (loadError && error) {
            *error = loadError;
        }
    });
}
#pragma clang diagnostic pop

// The fix: hand the error to a completion handler instead.
- (void)loadDataWithCompletion:(void (^)(NSData *data, NSError *error))completion {
    dispatch_async(self.queue, ^{
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"remote-cache.bin"];
        NSError *underlying;
        NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&underlying];
        NSError *error = data ? nil : MakeError(MyAppErrorCodeOperationFailed, @"Loading failed.", underlying);
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(data, error);
        });
    });
}

#pragma mark - Programmer errors

- (void)setName:(NSString *)name {
    NSParameterAssert(name != nil);
    _name = [name copy];
}

- (NSString *)runParameterAssertDemo {
    NSString *nilName = nil;
    @try {
        self.name = nilName;
    }
    @catch (NSException *exception) {
        return [NSString stringWithFormat:@"NSParameterAssert raised %@:\n%@\n\nIn Release builds (NS_BLOCK_ASSERTIONS) this check is compiled out.",
                exception.name, exception.reason];
    }
    return [NSString stringWithFormat:@"No assertion fired (assertions disabled). name = %@", self.name];
}

@end
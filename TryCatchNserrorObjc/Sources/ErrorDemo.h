#import <Foundation/Foundation.h>

@interface ErrorDemo : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong, readonly) dispatch_queue_t queue;

// Exceptions
- (NSString *)runTryCatchDemo;
- (NSString *)runLeakDemo;

// NSError
- (BOOL)processFile:(NSString *)path error:(NSError **)error;
- (NSString *)runProcessFileDemo;
- (NSString *)runReadDataDemo;
- (NSString *)runCustomErrorDemo;

// Async: the anti-pattern and the fix
- (void)loadDataAsync:(NSError **)error;
- (void)loadDataWithCompletion:(void (^)(NSData *data, NSError *error))completion;

// Programmer errors
- (NSString *)runParameterAssertDemo;

@end
#import <Foundation/Foundation.h>

@interface FileProcessor : NSObject

- (BOOL)processFile:(NSString *)path error:(NSError **)error;
- (BOOL)processHandle:(NSFileHandle *)handle error:(NSError **)error;

@end
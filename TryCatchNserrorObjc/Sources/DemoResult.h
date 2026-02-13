#import <Foundation/Foundation.h>

@interface DemoResult : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, assign) BOOL success;

+ (instancetype)resultWithTitle:(NSString *)title detail:(NSString *)detail success:(BOOL)success;

@end
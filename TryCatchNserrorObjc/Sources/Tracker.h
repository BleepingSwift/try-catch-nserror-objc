#import <Foundation/Foundation.h>

/// Counts deallocations so the demo can show whether an object
/// on a frame unwound by @throw was released.
@interface Tracker : NSObject

+ (int)deallocCount;
+ (void)resetCount;

@end

/// Allocates a Tracker, then throws before the frame returns.
FOUNDATION_EXPORT void frameHoldingObject(void);
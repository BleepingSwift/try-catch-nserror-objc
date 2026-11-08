#import "Tracker.h"

static int deallocs = 0;

@implementation Tracker

+ (int)deallocCount { return deallocs; }
+ (void)resetCount { deallocs = 0; }

- (void)dealloc { deallocs++; }

@end

static void thrower(void) {
    @throw [NSException exceptionWithName:NSGenericException
                                   reason:@"boom"
                                 userInfo:nil];
}

void frameHoldingObject(void) {
    Tracker *tracker = [Tracker new];
    thrower();
    NSLog(@"%@", tracker);
}
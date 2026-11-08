#import "ViewController.h"
#import "ErrorDemo.h"

@interface ViewController ()
@property (nonatomic, strong) ErrorDemo *demo;
@property (nonatomic, strong) UITextView *output;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"try-catch vs NSError";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.demo = [[ErrorDemo alloc] init];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 8;
    stack.translatesAutoresizingMaskIntoConstraints = NO;

    NSArray<NSString *> *titles = @[@"@try / @catch / @finally",
                                    @"Exception leak check",
                                    @"processFile:error:",
                                    @"NSData read error",
                                    @"Custom domain + underlying",
                                    @"Async completion handler",
                                    @"NSParameterAssert"];
    [titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:title forState:UIControlStateNormal];
        button.tag = (NSInteger)idx;
        [button addTarget:self action:@selector(runDemo:) forControlEvents:UIControlEventTouchUpInside];
        [stack addArrangedSubview:button];
    }];

    self.output = [[UITextView alloc] init];
    self.output.editable = NO;
    self.output.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightRegular];
    self.output.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.output.layer.cornerRadius = 8;
    self.output.text = @"Tap a demo.";
    self.output.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:stack];
    [self.view addSubview:self.output];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:safe.topAnchor constant:16],
        [stack.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:16],
        [stack.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-16],
        [self.output.topAnchor constraintEqualToAnchor:stack.bottomAnchor constant:16],
        [self.output.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:16],
        [self.output.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-16],
        [self.output.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-16],
    ]];
}

- (void)runDemo:(UIButton *)sender {
    switch (sender.tag) {
        case 0: self.output.text = [self.demo runTryCatchDemo]; break;
        case 1: self.output.text = [self.demo runLeakDemo]; break;
        case 2: self.output.text = [self.demo runProcessFileDemo]; break;
        case 3: self.output.text = [self.demo runReadDataDemo]; break;
        case 4: self.output.text = [self.demo runCustomErrorDemo]; break;
        case 5: {
            self.output.text = @"Loading...";
            __weak typeof(self) weakSelf = self;
            [self.demo loadDataWithCompletion:^(NSData *data, NSError *error) {
                weakSelf.output.text = data
                    ? [NSString stringWithFormat:@"Loaded %lu bytes", (unsigned long)data.length]
                    : [NSString stringWithFormat:@"Completion got error:\n%@ (%ld)\n%@",
                       error.domain, (long)error.code, error.localizedDescription];
            }];
            break;
        }
        case 6: self.output.text = [self.demo runParameterAssertDemo]; break;
        default: break;
    }
}

@end
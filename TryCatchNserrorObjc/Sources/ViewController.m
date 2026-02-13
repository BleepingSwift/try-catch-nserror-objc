#import "ViewController.h"
#import "FileProcessor.h"
#import "InputValidator.h"
#import "DemoResult.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<DemoResult *> *results;
@property (nonatomic, strong) UILabel *headerLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"@try/@catch vs NSError";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.results = [NSMutableArray array];

    [self setupHeader];
    [self setupTableView];
    [self setupToolbar];
}

- (void)setupHeader {
    self.headerLabel = [[UILabel alloc] init];
    self.headerLabel.text = @"Tap \"Run All Demos\" to see @try/@catch and NSError patterns side by side.";
    self.headerLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    self.headerLabel.textColor = [UIColor secondaryLabelColor];
    self.headerLabel.numberOfLines = 0;
    self.headerLabel.textAlignment = NSTextAlignmentCenter;
    self.headerLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:self.headerLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.headerLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12],
        [self.headerLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.headerLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ResultCell"];

    [self.view addSubview:self.tableView];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.headerLabel.bottomAnchor constant:8],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
}

- (void)setupToolbar {
    UIBarButtonItem *runButton = [[UIBarButtonItem alloc] initWithTitle:@"Run All Demos"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(runAllDemos)];
    self.navigationItem.rightBarButtonItem = runButton;
}

#pragma mark - Demo Runners

- (void)runAllDemos {
    [self.results removeAllObjects];

    [self demoTryCatch];
    [self demoThrowException];
    [self demoNSErrorPattern];
    [self demoFileReadWithNSError];
    [self demoNSParameterAssert];
    [self demoMemoryLeakScenario];

    [self.tableView reloadData];
}

- (void)demoTryCatch {
    @try {
        [self riskyOperation];
    }
    @catch (NSException *exception) {
        NSString *detail = [NSString stringWithFormat:@"Caught: %@", exception.reason];
        [self.results addObject:[DemoResult resultWithTitle:@"@try/@catch - Exception Caught"
                                                    detail:detail
                                                   success:NO]];
    }
    @finally {
        [self cleanup];
    }
}

- (void)demoThrowException {
    InputValidator *validator = [[InputValidator alloc] init];

    @try {
        [validator validateInput:@""];
    }
    @catch (NSException *exception) {
        NSString *detail = [NSString stringWithFormat:@"%@: %@", exception.name, exception.reason];
        [self.results addObject:[DemoResult resultWithTitle:@"@throw - Validation Exception"
                                                    detail:detail
                                                   success:NO]];
    }

    @try {
        [validator validateInput:@"Hello"];
        [self.results addObject:[DemoResult resultWithTitle:@"@throw - Valid Input"
                                                    detail:@"No exception thrown for non-empty input"
                                                   success:YES]];
    }
    @catch (NSException *exception) {
        [self.results addObject:[DemoResult resultWithTitle:@"@throw - Unexpected"
                                                    detail:exception.reason
                                                   success:NO]];
    }
}

- (void)demoNSErrorPattern {
    FileProcessor *processor = [[FileProcessor alloc] init];

    NSError *error = nil;
    BOOL success = [processor processFile:@"/nonexistent/path.txt" error:&error];

    if (!success) {
        NSString *detail = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
        [self.results addObject:[DemoResult resultWithTitle:@"NSError - File Not Found"
                                                    detail:detail
                                                   success:NO]];
    }

    InputValidator *validator = [[InputValidator alloc] init];
    error = nil;
    success = [validator validateInputSafely:@"" error:&error];

    if (!success) {
        NSString *detail = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
        [self.results addObject:[DemoResult resultWithTitle:@"NSError - Validation Failed"
                                                    detail:detail
                                                   success:NO]];
    }

    error = nil;
    success = [validator validateInputSafely:@"Valid text" error:&error];

    if (success) {
        [self.results addObject:[DemoResult resultWithTitle:@"NSError - Validation Passed"
                                                    detail:@"Input accepted without error"
                                                   success:YES]];
    }
}

- (void)demoFileReadWithNSError {
    NSString *path = @"/nonexistent/data.txt";
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];

    if (!data) {
        NSString *detail = [NSString stringWithFormat:@"Failed: %@", error.localizedDescription];
        [self.results addObject:[DemoResult resultWithTitle:@"NSData - Read Error"
                                                    detail:detail
                                                   success:NO]];
    }

    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"demo.txt"];
    [@"Sample content" writeToFile:tempPath atomically:YES encoding:NSUTF8StringEncoding error:nil];

    error = nil;
    data = [NSData dataWithContentsOfFile:tempPath options:0 error:&error];

    if (data) {
        NSString *detail = [NSString stringWithFormat:@"Read %lu bytes from temp file", (unsigned long)data.length];
        [self.results addObject:[DemoResult resultWithTitle:@"NSData - Read Success"
                                                    detail:detail
                                                   success:YES]];
    }
}

- (void)demoNSParameterAssert {
    InputValidator *validator = [[InputValidator alloc] init];

    validator.name = @"Test Name";
    NSString *detail = [NSString stringWithFormat:@"Name set to: %@", validator.name];
    [self.results addObject:[DemoResult resultWithTitle:@"NSParameterAssert - Valid"
                                                detail:detail
                                               success:YES]];

    [self.results addObject:[DemoResult resultWithTitle:@"NSParameterAssert - Info"
                                                detail:@"Passing nil would trigger assertion failure in debug builds"
                                               success:YES]];
}

- (void)demoMemoryLeakScenario {
    void *buffer = malloc(1024);

    @try {
        [self operationThatThrows];
    }
    @catch (NSException *exception) {
        free(buffer);
        buffer = NULL;
        [self.results addObject:[DemoResult resultWithTitle:@"Memory Leak - @try/@catch"
                                                    detail:@"Must free buffer in @catch to avoid leak"
                                                   success:NO]];
    }

    if (buffer) {
        free(buffer);
    }

    buffer = malloc(1024);
    BOOL success = [self operationWithError:NULL];
    free(buffer);

    NSString *detail = success ? @"Buffer freed normally after success" : @"Buffer freed normally after failure";
    [self.results addObject:[DemoResult resultWithTitle:@"Memory Leak - NSError"
                                                detail:[NSString stringWithFormat:@"%@. Normal control flow keeps cleanup simple.", detail]
                                               success:YES]];
}

#pragma mark - Helper Methods

- (void)riskyOperation {
    @throw [NSException exceptionWithName:@"DemoException"
                                   reason:@"Something went wrong in riskyOperation"
                                 userInfo:nil];
}

- (void)operationThatThrows {
    @throw [NSException exceptionWithName:@"LeakDemoException"
                                   reason:@"Exception during buffer processing"
                                 userInfo:nil];
}

- (BOOL)operationWithError:(NSError **)error {
    if (error) {
        *error = [NSError errorWithDomain:@"DemoError"
                                     code:42
                                 userInfo:@{NSLocalizedDescriptionKey: @"Simulated failure"}];
    }
    return NO;
}

- (void)cleanup {
    NSLog(@"Cleanup completed in @finally block");
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.results.count == 0) {
        return nil;
    }
    return @"Results";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultCell" forIndexPath:indexPath];

    DemoResult *result = self.results[indexPath.row];

    UIListContentConfiguration *config = [UIListContentConfiguration subtitleCellConfiguration];
    config.text = result.title;
    config.secondaryText = result.detail;
    config.secondaryTextProperties.numberOfLines = 0;
    config.secondaryTextProperties.color = [UIColor secondaryLabelColor];

    if (result.success) {
        config.image = [UIImage systemImageNamed:@"checkmark.circle.fill"];
        config.imageProperties.tintColor = [UIColor systemGreenColor];
    } else {
        config.image = [UIImage systemImageNamed:@"exclamationmark.triangle.fill"];
        config.imageProperties.tintColor = [UIColor systemOrangeColor];
    }

    cell.contentConfiguration = config;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
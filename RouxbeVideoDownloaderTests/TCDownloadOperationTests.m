//
//  TCDownloadOperationTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/7/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCDownloadOperation.h"

typedef void(^AFHTTPRequestOperationSuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^AFURLConnectionProgressiveOperationProgressBlock)(AFDownloadRequestOperation *operation, NSInteger bytes, long long totalBytes, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile);

@interface AFDownloadRequestOperation (UnitTest)

@property (readwrite, nonatomic, copy) AFURLConnectionProgressiveOperationProgressBlock progressiveDownloadProgress;

@end

@interface TCDownloadOperation (UnitTest)

@property (readwrite, nonatomic, copy) TCDownloadOperationBlock didStartCallback;
@property (readwrite, nonatomic, copy) TCDownloadOperationBlock didUpdateProgressCallback;
@property (readwrite, nonatomic, copy) TCDownloadOperationBlock didFinishCallback;
@property (readwrite, nonatomic, copy) TCDownloadOperationBlock didFailCallback;

@end

@interface TCDownloadOperationTests : XCTestCase

@property (readwrite, nonatomic, strong) TCDownloadOperation *downloadOperation;

@end

@implementation TCDownloadOperationTests

- (void)setUp
{
    [super setUp];

//    id mockFileManager = [self mockFileManagerWithCreateDirectorySuccess:YES];
//    self.downloadOperation = [[TCDownloadOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.example.com"]]
//                                                           destinationURL:[NSURL fileURLWithPath:@"/TestDirectory/Test.mp4" isDirectory:NO]
//                                                                    title:@"Whatever Title"];
//    [mockFileManager stopMocking];
}

- (void)tearDown
{
    self.downloadOperation = nil;

    [super tearDown];
}

#pragma mark - Initialize Tests

- (id)mockFileManagerWithCreateDirectorySuccess:(BOOL)success
{
    id mockFileManager = [OCMockObject niceMockForClass:[NSFileManager class]];
    [[[mockFileManager stub] andReturnValue:@(success)] createDirectoryAtURL:OCMOCK_ANY
                                            withIntermediateDirectories:YES
                                                             attributes:OCMOCK_ANY
                                                                  error:[OCMArg setTo:nil]];
    [[[[mockFileManager stub] classMethod] andReturn:mockFileManager] defaultManager];

    return mockFileManager;
}

- (void)testShouldReturnNilIfFailToCreateDestinationDirectory
{
    id mockFileManager = [self mockFileManagerWithCreateDirectorySuccess:NO];

    TCDownloadOperation *operation = [[TCDownloadOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.example.com"]]
                                                                   destinationURL:[NSURL fileURLWithPath:@"/TestDirectory/Test.mp4" isDirectory:NO]
                                                                            title:@"Whatever Title"];
    XCTAssertNil(operation, @"Should be nil.");

    [mockFileManager stopMocking];
}

- (void)testShouldRaiseExceptionIfRequestIsNil
{
    XCTAssertThrows([[TCDownloadOperation alloc] initWithRequest:nil
                                                  destinationURL:[NSURL fileURLWithPath:@"/TestDirectory/Test.mp4" isDirectory:NO]
                                                           title:@"Whatever"], @"Should raise an exception.");
}

- (void)testShouldRaiseExceptionIfDestinationURLIsNil
{
    XCTAssertThrows([[TCDownloadOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.example.com"]]
                                                  destinationURL:nil
                                                           title:@"Whatever"], @"Should raise an exception.");
}

- (void)testProgressShouldBeIndeterminateAfterInitialize
{
    id mockFileManager = [self mockFileManagerWithCreateDirectorySuccess:YES];

    TCDownloadOperation *operation = [[TCDownloadOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.example.com"]]
                                                                   destinationURL:[NSURL fileURLWithPath:@"/TestDirectory/Test.mp4" isDirectory:NO]
                                                                            title:@"Whatever Title"];

    XCTAssertTrue(operation.progress.isIndeterminate, @"Progress should be indeterminate.");

    [mockFileManager stopMocking];
}

#pragma mark - Notification/Callback Tests

/**
 * Creates and returns a ready to use \c TCDownloadOperation object for testing.
 */
- (TCDownloadOperation *)downloadOperationForTesting
{
    // Mock the NSFileManager so we don't actually end up creating a directory.
    id mockFileManager = [self mockFileManagerWithCreateDirectorySuccess:YES];

    TCDownloadOperation *downloadOperation = [[TCDownloadOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.example.com"]]
                                                                           destinationURL:[NSURL fileURLWithPath:@"/TestDirectory/Test.mp4" isDirectory:NO]
                                                                                    title:@"Whatever Title"];

    [mockFileManager stopMocking];

    return downloadOperation;
}

- (void)testShouldExecuteDidStartBlockWhenDownloadOperationHasStarted
{
    TCDownloadOperation *downloadOperation = [self downloadOperationForTesting];
    id mockOperation = [OCMockObject partialMockForObject:downloadOperation];
    [[[mockOperation stub] andPost:[NSNotification notificationWithName:AFNetworkingOperationDidStartNotification object:downloadOperation]] start];
    [[mockOperation expect] didStartCallback];

    [mockOperation start];

    [mockOperation verify];

    [mockOperation stopMocking];
}

- (void)testShouldExecuteDidUpdateProgressBlockWhenDownloadOperationHasMadeProgress
{
    TCDownloadOperation *downloadOperation = [self downloadOperationForTesting];
    id mockOperation = [OCMockObject partialMockForObject:downloadOperation];
    [[mockOperation expect] didUpdateProgressCallback];

    // Calling AFDownloadRequestOperation's progressiveDownloadProgress block,
    // should execute TCDownloadOperation didUpdateProgressCallback block.
    downloadOperation.progressiveDownloadProgress(self.downloadOperation, 0, 0, 0, 0, 0);

    [mockOperation verify];

    [mockOperation stopMocking];
}

- (void)testShouldExecuteDidFinishBlockWhenDownloadOperationHasFinished
{
    TCDownloadOperation *downloadOperation = [self downloadOperationForTesting];
    id mockOperation = [OCMockObject partialMockForObject:downloadOperation];
    [[mockOperation expect] didFinishCallback];

    XCTFail(@"Must use expecta to test asycnhronous result.");

    [mockOperation verify];

    [mockOperation stopMocking];
}

- (void)testShouldExecuteDidFailBlockWhenDownloadOperationHasFailed
{
    TCDownloadOperation *downloadOperation = [self downloadOperationForTesting];
    id mockOperation = [OCMockObject partialMockForObject:downloadOperation];
    [[mockOperation expect] didFailCallback];

    XCTFail(@"Must use expecta to test asycnhronous result.");

    [mockOperation verify];

    [mockOperation stopMocking];
}

#pragma mark - Localized Progress Description Tests

/**
 * Returns an indeterminate \c NSProgress for testing.
 */
- (NSProgress *)fakeIndeterminateProgress
{
    NSProgress *progress = [[NSProgress alloc] initWithParent:nil
                                                         userInfo:@{NSProgressFileOperationKindKey: NSProgressFileOperationKindDownloading}];
    progress.kind = NSProgressKindFile;
    progress.completedUnitCount = -1;
    progress.totalUnitCount = -1;

    return progress;
}

/**
 * Returns a determinate \c NSProgress for testing.
 */
- (NSProgress *)fakeProgress
{
    NSProgress *progress = [self fakeIndeterminateProgress];
    progress.completedUnitCount = 1024 * 1024;
    progress.totalUnitCount = 10 * 1024 * 1024;

    return progress;
}

/**
 * Returns a \c NSProgress with the given error code for testing.
 */
- (NSError *)fakeErrorWithCode:(NSInteger)code
{
    return [NSError errorWithDomain:NSURLErrorDomain
                               code:code
                           userInfo:nil];
}

- (void)testProgressDescriptionForReadyStateWithIndeterminateProgress
{
    id mockOperation = [OCMockObject partialMockForObject:[[TCDownloadOperation alloc] init]];
    [[[mockOperation stub] andReturnValue:@(YES)] isReady];
    [[[mockOperation stub] andReturn:[self fakeIndeterminateProgress]] progress];

    expect([mockOperation localizedProgressDescription]).to.equal(NSLocalizedString(@"Waiting...", @""));

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForReadyStateWithProgress
{
    id mockOperation = [OCMockObject partialMockForObject:[[TCDownloadOperation alloc] init]];
    [[[mockOperation stub] andReturnValue:@(YES)] isReady];

    NSProgress *fakeProgress = [self fakeProgress];
    [[[mockOperation stub] andReturn:fakeProgress] progress];

    NSString *expectedString = [NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"Waiting...", @""), fakeProgress.localizedAdditionalDescription];
    expect([mockOperation localizedProgressDescription]).to.equal(expectedString);

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForExecutingStateWithIndeterminateProgress
{
    id mockOperation = [OCMockObject partialMockForObject:[[TCDownloadOperation alloc] init]];
    [[[mockOperation stub] andReturnValue:@(YES)] isExecuting];
    [[[mockOperation stub] andReturn:[self fakeIndeterminateProgress]] progress];

    expect([mockOperation localizedProgressDescription]).to.equal(NSLocalizedString(@"Starting...", @""));

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForExecutingStateWithProgress
{
    id mockOperation = [OCMockObject partialMockForObject:[[TCDownloadOperation alloc] init]];
    [[[mockOperation stub] andReturnValue:@(YES)] isExecuting];

    NSProgress *fakeProgress = [self fakeProgress];
    [[[mockOperation stub] andReturn:fakeProgress] progress];

    expect([mockOperation localizedProgressDescription]).to.equal(fakeProgress.localizedAdditionalDescription);

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForFinishedStateWithError
{
    id mockOperation = [OCMockObject partialMockForObject:[[TCDownloadOperation alloc] init]];
    [[[mockOperation stub] andReturnValue:@(YES)] isFinished];

    NSError *fakeError = [self fakeErrorWithCode:NSURLErrorTimedOut];
    [[[mockOperation stub] andReturn:fakeError] error];

    NSString *expectedString = [NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"Error", @""), fakeError.localizedDescription];
    expect([mockOperation localizedProgressDescription]).to.equal(expectedString);

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForCancelledStateWithIndeterminateProgress
{
    id mockOperation = [OCMockObject partialMockForObject:[[TCDownloadOperation alloc] init]];
    [[[mockOperation stub] andReturnValue:@(YES)] isFinished];
    [[[mockOperation stub] andReturn:[self fakeIndeterminateProgress]] progress];
    [[[mockOperation stub] andReturn:[self fakeErrorWithCode:NSURLErrorCancelled]] error];

    NSString *expectedString = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Cancelled", @"")];
    expect([mockOperation localizedProgressDescription]).to.equal(expectedString);

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForCancelledStateWithProgress
{
    id mockOperation = [OCMockObject partialMockForObject:[[TCDownloadOperation alloc] init]];
    [[[mockOperation stub] andReturnValue:@(YES)] isFinished];
    [[[mockOperation stub] andReturn:[self fakeErrorWithCode:NSURLErrorCancelled]] error];

    NSProgress *fakeProgress = [self fakeProgress];
    [[[mockOperation stub] andReturn:fakeProgress] progress];

    NSString *expectedString = [NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"Cancelled", @""), fakeProgress.localizedAdditionalDescription];
    expect([mockOperation localizedProgressDescription]).to.equal(expectedString);

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForFinishedStateWithIndeterminateProgress
{
    id mockOperation = [OCMockObject partialMockForObject:[[TCDownloadOperation alloc] init]];
    [[[mockOperation stub] andReturnValue:@(YES)] isFinished];
    [[[mockOperation stub] andReturn:[self fakeIndeterminateProgress]] progress];

    expect([mockOperation localizedProgressDescription]).to.equal(NSLocalizedString(@"Completed",@""));

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForFinishedStateWithProgress
{
    id mockOperation = [OCMockObject partialMockForObject:[[TCDownloadOperation alloc] init]];
    [[[mockOperation stub] andReturnValue:@(YES)] isFinished];

    NSProgress *fakeProgress = [self fakeProgress];
    [[[mockOperation stub] andReturn:fakeProgress] progress];

    NSString *expectedString = [NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"Completed",@""), fakeProgress.localizedAdditionalDescription];
    expect([mockOperation localizedProgressDescription]).to.equal(expectedString);

    [mockOperation stopMocking];
}

@end

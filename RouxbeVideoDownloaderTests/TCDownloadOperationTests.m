//
//  TCDownloadOperationTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/7/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCDownloadOperation.h"

typedef void (^AFURLConnectionProgressiveOperationProgressBlock)(AFDownloadRequestOperation *operation, NSInteger bytes, long long totalBytes, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile);

@interface AFDownloadRequestOperation (UnitTest)
@property (readwrite, nonatomic, copy) AFURLConnectionProgressiveOperationProgressBlock progressiveDownloadProgress;
@end

@interface TCDownloadOperationTests : XCTestCase

@property (readonly, nonatomic, copy) NSURLRequest *dummyRequest;
@property (readonly, nonatomic, copy) NSURL *dummyDestinationURL;
@property (readonly, nonatomic, copy) NSString *dummyTitle;

@end

@implementation TCDownloadOperationTests

- (void)setUp
{
    [super setUp];

    _dummyRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.example.com"]];
    _dummyDestinationURL = [NSURL fileURLWithPath:@"/TestDirectory/Test.mp4" isDirectory:NO];
    _dummyTitle = @"Whatever Title";
}

- (void)tearDown
{
    _dummyRequest = nil;
    _dummyDestinationURL = nil;
    _dummyTitle = nil;

    [super tearDown];
}

#pragma mark - Init Download Operation Tests

/**
 * Creates and return a mock \c NSFileManager object.
 *
 * @param success The \c BOOL value that should be returned from stubbed method 
 *                \c createDirectoryAtURL:withIntermediateDirectories:attributes:error:.
 */
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

- (void)testShouldCreateDestinationDirectoryAfterInitialize
{
    id mockFileManager = [OCMockObject niceMockForClass:[NSFileManager class]];
    [[[[mockFileManager stub] classMethod] andReturn:mockFileManager] defaultManager];

    [[[mockFileManager expect] ignoringNonObjectArgs] createDirectoryAtURL:OCMOCK_ANY
                                               withIntermediateDirectories:YES
                                                                attributes:OCMOCK_ANY
                                                                     error:[OCMArg setTo:nil]];

    __unused id operation = [[TCDownloadOperation alloc] initWithRequest:self.dummyRequest
                                                          destinationURL:self.dummyDestinationURL
                                                                   title:self.dummyTitle];

    [mockFileManager verify];

    [mockFileManager stopMocking];
}

- (void)testProgressShouldBeIndeterminateAfterInitialize
{
    id mockFileManager = [self mockFileManagerWithCreateDirectorySuccess:YES];

    TCDownloadOperation *operation = [[TCDownloadOperation alloc] initWithRequest:self.dummyRequest
                                                                   destinationURL:self.dummyDestinationURL
                                                                            title:self.dummyTitle];

    expect(operation.progress.isIndeterminate).to.beTruthy();

    [mockFileManager stopMocking];
}

- (void)testShouldReturnNilIfFailToCreateDestinationDirectory
{
    id mockFileManager = [self mockFileManagerWithCreateDirectorySuccess:NO];
    TCDownloadOperation *downloadOperation = [[TCDownloadOperation alloc] initWithRequest:self.dummyRequest
                                                                           destinationURL:self.dummyDestinationURL
                                                                                    title:self.dummyTitle];

    expect(downloadOperation).to.beNil();

    [mockFileManager stopMocking];
}

- (void)testShouldRaiseExceptionIfRequestIsNil
{
    void(^blockToTest)() = ^() {
        __unused id operation = [[TCDownloadOperation alloc] initWithRequest:nil
                                                              destinationURL:self.dummyDestinationURL
                                                                       title:self.dummyTitle];
    };

    expect(blockToTest).to.raise(NSInternalInconsistencyException);
}

- (void)testShouldRaiseExceptionIfDestinationURLIsNil
{
    void(^blockToTest)() = ^() {
        __unused id operation = [[TCDownloadOperation alloc] initWithRequest:self.dummyRequest
                                                              destinationURL:nil
                                                                       title:self.dummyTitle];
    };

    expect(blockToTest).to.raise(NSInternalInconsistencyException);
}

#pragma mark - Notification/Callback Tests

/**
 * Creates and returns a ready to use \c TCDownloadOperation object for testing.
 */
- (TCDownloadOperation *)downloadOperationForTesting
{
    // Mock the NSFileManager so we don't actually end up creating a directory.
    id mockFileManager = [self mockFileManagerWithCreateDirectorySuccess:YES];

    TCDownloadOperation *downloadOperation = [[TCDownloadOperation alloc] initWithRequest:self.dummyRequest
                                                                           destinationURL:self.dummyDestinationURL
                                                                                    title:self.dummyTitle];

    [mockFileManager stopMocking];

    return downloadOperation;
}

- (void)testShouldCallDidStartBlockWhenDownloadOperationHasStarted
{
    TCDownloadOperation *downloadOperation = [self downloadOperationForTesting];
    id mockOperation = [OCMockObject partialMockForObject:downloadOperation];
    [[[mockOperation stub] andPost:[NSNotification notificationWithName:AFNetworkingOperationDidStartNotification object:downloadOperation]] start];

    __block BOOL isBlockCalled = NO;
    [downloadOperation setDidStartBlock:^(TCDownloadOperation *operation) {
        isBlockCalled = YES;
    }];

    [downloadOperation start];

    expect(isBlockCalled).will.beTruthy();

    [mockOperation stopMocking];
}

- (void)testShouldCallDidUpdateProgressBlockWhenDownloadOperationHasMadeProgress
{
    TCDownloadOperation *downloadOperation = [self downloadOperationForTesting];

    __block BOOL isBlockCalled = NO;
    [downloadOperation setDidUpdateProgressBlock:^(TCDownloadOperation *operation) {
        isBlockCalled = YES;
    }];

    // Calling AFDownloadRequestOperation's progressiveDownloadProgress block,
    // should execute TCDownloadOperation's didUpdateProgressCallback block.
    downloadOperation.progressiveDownloadProgress(downloadOperation, 0, 0, 0, 0, 0);

    expect(isBlockCalled).will.beTruthy();
}

- (void)testShouldExecuteDidFinishBlockWhenDownloadOperationHasFinished
{
    TCDownloadOperation *downloadOperation = [self downloadOperationForTesting];

    __block BOOL isBlockCalled = NO;
    [downloadOperation setDidFinishBlock:^(TCDownloadOperation *operation) {
        isBlockCalled = YES;
    }];

    // Calling NSOperation's completionBlock with no error should call
    // TCDownloadOperation's didFinishCallback block.
    downloadOperation.completionBlock();

    expect(isBlockCalled).will.beTruthy();
}

- (void)testShouldExecuteDidFailBlockWhenDownloadOperationHasFailed
{
    TCDownloadOperation *downloadOperation = [self downloadOperationForTesting];
    id mockOperation = [OCMockObject partialMockForObject:downloadOperation];
    [[[mockOperation stub]
      andReturn:[self dummyErrorWithCode:NSURLErrorTimedOut]] error];

    __block BOOL isBlockCalled = NO;
    [downloadOperation setDidFailBlock:^(TCDownloadOperation *operation) {
        isBlockCalled = YES;
    }];

    // Calling NSOperation's completionBlock with an error should call
    // TCDownloadOperation's didFailCallback block.
    downloadOperation.completionBlock();

    expect(isBlockCalled).will.beTruthy();

    [mockOperation stopMocking];
}

#pragma mark - Localized Progress Description Tests

/**
 * Returns an indeterminate \c NSProgress for testing.
 */
- (NSProgress *)dummyIndeterminateProgress
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
- (NSProgress *)dummyProgress
{
    NSProgress *progress = [self dummyIndeterminateProgress];
    progress.completedUnitCount = 1024 * 1024;
    progress.totalUnitCount = 10 * 1024 * 1024;

    return progress;
}

/**
 * Returns a \c NSProgress with the given error code for testing.
 */
- (NSError *)dummyErrorWithCode:(NSInteger)code
{
    return [NSError errorWithDomain:NSURLErrorDomain
                               code:code
                           userInfo:nil];
}

- (void)testProgressDescriptionForReadyStateWithIndeterminateProgress
{
    id mockOperation = [OCMockObject partialMockForObject:[[TCDownloadOperation alloc] init]];
    [[[mockOperation stub] andReturnValue:@(YES)] isReady];
    [[[mockOperation stub] andReturn:[self dummyIndeterminateProgress]] progress];

    expect([mockOperation localizedProgressDescription]).to.equal(NSLocalizedString(@"Waiting...", @""));

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForReadyStateWithProgress
{
    id mockOperation = [OCMockObject partialMockForObject:[[TCDownloadOperation alloc] init]];
    [[[mockOperation stub] andReturnValue:@(YES)] isReady];

    NSProgress *dummyProgress = [self dummyProgress];
    [[[mockOperation stub] andReturn:dummyProgress] progress];

    NSString *expectedString = [NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"Waiting...", @""), dummyProgress.localizedAdditionalDescription];
    expect([mockOperation localizedProgressDescription]).to.equal(expectedString);

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForExecutingStateWithIndeterminateProgress
{
    id mockOperation = [OCMockObject partialMockForObject:[[TCDownloadOperation alloc] init]];
    [[[mockOperation stub] andReturnValue:@(YES)] isExecuting];
    [[[mockOperation stub] andReturn:[self dummyIndeterminateProgress]] progress];

    expect([mockOperation localizedProgressDescription]).to.equal(NSLocalizedString(@"Starting...", @""));

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForExecutingStateWithProgress
{
    id mockOperation = [OCMockObject partialMockForObject:[[TCDownloadOperation alloc] init]];
    [[[mockOperation stub] andReturnValue:@(YES)] isExecuting];

    NSProgress *fakeProgress = [self dummyProgress];
    [[[mockOperation stub] andReturn:fakeProgress] progress];

    expect([mockOperation localizedProgressDescription]).to.equal(fakeProgress.localizedAdditionalDescription);

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForFinishedStateWithError
{
    id mockOperation = [OCMockObject partialMockForObject:[[TCDownloadOperation alloc] init]];
    [[[mockOperation stub] andReturnValue:@(YES)] isFinished];

    NSError *fakeError = [self dummyErrorWithCode:NSURLErrorTimedOut];
    [[[mockOperation stub] andReturn:fakeError] error];

    NSString *expectedString = [NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"Error", @""), fakeError.localizedDescription];
    expect([mockOperation localizedProgressDescription]).to.equal(expectedString);

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForCancelledStateWithIndeterminateProgress
{
    id mockOperation = [OCMockObject partialMockForObject:[[TCDownloadOperation alloc] init]];
    [[[mockOperation stub] andReturnValue:@(YES)] isFinished];
    [[[mockOperation stub] andReturn:[self dummyIndeterminateProgress]] progress];
    [[[mockOperation stub] andReturn:[self dummyErrorWithCode:NSURLErrorCancelled]] error];

    NSString *expectedString = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Cancelled", @"")];
    expect([mockOperation localizedProgressDescription]).to.equal(expectedString);

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForCancelledStateWithProgress
{
    id mockOperation = [OCMockObject partialMockForObject:[[TCDownloadOperation alloc] init]];
    [[[mockOperation stub] andReturnValue:@(YES)] isFinished];
    [[[mockOperation stub] andReturn:[self dummyErrorWithCode:NSURLErrorCancelled]] error];

    NSProgress *fakeProgress = [self dummyProgress];
    [[[mockOperation stub] andReturn:fakeProgress] progress];

    NSString *expectedString = [NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"Cancelled", @""), fakeProgress.localizedAdditionalDescription];
    expect([mockOperation localizedProgressDescription]).to.equal(expectedString);

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForFinishedStateWithIndeterminateProgress
{
    id mockOperation = [OCMockObject partialMockForObject:[[TCDownloadOperation alloc] init]];
    [[[mockOperation stub] andReturnValue:@(YES)] isFinished];
    [[[mockOperation stub] andReturn:[self dummyIndeterminateProgress]] progress];

    expect([mockOperation localizedProgressDescription]).to.equal(NSLocalizedString(@"Completed",@""));

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForFinishedStateWithProgress
{
    id mockOperation = [OCMockObject partialMockForObject:[[TCDownloadOperation alloc] init]];
    [[[mockOperation stub] andReturnValue:@(YES)] isFinished];

    NSProgress *fakeProgress = [self dummyProgress];
    [[[mockOperation stub] andReturn:fakeProgress] progress];

    NSString *expectedString = [NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"Completed",@""), fakeProgress.localizedAdditionalDescription];
    expect([mockOperation localizedProgressDescription]).to.equal(expectedString);

    [mockOperation stopMocking];
}

@end

//
//  TCDownloadOperationTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/7/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCDownloadOperation.h"

@interface TCDownloadOperationTests : XCTestCase

@property (readwrite, nonatomic, strong) TCDownloadOperation *downloadOperation;

@end

@implementation TCDownloadOperationTests

- (void)setUp
{
    [super setUp];

    self.downloadOperation = [[TCDownloadOperation alloc] init];
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

    TCDownloadOperation *operation = [[TCDownloadOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]
                                                                   destinationURL:[NSURL fileURLWithPath:@"/Test.mp4" isDirectory:NO]
                                                                            title:@"Whatever Title"];
    XCTAssertNil(operation, @"Should be nil.");

    [mockFileManager stopMocking];
}

#pragma mark - Localized Progress Description Tests

- (NSProgress *)mockIndeterminateProgress
{
    NSProgress *progress = [[NSProgress alloc] initWithParent:nil
                                                         userInfo:@{NSProgressFileOperationKindKey: NSProgressFileOperationKindDownloading}];
    progress.kind = NSProgressKindFile;
    progress.completedUnitCount = -1;
    progress.totalUnitCount = -1;

    return progress;
}

- (NSProgress *)mockProgress
{
    NSProgress *progress = [self mockIndeterminateProgress];
    progress.completedUnitCount = 1024 * 1024;
    progress.totalUnitCount = 10 * 1024 * 1024;

    return progress;
}

- (NSError *)mockErrorWithCode:(NSInteger)code
{
    return [NSError errorWithDomain:NSURLErrorDomain
                               code:code
                           userInfo:nil];
}

- (void)testProgressDescriptionForReadyStateWithIndeterminateProgress
{
    id mockOperation = [OCMockObject partialMockForObject:self.downloadOperation];
    [[[mockOperation stub] andReturnValue:@(YES)] isReady];
    [[[mockOperation stub] andReturn:[self mockIndeterminateProgress]] progress];

    XCTAssertTrue([[mockOperation localizedProgressDescription] isEqualToString:NSLocalizedString(@"Waiting...", @"")],
                  @"Should be equals to given string.");

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForReadyStateWithProgress
{
    id mockOperation = [OCMockObject partialMockForObject:self.downloadOperation];
    [[[mockOperation stub] andReturnValue:@(YES)] isReady];

    NSProgress *mockProgress = [self mockProgress];
    [[[mockOperation stub] andReturn:mockProgress] progress];

    NSString *expectedString = [NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"Waiting...", @""), mockProgress.localizedAdditionalDescription];
    XCTAssertTrue([[mockOperation localizedProgressDescription] isEqualToString:expectedString],
                  @"Should be equals to given string.");

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForExecutingStateWithIndeterminateProgress
{
    id mockOperation = [OCMockObject partialMockForObject:self.downloadOperation];
    [[[mockOperation stub] andReturnValue:@(YES)] isExecuting];
    [[[mockOperation stub] andReturn:[self mockIndeterminateProgress]] progress];

    XCTAssertTrue([[mockOperation localizedProgressDescription] isEqualToString:NSLocalizedString(@"Starting...", @"")],
                  @"Should be equals to given string.");

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForExecutingStateWithProgress
{
    id mockOperation = [OCMockObject partialMockForObject:self.downloadOperation];
    [[[mockOperation stub] andReturnValue:@(YES)] isExecuting];

    NSProgress *mockProgress = [self mockProgress];
    [[[mockOperation stub] andReturn:mockProgress] progress];

    XCTAssertTrue([[mockOperation localizedProgressDescription] isEqualToString:mockProgress.localizedAdditionalDescription],
                  @"Should be equals to given string.");

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForFinishedStateWithError
{
    id mockOperation = [OCMockObject partialMockForObject:self.downloadOperation];
    [[[mockOperation stub] andReturnValue:@(YES)] isFinished];

    NSError *mockError = [self mockErrorWithCode:NSURLErrorTimedOut];
    [[[mockOperation stub] andReturn:mockError] error];

    NSString *expectedString = [NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"Error", @""), mockError.localizedDescription];
    XCTAssertTrue([[mockOperation localizedProgressDescription] isEqualToString:expectedString],
                  @"Should be equals to given string.");

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForCancelledStateWithIndeterminateProgress
{
    id mockOperation = [OCMockObject partialMockForObject:self.downloadOperation];
    [[[mockOperation stub] andReturnValue:@(YES)] isFinished];
    [[[mockOperation stub] andReturn:[self mockIndeterminateProgress]] progress];
    [[[mockOperation stub] andReturn:[self mockErrorWithCode:NSURLErrorCancelled]] error];

    NSString *expectedString = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Cancelled", @"")];
    XCTAssertTrue([[mockOperation localizedProgressDescription] isEqualToString:expectedString],
                  @"Should be equals to given string.");

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForCancelledStateWithProgress
{
    id mockOperation = [OCMockObject partialMockForObject:self.downloadOperation];
    [[[mockOperation stub] andReturnValue:@(YES)] isFinished];
    [[[mockOperation stub] andReturn:[self mockErrorWithCode:NSURLErrorCancelled]] error];

    NSProgress *mockProgress = [self mockProgress];
    [[[mockOperation stub] andReturn:mockProgress] progress];

    NSString *expectedString = [NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"Cancelled", @""), mockProgress.localizedAdditionalDescription];
    XCTAssertTrue([[mockOperation localizedProgressDescription] isEqualToString:expectedString],
                  @"Should be equals to given string.");

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForFinishedStateWithIndeterminateProgress
{
    id mockOperation = [OCMockObject partialMockForObject:self.downloadOperation];
    [[[mockOperation stub] andReturnValue:@(YES)] isFinished];
    [[[mockOperation stub] andReturn:[self mockIndeterminateProgress]] progress];

    XCTAssertTrue([[mockOperation localizedProgressDescription] isEqualToString:NSLocalizedString(@"Completed",@"")],
                  @"Should be equals to given string.");

    [mockOperation stopMocking];
}

- (void)testProgressDescriptionForFinishedStateWithProgress
{
    id mockOperation = [OCMockObject partialMockForObject:self.downloadOperation];
    [[[mockOperation stub] andReturnValue:@(YES)] isFinished];

    NSProgress *mockProgress = [self mockProgress];
    [[[mockOperation stub] andReturn:mockProgress] progress];

    NSString *expectedString = [NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"Completed",@""), mockProgress.localizedAdditionalDescription];
    XCTAssertTrue([[mockOperation localizedProgressDescription] isEqualToString:expectedString],
                  @"Should be equals to given string.");

    [mockOperation stopMocking];
}

@end

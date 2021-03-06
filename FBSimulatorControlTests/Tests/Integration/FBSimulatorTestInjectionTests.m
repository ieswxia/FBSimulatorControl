/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>

#import <XCTestBootstrap/XCTestBootstrap.h>

#import <FBSimulatorControl/FBSimulatorControl.h>

#import "CoreSimulatorDoubles.h"
#import "FBSimulatorControlTestCase.h"
#import "FBSimulatorPoolTestCase.h"
#import "FBSimulatorControlFixtures.h"
#import "FBSimulatorControlAssertions.h"

@interface FBSimulatorTestInjection : FBSimulatorControlTestCase <FBTestManagerTestReporter>

@property (nonatomic, strong, readwrite) NSMutableSet *passedMethods;
@property (nonatomic, strong, readwrite) NSMutableSet *failedMethods;

@end

@implementation FBSimulatorTestInjection

#pragma mark Lifecycle

- (void)setUp
{
  [super setUp];
  self.passedMethods = [NSMutableSet set];
  self.failedMethods = [NSMutableSet set];
}

#pragma mark Tests

- (nullable FBSimulator *)assertObtainsBootedSimulatorWithTableSearch
{
  FBSimulator *simulator = [self assertObtainsBootedSimulator];
  if (!simulator) {
    return nil;
  }
  NSError *error = nil;
  BOOL success = [[simulator installApplicationWithPath:self.tableSearchApplication.path] await:&error] != nil;
  XCTAssertNil(error);
  XCTAssertTrue(success);
  return simulator;
}

- (void)assertLaunchesTestWithConfiguration:(FBTestLaunchConfiguration *)testLaunch reporter:(id<FBTestManagerTestReporter>)reporter simulator:(FBSimulator *)simulator
{
  NSError *error = nil;
  id<FBiOSTargetContinuation> operation = [[simulator startTestWithLaunchConfiguration:self.testLaunch reporter:reporter logger:simulator.logger] await:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(operation);

  id result = [operation.completed awaitWithTimeout:20 error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(result);
}

- (void)testInjectsApplicationTestIntoSampleApp
{
  FBSimulator *simulator = [self assertObtainsBootedSimulatorWithTableSearch];
  [self assertLaunchesTestWithConfiguration:self.testLaunch reporter:self simulator:simulator];
  [self assertPassed:@[@"testIsRunningOnIOS", @"testIsRunningInIOSApp", @"testPossibleCrashingOfHostProcess", @"testPossibleStallingOfHostProcess", @"testWillAlwaysPass"]
              failed:@[@"testHostProcessIsMobileSafari", @"testHostProcessIsXctest", @"testIsRunningInMacOSXApp", @"testIsRunningOnMacOSX", @"testWillAlwaysFail"]];
}

- (void)testInjectsApplicationTestIntoSampleAppOnIOS81Simulator
{
  if (FBXcodeConfiguration.isXcode8OrGreater) {
    NSLog(@"Skipping running -[%@ %@] since Xcode 7 or smaller is required", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    return;
  }
  self.simulatorConfiguration = [[FBSimulatorConfiguration withDeviceModel:FBDeviceModeliPhone5] withOSNamed:FBOSVersionNameiOS_8_1];
  FBSimulator *simulator = [self assertObtainsBootedSimulatorWithTableSearch];
  if (!simulator) {
    return;
  }
  [self assertLaunchesTestWithConfiguration:self.testLaunch reporter:self simulator:simulator];
  [self assertPassed:@[@"testIsRunningOnIOS", @"testIsRunningInIOSApp", @"testPossibleCrashingOfHostProcess", @"testPossibleStallingOfHostProcess", @"testWillAlwaysPass"]
              failed:@[@"testHostProcessIsMobileSafari", @"testHostProcessIsXctest", @"testIsRunningInMacOSXApp", @"testIsRunningOnMacOSX", @"testWillAlwaysFail"]];
}

- (void)testInjectsApplicationTestIntoSafari
{
  FBSimulator *simulator = [self assertObtainsBootedSimulator];
  [self assertLaunchesTestWithConfiguration:self.testLaunch reporter:self simulator:simulator];
  [self assertPassed:@[@"testIsRunningOnIOS", @"testIsRunningInIOSApp", @"testHostProcessIsMobileSafari", @"testPossibleCrashingOfHostProcess", @"testPossibleStallingOfHostProcess", @"testWillAlwaysPass"]
              failed:@[@"testHostProcessIsXctest", @"testIsRunningInMacOSXApp", @"testIsRunningOnMacOSX", @"testWillAlwaysFail"]];
}

- (void)testInjectsApplicationTestWithCustomOutputConfiguration
{
  NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:NSUUID.UUID.UUIDString];
  NSString *stdErrPath = [path stringByAppendingPathComponent:@"stderr.log"];
  NSString *stdOutPath = [path stringByAppendingPathComponent:@"stdout.log"];
  FBProcessOutputConfiguration *output = [FBProcessOutputConfiguration configurationWithStdOut:stdOutPath stdErr:stdErrPath error:nil];
  FBApplicationLaunchConfiguration *applicationLaunchConfiguration = [self.safariAppLaunch withOutput:output];
  FBTestLaunchConfiguration *testLaunch = [self.testLaunch withApplicationLaunchConfiguration:applicationLaunchConfiguration];

  FBSimulator *simulator = [self assertObtainsBootedSimulator];
  [self assertLaunchesTestWithConfiguration:testLaunch reporter:self simulator:simulator];

  NSFileManager *fileManager = [NSFileManager defaultManager];
  XCTAssertTrue([fileManager fileExistsAtPath:stdErrPath]);
  XCTAssertTrue([fileManager fileExistsAtPath:stdOutPath]);

  NSString *stdErrContent = [[NSString alloc] initWithContentsOfFile:stdErrPath encoding:NSUTF8StringEncoding error:nil];
  XCTAssertTrue([stdErrContent containsString:@"Started running iOSUnitTestFixtureTests"]);
}

- (void)assertPassed:(NSArray<NSString *> *)passed failed:(NSArray<NSString *> *)failed
{
  XCTAssertEqualObjects(self.passedMethods, [NSSet setWithArray:passed]);
  XCTAssertEqualObjects(self.failedMethods, [NSSet setWithArray:failed]);
}

- (void)testInjectsApplicationTestIntoSampleAppWithJUnitReporter
{
  NSURL *outputFileURL =
      [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID UUID].UUIDString]];
  FBTestManagerTestReporterJUnit *reporter = [FBTestManagerTestReporterJUnit withOutputFileURL:outputFileURL];
  FBSimulator *simulator = [self assertObtainsBootedSimulatorWithInstalledApplication:self.tableSearchApplication];
  [self assertLaunchesTestWithConfiguration:self.testLaunch reporter:reporter simulator:simulator];

  NSURL *fixtureFileURL = [NSURL fileURLWithPath:[FBSimulatorControlFixtures JUnitXMLResult0Path]];
  NSString *expected = [self stringWithContentsOfJUnitResult:fixtureFileURL];
  NSString *actual = [self stringWithContentsOfJUnitResult:outputFileURL];

  XCTAssertEqualObjects(expected, actual);
}

- (void)testInjectsApplicationTestWithTestsToRun
{
  FBSimulator *simulator = [self assertObtainsBootedSimulator];
  FBTestLaunchConfiguration *testLaunch = [[self.testLaunch
    withTestsToRun:[NSSet setWithArray:@[@"iOSUnitTestFixtureTests/testIsRunningOnIOS", @"iOSUnitTestFixtureTests/testWillAlwaysFail"]]]
    withApplicationLaunchConfiguration:self.safariAppLaunch];

  [self assertLaunchesTestWithConfiguration:testLaunch reporter:self simulator:simulator];
  [self assertPassed:@[@"testIsRunningOnIOS"]
              failed:@[@"testWillAlwaysFail"]];
}

- (void)testInjectsApplicationTestWithTestsToSkip
{
  FBSimulator *simulator = [self assertObtainsBootedSimulator];
  FBTestLaunchConfiguration *testLaunch = [[self.testLaunch
    withTestsToSkip:[NSSet setWithArray:@[@"iOSUnitTestFixtureTests/testIsRunningOnIOS", @"iOSUnitTestFixtureTests/testWillAlwaysFail"]]]
    withApplicationLaunchConfiguration:self.safariAppLaunch];

  [self assertLaunchesTestWithConfiguration:testLaunch reporter:self simulator:simulator];
  [self assertPassed:@[@"testIsRunningInIOSApp", @"testHostProcessIsMobileSafari", @"testPossibleCrashingOfHostProcess", @"testPossibleStallingOfHostProcess", @"testWillAlwaysPass"]
              failed:@[@"testHostProcessIsXctest", @"testIsRunningInMacOSXApp", @"testIsRunningOnMacOSX"]];
}

#pragma mark -

- (NSString *)stringWithContentsOfJUnitResult:(NSURL *)path
{
  NSError *error;
  NSString *string = [NSString stringWithContentsOfURL:path encoding:NSUTF8StringEncoding error:&error];
  XCTAssertNil(error);

  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"time=\"[^\"]+\""
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:&error];
  XCTAssertNil(error);

  return [regex stringByReplacingMatchesInString:string
                                         options:0
                                           range:NSMakeRange(0, string.length)
                                    withTemplate:@"time=\"0.00\""];
}

#pragma mark FBTestManagerTestReporter

- (void)testManagerMediatorDidBeginExecutingTestPlan:(FBTestManagerAPIMediator *)mediator
{

}

- (void)testManagerMediator:(FBTestManagerAPIMediator *)mediator testSuite:(NSString *)testSuite didStartAt:(NSString *)startTime
{

}

- (void)testManagerMediator:(FBTestManagerAPIMediator *)mediator testCaseDidFinishForTestClass:(NSString *)testClass method:(NSString *)method withStatus:(FBTestReportStatus)status duration:(NSTimeInterval)duration
{
  switch (status) {
    case FBTestReportStatusPassed:
      [self.passedMethods addObject:method];
      break;
    case FBTestReportStatusFailed:
      [self.failedMethods addObject:method];
    case FBTestReportStatusUnknown:
      break;
  }
}

- (void)testManagerMediator:(FBTestManagerAPIMediator *)mediator testCaseDidFailForTestClass:(NSString *)testClass method:(NSString *)method withMessage:(NSString *)message file:(NSString *)file line:(NSUInteger)line
{

}

- (void)testManagerMediator:(FBTestManagerAPIMediator *)mediator testBundleReadyWithProtocolVersion:(NSInteger)protocolVersion minimumVersion:(NSInteger)minimumVersion
{

}

- (void)testManagerMediator:(FBTestManagerAPIMediator *)mediator testCaseDidStartForTestClass:(NSString *)testClass method:(NSString *)method
{
}

- (void)testManagerMediator:(FBTestManagerAPIMediator *)mediator finishedWithSummary:(FBTestManagerResultSummary *)summary
{
  XCTAssertNotNil(summary.finishTime);
  XCTAssertNotNil(summary.testSuite);
}

- (void)testManagerMediatorDidFinishExecutingTestPlan:(FBTestManagerAPIMediator *)mediator
{

}

@end

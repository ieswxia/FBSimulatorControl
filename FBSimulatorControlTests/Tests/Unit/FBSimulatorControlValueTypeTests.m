/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <FBSimulatorControl/FBSimulatorControl.h>
#import <Carbon/Carbon.h>

#import "FBSimulatorControlFixtures.h"
#import "FBControlCoreValueTestCase.h"

@interface FBSimulatorControlValueTypeTests : FBControlCoreValueTestCase

@end

@implementation FBSimulatorControlValueTypeTests

- (void)testAppLaunchConfigurations
{
  NSArray<FBApplicationLaunchConfiguration *> *values = @[
    self.safariAppLaunch,
    self.tableSearchAppLaunch,
  ];
  [self assertEqualityOfCopy:values];
  [self assertJSONSerialization:values];
  [self assertJSONDeserialization:values];
}

- (void)testAgentLaunchLaunchConfigurations
{
  NSArray<FBAgentLaunchConfiguration *> *values = @[
    self.agentLaunch1,
  ];
  [self assertEqualityOfCopy:values];
  [self assertJSONSerialization:values];
  [self assertJSONDeserialization:values];
}

- (void)testAgentLaunchConfigurations
{
  NSArray<FBAgentLaunchConfiguration *> *values = @[self.agentLaunch1];
  [self assertEqualityOfCopy:values];
  [self assertJSONSerialization:values];
}

- (void)testSimulatorConfigurations
{
  NSArray<FBSimulatorConfiguration *> *values = @[
    FBSimulatorConfiguration.defaultConfiguration,
    [FBSimulatorConfiguration withDeviceModel:FBDeviceModeliPhone5],
    [[FBSimulatorConfiguration withDeviceModel:FBDeviceModeliPad2] withOSNamed:FBOSVersionNameiOS_8_3],
  ];
  [self assertEqualityOfCopy:values];

  [self assertJSONSerialization:values];
}

- (void)testControlConfigurations
{
  NSArray<FBSimulatorControlConfiguration *> *values = @[
    [FBSimulatorControlConfiguration
      configurationWithDeviceSetPath:nil
      options:FBSimulatorManagementOptionsKillSpuriousSimulatorsOnFirstStart],
    [FBSimulatorControlConfiguration
      configurationWithDeviceSetPath:@"/foo/bar"
      options:FBSimulatorManagementOptionsKillAllOnFirstStart | FBSimulatorManagementOptionsKillAllOnFirstStart]
  ];
  [self assertEqualityOfCopy:values];
  [self assertJSONSerialization:values];
}

- (void)testLaunchConfigurations
{
  NSArray<FBSimulatorBootConfiguration *> *values = @[
    [[[FBSimulatorBootConfiguration
      withLocalizationOverride:[FBLocalizationOverride withLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]]]
      withOptions:FBSimulatorBootOptionsEnableDirectLaunch]
      withScale:FBScale75],
    [[FBSimulatorBootConfiguration
      withOptions:FBSimulatorBootOptionsUseNSWorkspace]
      withScale:FBScale25]
  ];
  [self assertEqualityOfCopy:values];
  [self assertJSONSerialization:values];
  [self assertJSONDeserialization:values];
}

- (void)testLaunchConfigurationScaleAppliedToFramebufferConfiguration
{
  FBSimulatorBootConfiguration *launchConfiguration = [[[FBSimulatorBootConfiguration
    withLocalizationOverride:[FBLocalizationOverride withLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]]]
    withOptions:FBSimulatorBootOptionsEnableDirectLaunch]
    withFramebuffer:FBFramebufferConfiguration.defaultConfiguration];
  XCTAssertNotNil(launchConfiguration.framebuffer);
  XCTAssertNil(launchConfiguration.scale);
  XCTAssertNil(launchConfiguration.scale);

  launchConfiguration = [launchConfiguration withScale:FBScale75];
  XCTAssertEqualObjects(launchConfiguration.scale, FBScale75);
  XCTAssertEqualObjects(launchConfiguration.framebuffer.scale, FBScale75);
  XCTAssertNotEqualObjects(launchConfiguration.scale, FBScale50);
  XCTAssertNotEqualObjects(launchConfiguration.framebuffer.scale, FBScale50);
}

- (void)testEncoderConfigurations
{
  NSArray<FBVideoEncoderConfiguration *> *values = @[
    FBVideoEncoderConfiguration.prudentConfiguration,
    FBVideoEncoderConfiguration.defaultConfiguration,
    [[[FBVideoEncoderConfiguration withOptions:FBVideoEncoderOptionsAutorecord | FBVideoEncoderOptionsFinalFrame ] withRoundingMethod:kCMTimeRoundingMethod_RoundTowardZero] withFileType:@"foo"],
    [[[FBVideoEncoderConfiguration withOptions:FBVideoEncoderOptionsImmediateFrameStart] withRoundingMethod:kCMTimeRoundingMethod_RoundTowardNegativeInfinity] withFileType:@"bar"]
  ];
  [self assertEqualityOfCopy:values];
  [self assertJSONSerialization:values];
  [self assertJSONDeserialization:values];
}

- (void)testFramebufferConfigurations
{
  NSArray<FBFramebufferConfiguration *> *values = @[
    FBFramebufferConfiguration.defaultConfiguration,
    [FBFramebufferConfiguration configurationWithScale:FBScale25 encoder:FBVideoEncoderConfiguration.defaultConfiguration imagePath:@"/img.png"],
    [FBFramebufferConfiguration configurationWithScale:FBScale75 encoder:FBVideoEncoderConfiguration.prudentConfiguration imagePath:@"/img.png"],
  ];
  [self assertEqualityOfCopy:values];
  [self assertJSONSerialization:values];
  [self assertJSONDeserialization:values];
}

- (void)testDiagnosticQueries
{
  NSArray<FBDiagnosticQuery *> *values = @[
    [FBDiagnosticQuery all],
    [FBDiagnosticQuery named:@[@"foo", @"bar", @"baz"]],
    [FBDiagnosticQuery filesInApplicationOfBundleID:@"foo.bar.baz" withFilenames:@[@"foo.txt", @"bar.log"]],
    [FBDiagnosticQuery crashesOfType:FBCrashLogInfoProcessTypeCustomAgent | FBCrashLogInfoProcessTypeApplication since:[NSDate dateWithTimeIntervalSince1970:100]],
  ];
  [self assertEqualityOfCopy:values];
  [self assertJSONSerialization:values];
  [self assertJSONDeserialization:values];
}

- (void)testHIDEvents
{
  NSArray<FBSimulatorHIDEvent *> *values = @[
    [FBSimulatorHIDEvent tapAtX:10 y:20],
    [FBSimulatorHIDEvent shortButtonPress:FBSimulatorHIDButtonApplePay],
    [FBSimulatorHIDEvent shortButtonPress:FBSimulatorHIDButtonHomeButton],
    [FBSimulatorHIDEvent shortButtonPress:FBSimulatorHIDButtonLock],
    [FBSimulatorHIDEvent shortButtonPress:FBSimulatorHIDButtonSideButton],
    [FBSimulatorHIDEvent shortButtonPress:FBSimulatorHIDButtonSiri],
    [FBSimulatorHIDEvent shortButtonPress:FBSimulatorHIDButtonHomeButton],
    [FBSimulatorHIDEvent shortKeyPress:kVK_ANSI_W],
    [FBSimulatorHIDEvent shortKeyPress:kVK_ANSI_A],
    [FBSimulatorHIDEvent shortKeyPress:kVK_ANSI_R],
    [FBSimulatorHIDEvent shortKeyPress:kVK_ANSI_I],
    [FBSimulatorHIDEvent shortKeyPress:kVK_ANSI_O],
  ];
  [self assertEqualityOfCopy:values];
  [self assertJSONSerialization:values];
  [self assertJSONDeserialization:values];
}

- (void)testServiceInfo
{
  NSArray<FBServiceInfoConfiguration *> *values = @[
    [FBServiceInfoConfiguration configurationWithServiceName:@"foo.bar.baz"],
    [FBServiceInfoConfiguration configurationWithServiceName:@"boo.bar.baz"],
  ];
  [self assertEqualityOfCopy:values];
  [self assertJSONSerialization:values];
  [self assertJSONDeserialization:values];
}

@end

/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBSimulatorInteraction+Bridge.h"

#import "FBFramebuffer.h"
#import "FBFramebufferVideo.h"
#import "FBSimulator.h"
#import "FBSimulatorBridge.h"
#import "FBSimulatorError.h"
#import "FBSimulatorInteraction+Private.h"

@implementation FBSimulatorInteraction (Bridge)

- (instancetype)startRecordingVideo
{
  return [self interactWithVideo:^ BOOL (NSError **error, FBSimulator *simulator, FBFramebufferVideo *video, dispatch_group_t waitGroup) {
    [video startRecording:waitGroup];
    return YES;
  }];
}

- (instancetype)stopRecordingVideo
{
  return [self interactWithVideo:^ BOOL (NSError **error, FBSimulator *simulator, FBFramebufferVideo *video, dispatch_group_t waitGroup) {
    [video stopRecording:waitGroup];
    return YES;
  }];
}

- (instancetype)tap:(double)x y:(double)y
{
  return [self interactWithBridge:^ BOOL (NSError **error, FBSimulator *simulator, FBSimulatorBridge *bridge) {
    return [bridge tapX:x y:y error:error];
  }];
}

#pragma mark Private

- (instancetype)interactWithBridge:(BOOL (^)(NSError **error, FBSimulator *simulator, FBSimulatorBridge *bridge))block
{
  return [self interactWithBootedSimulator:^ BOOL (NSError **error, FBSimulator *simulator) {
    FBSimulatorBridge *bridge = simulator.bridge;
    if (!bridge) {
      return [[[FBSimulatorError
        describe:@"Simulator does not have a bridge"]
        inSimulator:simulator]
        failBool:error];
    }
    return block(error, simulator, bridge);
  }];
}

- (instancetype)interactWithVideo:(BOOL (^)(NSError **error, FBSimulator *simulator, FBFramebufferVideo *video, dispatch_group_t waitGroup))block
{
  return [self interactWithBootedSimulator:^ BOOL (NSError **error, FBSimulator *simulator) {
    FBFramebufferVideo *video = simulator.bridge.framebuffer.video;
    if (!video) {
      return [[[FBSimulatorError
        describe:@"Simulator Does not have a FBFramebufferVideo instance"]
        inSimulator:simulator]
        failBool:error];
    }
    dispatch_group_t waitGroup = dispatch_group_create();
    if (!block(error, simulator, video, waitGroup)) {
      return NO;
    }
    NSTimeInterval timeout = FBControlCoreGlobalConfiguration.regularTimeout;
    int64_t timeoutInt = ((int64_t) timeout) * ((int64_t) NSEC_PER_SEC);
    long fail = dispatch_group_wait(waitGroup, dispatch_time(DISPATCH_TIME_NOW, timeoutInt));
    if (fail) {
      return [[[FBSimulatorError
        describeFormat:@"Timeout waiting for video interaction to complete in %f seconds", timeout]
        inSimulator:simulator]
        failBool:error];
    }
    return YES;
  }];
}

@end

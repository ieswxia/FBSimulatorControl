/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <FBControlCore/FBiOSTargetFuture.h>

#import <objc/runtime.h>

#import "NSRunLoop+FBControlCore.h"

FBiOSTargetFutureType const FBiOSTargetFutureTypeApplicationLaunch = @"applaunch";

FBiOSTargetFutureType const FBiOSTargetFutureTypeAgentLaunch = @"agentlaunch";

FBiOSTargetFutureType const FBiOSTargetFutureTypeTestLaunch = @"launch_xctest";

@interface FBiOSTargetContinuation_Renamed : NSObject <FBiOSTargetContinuation>

@property (nonatomic, strong, readonly) id<FBiOSTargetContinuation> continuation;

@end

@implementation FBiOSTargetContinuation_Renamed

@synthesize futureType = _futureType;

- (instancetype)initWithAwaitable:(id<FBiOSTargetContinuation>)continuation futureType:(FBiOSTargetFutureType)futureType
{
  self = [super init];
  if (!self) {
    return nil;
  }

  _continuation = continuation;
  _futureType = futureType;

  return self;
}

- (FBFuture<NSNull *> *)completed
{
  return [self.continuation completed];
}

- (FBiOSTargetFutureType)futureType
{
  return _futureType;
}

@end

@interface FBiOSTargetContinuation_Done : NSObject <FBiOSTargetContinuation>

@end

@implementation FBiOSTargetContinuation_Done

@synthesize futureType = _futureType;

- (instancetype)initWithFutureType:(FBiOSTargetFutureType)futureType
{
  self = [super init];
  if (!self) {
    return nil;
  }

  _futureType = futureType;

  return self;
}

- (FBFuture<NSNull *> *)completed
{
  return [FBFuture futureWithResult:NSNull.null];
}

- (FBiOSTargetFutureType)futureType
{
  return _futureType;
}

@end


id<FBiOSTargetContinuation> FBiOSTargetContinuationRenamed(id<FBiOSTargetContinuation> continuation, FBiOSTargetFutureType futureType)
{
  return [[FBiOSTargetContinuation_Renamed alloc] initWithAwaitable:continuation futureType:futureType];
}

id<FBiOSTargetContinuation> FBiOSTargetContinuationDone(FBTerminationHandleType handleType)
{
  return [[FBiOSTargetContinuation_Done alloc] initWithFutureType:handleType];
}

@implementation FBiOSTargetFutureSimple

#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
  return self;
}

#pragma mark JSON

- (nonnull id)jsonSerializableRepresentation
{
  return @{};
}

+ (instancetype)inflateFromJSON:(id)json error:(NSError **)error
{
  return [self new];
}

#pragma mark NSObject

- (BOOL)isEqual:(FBiOSTargetFutureSimple *)configuration
{
  if (![configuration isKindOfClass:self.class]) {
    return NO;
  }
  return YES;
}

- (NSUInteger)hash
{
  return NSStringFromClass(self.class).hash;
}

@end

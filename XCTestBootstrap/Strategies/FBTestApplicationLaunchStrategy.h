/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import <FBControlCore/FBControlCore.h>

NS_ASSUME_NONNULL_BEGIN

@class FBApplicationLaunchConfiguration;

@protocol FBDeviceOperator;
@protocol FBiOSTarget;

/**
 An Application Launch Strategy for Tests.
 */
@interface FBTestApplicationLaunchStrategy : NSObject

#pragma mark Initializers

/**
 Constructs a FBTestApplicationLaunchStrategy.

 @param iosTarget the iOS Target.
 @return a new FBTestApplicationLaunchStrategy instance
 */
+ (instancetype)strategyWithTarget:(id<FBiOSTarget>)iosTarget;

#pragma mark Public Methods

/**
 Request to launch an Application Process.

 @param configuration the configuration of the Application to launch.
 @param path the path of the application on the host filesystem.
 @return A future that resolves when the application has been launched.
 */
- (FBFuture<NSNumber *> *)launchApplication:(FBApplicationLaunchConfiguration *)configuration atPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END

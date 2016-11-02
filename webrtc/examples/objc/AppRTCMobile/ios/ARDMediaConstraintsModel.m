/*
 *  Copyright 2016 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "ARDMediaConstraintsModel+Private.h"
#import "ARDMediaConstraintsSettingsStore.h"
#import "WebRTC/RTCMediaConstraints.h"

NS_ASSUME_NONNULL_BEGIN
static NSArray<NSString *> *videoResolutionsStaticValues() {
  return @[ @"640x480", @"960x540", @"1280x720" ];
}

@interface ARDMediaConstraintsModel () {
  ARDMediaConstraintsSettingsStore *_settingsStore;
}
@end

@implementation ARDMediaConstraintsModel

- (NSArray<NSString *> *)availableVideoResoultionsMediaConstraints {
  return videoResolutionsStaticValues();
}

- (NSString *)currentVideoResoultionConstraintFromStore {
  NSString *constraint = [[self settingsStore] videoResolutionConstraintsSetting];
  if (!constraint) {
    constraint = [self defaultVideoResolutionMediaConstraint];
    // To ensure consistency add the default to the store.
    [[self settingsStore] setVideoResolutionConstraintsSetting:constraint];
  }
  return constraint;
}

- (BOOL)storeVideoResoultionConstraint:(NSString *)constraint {
  if (![[self availableVideoResoultionsMediaConstraints] containsObject:constraint]) {
    return NO;
  }
  [[self settingsStore] setVideoResolutionConstraintsSetting:constraint];
  return YES;
}

#pragma mark - Testable

- (ARDMediaConstraintsSettingsStore *)settingsStore {
  if (!_settingsStore) {
    _settingsStore = [[ARDMediaConstraintsSettingsStore alloc] init];
  }
  return _settingsStore;
}

- (nullable NSString *)currentVideoResolutionWidthFromStore {
  NSString *mediaConstraintFromStore = [self currentVideoResoultionConstraintFromStore];

  return [self videoResolutionComponentAtIndex:0 inConstraintsString:mediaConstraintFromStore];
}

- (nullable NSString *)currentVideoResolutionHeightFromStore {
  NSString *mediaConstraintFromStore = [self currentVideoResoultionConstraintFromStore];
  return [self videoResolutionComponentAtIndex:1 inConstraintsString:mediaConstraintFromStore];
}

#pragma mark -

- (NSString *)defaultVideoResolutionMediaConstraint {
  return videoResolutionsStaticValues()[0];
}

- (nullable NSString *)videoResolutionComponentAtIndex:(int)index
                                   inConstraintsString:(NSString *)constraint {
  if (index != 0 && index != 1) {
    return nil;
  }
  NSArray *components = [constraint componentsSeparatedByString:@"x"];
  if (components.count != 2) {
    return nil;
  }
  return components[index];
}

#pragma mark - Conversion to RTCMediaConstraints

- (nullable NSDictionary *)currentMediaConstraintFromStoreAsRTCDictionary {
  NSDictionary *mediaConstraintsDictionary = nil;

  NSString *widthConstraint = [self currentVideoResolutionWidthFromStore];
  NSString *heightConstraint = [self currentVideoResolutionHeightFromStore];
  if (widthConstraint && heightConstraint) {
    mediaConstraintsDictionary = @{
      kRTCMediaConstraintsMinWidth : widthConstraint,
      kRTCMediaConstraintsMinHeight : heightConstraint
    };
  }
  return mediaConstraintsDictionary;
}

@end
NS_ASSUME_NONNULL_END

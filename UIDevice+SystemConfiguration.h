//
//  UIDevice+SystemConfiguration.h
//  SCPreferences
//
//  Created by Ray Zhang on 13-1-23.
//  Copyright (c) 2013年 Ray Zhang. All rights reserved.
//
//  This Device Categroy Depand on System Configuration Framework 
//  Entitlements which allow access(write) SCPreferences should be added to your project
//

#import <UIKit/UIKit.h>

@interface UIDevice (SystemConfiguration)

- (BOOL)isAirplaneModeOn;
- (void)setAirplaneModeOn:(BOOL)on;

- (BOOL)isWiFiOn;
- (void)setWiFiOn:(BOOL)on;

@end

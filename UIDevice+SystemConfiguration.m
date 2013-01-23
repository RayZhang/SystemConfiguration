//
//  UIDevice+SystemConfiguration.m
//  SCPreferences
//
//  Created by Ray Zhang on 13-1-23.
//  Copyright (c) 2013年 Ray Zhang. All rights reserved.
//
//  This Device Categroy Depand on System Configuration Framework
//  Entitlements which to allow access(write) SCPreferences should be added to your project
//

#import "UIDevice+SystemConfiguration.h"

#import <SystemConfiguration/SystemConfiguration.h>

#define kAirplaneMode CFSTR("AirplaneMode")
#define kWiFi CFSTR("AllowEnable")

#define SCAirplaneID CFSTR("com.apple.radios.plist")
#define SCWiFiID CFSTR("com.apple.wifi.plist")

@implementation UIDevice (SystemConfiguration)

- (CFBooleanRef)systemConfigurationForKey:(CFStringRef)key {
    CFBooleanRef retVal = nil;
    CFStringRef name = (CFStringRef)[[NSBundle mainBundle] bundleIdentifier];
    CFStringRef prefsID = nil;
    if (CFStringCompare(key, kAirplaneMode, kCFCompareAnchored) == kCFCompareEqualTo) {
        prefsID = SCAirplaneID;
    } else if (CFStringCompare(key, kWiFi, kCFCompareAnchored) == kCFCompareEqualTo) {
        prefsID = SCWiFiID;
    }
    
    if (prefsID) {
        SCPreferencesRef preferences = SCPreferencesCreateWithAuthorization(kCFAllocatorDefault, name, prefsID, NULL);
        if (preferences) {
            Boolean result = SCPreferencesLock(preferences, YES);
            if (result == TRUE) {
                retVal = SCPreferencesGetValue(preferences, key);
                SCPreferencesUnlock(preferences);
            }
            CFRelease(preferences);
        }
    }
    
    return retVal;
}

- (void)setSystemConfigurationValue:(CFBooleanRef)value forKey:(CFStringRef)key {
    CFStringRef name = (CFStringRef)[[NSBundle mainBundle] bundleIdentifier];
    CFStringRef prefsID = nil;
    if (CFStringCompare(key, kAirplaneMode, kCFCompareAnchored) == kCFCompareEqualTo) {
        prefsID = SCAirplaneID;
    } else if (CFStringCompare(key, kWiFi, kCFCompareAnchored) == kCFCompareEqualTo) {
        prefsID = SCWiFiID;
    }
    
    if (prefsID) {
        SCPreferencesRef preferences = SCPreferencesCreateWithAuthorization(kCFAllocatorDefault, name, prefsID, NULL);
        if (preferences) {
            Boolean result = SCPreferencesLock(preferences, YES);
            if (result == TRUE) {
                result = SCPreferencesSetValue(preferences, key, value);
                if (result == TRUE) {
                    result = SCPreferencesCommitChanges(preferences);
                    if (result) {
                        result = SCPreferencesApplyChanges(preferences);
                    }
                }
                SCPreferencesUnlock(preferences);
            }
            CFRelease(preferences);
        }
    }
}

- (BOOL)isAirplaneModeOn {
    BOOL retVal = NO;
    CFBooleanRef airplane = [self systemConfigurationForKey:kAirplaneMode];
    if (airplane) {
        if (airplane == kCFBooleanTrue) {
            retVal = YES;
        }
    }
    return retVal;
}

- (void)setAirplaneModeOn:(BOOL)on {
    CFBooleanRef value = kCFBooleanFalse;
    if (on) {
        value = kCFBooleanTrue;
    }
    
    [self setSystemConfigurationValue:value forKey:kAirplaneMode];
}

- (BOOL)isWiFiOn {
    BOOL retVal = NO;
    CFBooleanRef wifi = [self systemConfigurationForKey:kWiFi];
    if (wifi) {
        if (wifi == kCFBooleanTrue) {
            retVal = YES;
        }
    }
    return retVal;
}

- (void)setWiFiOn:(BOOL)on {
    CFBooleanRef value = kCFBooleanFalse;
    if (on) {
        value = kCFBooleanTrue;
    }
    [self setSystemConfigurationValue:value forKey:kWiFi];
}

@end

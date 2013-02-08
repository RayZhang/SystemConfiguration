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
#define kPowerOn CFSTR("RepeatingPowerOn")
#define kPowerOff CFSTR("RepeatingPowerOff")

#define SCAirplaneID CFSTR("com.apple.radios.plist")
#define SCWiFiID CFSTR("com.apple.wifi.plist")
#define SCAutoWakeID CFSTR("com.apple.AutoWake.plist")

@implementation UIDevice (SystemConfiguration)

- (CFTypeRef)systemConfigurationForKey:(CFStringRef)key {
    CFTypeRef retVal = nil;
    CFStringRef name = (CFStringRef)[[NSBundle mainBundle] bundleIdentifier];
    CFStringRef prefsID = nil;
    if (CFStringCompare(key, kAirplaneMode, kCFCompareAnchored) == kCFCompareEqualTo) {
        prefsID = SCAirplaneID;
    } else if (CFStringCompare(key, kWiFi, kCFCompareAnchored) == kCFCompareEqualTo) {
        prefsID = SCWiFiID;
    } else if (!(CFStringCompare(key, kPowerOff, kCFCompareAnchored) && CFStringCompare(key, kPowerOn, kCFCompareAnchored))) {
        prefsID = SCAutoWakeID;
    }
    
    if (prefsID) {
        SCPreferencesRef preferences = SCPreferencesCreateWithAuthorization(kCFAllocatorDefault, name, prefsID, NULL);
        if (preferences) {
            Boolean result = SCPreferencesLock(preferences, TRUE);
            if (result == TRUE) {
                retVal = SCPreferencesGetValue(preferences, key);
                SCPreferencesUnlock(preferences);
            }
            CFRelease(preferences);
        }
    }
    
    return retVal;
}

- (void)setSystemConfigurationValue:(CFTypeRef)value forKey:(CFStringRef)key {
    CFStringRef name = (CFStringRef)[[NSBundle mainBundle] bundleIdentifier];
    CFStringRef prefsID = nil;
    if (CFStringCompare(key, kAirplaneMode, kCFCompareAnchored) == kCFCompareEqualTo) {
        prefsID = SCAirplaneID;
    } else if (CFStringCompare(key, kWiFi, kCFCompareAnchored) == kCFCompareEqualTo) {
        prefsID = SCWiFiID;
    } else if (!(CFStringCompare(key, kPowerOff, kCFCompareAnchored) && CFStringCompare(key, kPowerOn, kCFCompareAnchored))) {
        prefsID = SCAutoWakeID;
    }
    
    if (prefsID) {
        SCPreferencesRef preferences = SCPreferencesCreateWithAuthorization(kCFAllocatorDefault, name, prefsID, NULL);
        if (preferences) {
            Boolean result = SCPreferencesLock(preferences, TRUE);
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

- (void)removeSystemConfigurationForKey:(CFStringRef)key {
    CFStringRef name = (CFStringRef)[[NSBundle mainBundle] bundleIdentifier];
    CFStringRef prefsID = nil;
    if (CFStringCompare(key, kAirplaneMode, kCFCompareAnchored) == kCFCompareEqualTo) {
        prefsID = SCAirplaneID;
    } else if (CFStringCompare(key, kWiFi, kCFCompareAnchored) == kCFCompareEqualTo) {
        prefsID = SCWiFiID;
    } else if (!(CFStringCompare(key, kPowerOff, kCFCompareAnchored) && CFStringCompare(key, kPowerOn, kCFCompareAnchored))) {
        prefsID = SCAutoWakeID;
    }
    
    if (prefsID) {
        SCPreferencesRef preferences = SCPreferencesCreateWithAuthorization(kCFAllocatorDefault, name, prefsID, NULL);
        if (preferences) {
            Boolean result = SCPreferencesLock(preferences, TRUE);
            if (result == TRUE) {
                result = SCPreferencesRemoveValue(preferences, key);
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

- (BOOL)isAutoPowerOnWithKey:(CFStringRef)onOrOff {
    BOOL retVal = NO;
    CFDictionaryRef autoPower = [self systemConfigurationForKey:onOrOff];
    if (autoPower) {
        retVal = YES;
    }
    return NO;
}

- (void)setAutoPowerOnWithKey:(CFStringRef)powerKey time:(NSInteger)minutes {
    if (minutes < 0) {
        [self removeSystemConfigurationForKey:powerKey];
    } else {
        CFStringRef keys[] = {CFSTR("eventtype"), CFSTR("time"), CFSTR("weekdays")};
        
        CFNumberRef timeValue = CFNumberCreate(kCFAllocatorDefault, kCFNumberNSIntegerType, &minutes);
        NSInteger weekdays = 127;
        CFNumberRef weekdaysValue = CFNumberCreate(kCFAllocatorDefault, kCFNumberNSIntegerType, &weekdays);
        CFTypeRef values[] = {CFSTR("shutdown"), timeValue, weekdaysValue};
        
        CFDictionaryRef value = CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)values, 3, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
        [self setSystemConfigurationValue:value forKey:powerKey];
        
        CFRelease(weekdaysValue);
        CFRelease(timeValue);
    }
}

- (BOOL)isAutoPowerOn {
    return [self isAutoPowerOnWithKey:kPowerOn];
}

- (void)setAutoPowerOnTime:(NSInteger)minutes {
    [self setAutoPowerOnWithKey:kPowerOn time:minutes];
}

- (BOOL)isAutoPowerOff {
    return [self isAutoPowerOnWithKey:kPowerOff];
}

- (void)setAutoPowerOffTime:(NSInteger)minutes {
    [self setAutoPowerOnWithKey:kPowerOff time:minutes];
}

@end

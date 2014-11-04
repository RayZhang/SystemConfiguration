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

- (CFTypeRef)systemConfigurationForKey:(CFStringRef)key {
    CFTypeRef retVal = nil;
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

static void callout(SCNetworkConnectionRef connection, SCNetworkConnectionStatus status, void *info) {
    
}

- (BOOL)VPNEnabled {
    BOOL retVal = NO;
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFStringRef bundleIdentifier = CFBundleGetIdentifier(mainBundle);
    SCPreferencesRef preferences = SCPreferencesCreateWithAuthorization(kCFAllocatorDefault, bundleIdentifier, nil, nil);
    if (preferences) {
        CFArrayRef services = SCNetworkServiceCopyAll(preferences);
        if (services) {
            CFIndex i, count = CFArrayGetCount(services);
            for (i = 0; i < count; i++) {
                SCNetworkServiceRef networkServerice = CFArrayGetValueAtIndex(services, i);
                if (SCNetworkServiceGetEnabled(networkServerice)) {
                    SCNetworkInterfaceRef interface = SCNetworkServiceGetInterface(networkServerice);
                    CFStringRef interfaceType = SCNetworkInterfaceGetInterfaceType(interface);
                    if (CFStringCompare(interfaceType, kSCNetworkInterfaceTypePPP, kCFCompareAnchored) == kCFCompareEqualTo || CFStringCompare(interfaceType, kSCNetworkInterfaceTypeIPSec, kCFCompareAnchored) == kCFCompareEqualTo) {
                        if (MCVPNPreferencesLock(preferences)) {
                            SCNetworkConnectionRef connection = SCNetworkConnectionCreateWithServiceID(kCFAllocatorDefault, SCNetworkServiceGetServiceID(networkServerice), NULL, NULL);
                            if (connection) {
                                SCNetworkConnectionStatus connectionStatus = SCNetworkConnectionGetStatus(connection);
                                if (connectionStatus == kSCNetworkConnectionConnecting || connectionStatus == kSCNetworkConnectionConnected) {
                                    retVal = YES;
                                }
                                CFRelease(connection);
                            }
                            MCVPNPreferencesUnlock(preferences);
                        }
                        break;
                    }
                }
            }
            CFRelease(services);
        }
        CFRelease(preferences);
    }
    return retVal;
}

- (void)setVPNEnabled:(BOOL)enabled {
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFStringRef bundleIdentifier = CFBundleGetIdentifier(mainBundle);
    SCPreferencesRef preferences = SCPreferencesCreateWithAuthorization(kCFAllocatorDefault, bundleIdentifier, nil, nil);
    if (preferences) {
        CFArrayRef services = SCNetworkServiceCopyAll(preferences);
        if (services) {
            CFIndex i, count = CFArrayGetCount(services);
            for (i = 0; i < count; i++) {
                SCNetworkServiceRef networkServerice = CFArrayGetValueAtIndex(services, i);
                if (SCNetworkServiceGetEnabled(networkServerice)) {
                    SCNetworkInterfaceRef interface = SCNetworkServiceGetInterface(networkServerice);
                    CFStringRef interfaceType = SCNetworkInterfaceGetInterfaceType(interface);
                    if (CFStringCompare(interfaceType, kSCNetworkInterfaceTypePPP, kCFCompareAnchored) == kCFCompareEqualTo) {
                        if (MCVPNPreferencesLock(preferences)) {
                            SCNetworkConnectionRef connection = SCNetworkConnectionCreateWithServiceID(kCFAllocatorDefault, SCNetworkServiceGetServiceID(networkServerice), callout, NULL);
                            if (connection) {
                                if (SCNetworkConnectionScheduleWithRunLoop(connection, CFRunLoopGetMain(), kCFRunLoopDefaultMode)) {
                                    if (enabled) {
                                        CFStringRef password = MCVPNServiceCopyPassword(networkServerice);
                                        CFStringRef sharedSecret = MCVPNServiceCopySharedSecret(networkServerice);
                                        CFDictionaryRef	userOptions = nil;
                                        if (password) {
                                            NSArray *keys1 = [[NSArray alloc] initWithObjects:(NSString *)kSCPropNetIPSecAuthenticationMethod, (NSString *)kSCPropNetIPSecLocalCertificate, (NSString *)kSCPropNetIPSecLocalIdentifier, (NSString *)kSCPropNetIPSecLocalIdentifierType, (NSString *)kSCPropNetIPSecSharedSecret, (NSString *)kSCPropNetIPSecSharedSecretEncryption, (NSString *)kSCPropNetIPSecConnectTime, (NSString *)kSCPropNetIPSecRemoteAddress, (NSString *)kSCPropNetIPSecStatus, (NSString *)kSCPropNetIPSecXAuthEnabled, (NSString *)kSCPropNetIPSecXAuthName, (NSString *)kSCPropNetIPSecXAuthPassword, (NSString *)kSCPropNetIPSecXAuthPasswordEncryption, nil];
                                            CFMutableDictionaryRef IPSecValue = CFDictionaryCreateMutable(kCFAllocatorDefault, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                                            for (NSString *key in keys1) {
                                                if (CFStringCompare(kSCPropNetIPSecSharedSecret, (CFStringRef)key, kCFCompareAnchored) == kCFCompareEqualTo) {
                                                    if (sharedSecret) {
                                                        CFDictionaryAddValue(IPSecValue, (const void *)key, (const void *)sharedSecret);
                                                    }
                                                } else if (CFStringCompare(kSCPropNetIPSecXAuthPassword, (CFStringRef)key, kCFCompareAnchored) == kCFCompareEqualTo) {
                                                    if (password) {
                                                        CFDictionaryAddValue(IPSecValue, (const void *)key, (const void *)password);
                                                    }
                                                } else {
                                                    CFStringRef value = (CFStringRef)MCVPNServiceGetConfigurationProperty(networkServerice, (CFStringRef)key);
                                                    if (value) {
                                                        CFDictionaryAddValue(IPSecValue, (const void *)key, (const void *)value);
                                                    }
                                                }
                                            }
                                            [keys1 release];
                                            
                                            NSArray *keys2 = [[NSArray alloc] initWithObjects:(NSString *)kSCPropNetPPPAuthName, (NSString *)kSCPropNetPPPAuthPassword, (NSString *)kSCPropNetPPPCommRemoteAddress, nil];
                                            CFMutableDictionaryRef PPPSecValue = CFDictionaryCreateMutable(kCFAllocatorDefault, 3, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                                            for (NSString *key in keys2) {
                                                if (CFStringCompare(kSCPropNetPPPAuthPassword, (CFStringRef)key, kCFCompareAnchored) == kCFCompareEqualTo) {
                                                    if (password) {
                                                        CFDictionaryAddValue(PPPSecValue, (const void *)key, (const void *)password);
                                                    }
                                                } else {
                                                    CFStringRef value = (CFStringRef)MCVPNServiceGetConfigurationProperty(networkServerice, (CFStringRef)key);
                                                    if (value) {
                                                        CFDictionaryAddValue(PPPSecValue, (const void *)key, (const void *)value);
                                                    }
                                                }
                                            }
                                            [keys2 release];
                                            
                                            CFStringRef keys[] = {kSCNetworkInterfaceTypeIPSec, kSCNetworkInterfaceTypePPP};
                                            CFDictionaryRef values[] = {IPSecValue, PPPSecValue};
                                            
                                            userOptions = CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)values, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                                            
                                            CFRelease(IPSecValue);
                                            CFRelease(PPPSecValue);
                                            CFRelease(password);
                                        }
                                        SCNetworkConnectionStart(connection, userOptions, true);
                                        if (userOptions) {
                                            CFRelease(userOptions);
                                        }
                                    } else {
                                        SCNetworkConnectionStop(connection, true);
                                    }
                                    SCNetworkConnectionUnscheduleFromRunLoop(connection, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
                                }
                                CFRelease(connection);
                            }
                            MCVPNPreferencesUnlock(preferences);
                        }
                        break;
                    } else if (CFStringCompare(interfaceType, kSCNetworkInterfaceTypeIPSec, kCFCompareAnchored) == kCFCompareEqualTo) {
                        if (MCVPNPreferencesLock(preferences)) {
                            SCNetworkConnectionRef connection = SCNetworkConnectionCreateWithServiceID(kCFAllocatorDefault, SCNetworkServiceGetServiceID(networkServerice), callout, NULL);
                            if (connection) {
                                if (SCNetworkConnectionScheduleWithRunLoop(connection, CFRunLoopGetMain(), kCFRunLoopDefaultMode)) {
                                    if (enabled) {
                                        CFStringRef password = MCVPNServiceCopyPassword(networkServerice);
                                        CFStringRef sharedSecret = MCVPNServiceCopySharedSecret(networkServerice);
                                        CFDictionaryRef	userOptions = nil;
                                        if (password) {
                                            NSArray *keys1 = [[NSArray alloc] initWithObjects:(NSString *)kSCPropNetIPSecAuthenticationMethod, (NSString *)kSCPropNetIPSecLocalCertificate, (NSString *)kSCPropNetIPSecLocalIdentifier, (NSString *)kSCPropNetIPSecLocalIdentifierType, (NSString *)kSCPropNetIPSecSharedSecret, (NSString *)kSCPropNetIPSecSharedSecretEncryption, (NSString *)kSCPropNetIPSecConnectTime, (NSString *)kSCPropNetIPSecRemoteAddress, (NSString *)kSCPropNetIPSecStatus, (NSString *)kSCPropNetIPSecXAuthEnabled, (NSString *)kSCPropNetIPSecXAuthName, (NSString *)kSCPropNetIPSecXAuthPassword, (NSString *)kSCPropNetIPSecXAuthPasswordEncryption, nil];
                                            CFMutableDictionaryRef IPSecValue = CFDictionaryCreateMutable(kCFAllocatorDefault, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                                            for (NSString *key in keys1) {
                                                if (CFStringCompare(kSCPropNetIPSecSharedSecret, (CFStringRef)key, kCFCompareAnchored) == kCFCompareEqualTo) {
                                                    if (sharedSecret) {
                                                        CFDictionaryAddValue(IPSecValue, (const void *)key, (const void *)sharedSecret);
                                                    }
                                                } else if (CFStringCompare(kSCPropNetIPSecXAuthPassword, (CFStringRef)key, kCFCompareAnchored) == kCFCompareEqualTo) {
                                                    if (password) {
                                                        CFDictionaryAddValue(IPSecValue, (const void *)key, (const void *)password);
                                                    }
                                                } else {
                                                    CFStringRef value = (CFStringRef)MCVPNServiceGetConfigurationProperty(networkServerice, (CFStringRef)key);
                                                    if (value) {
                                                        CFDictionaryAddValue(IPSecValue, (const void *)key, (const void *)value);
                                                    }
                                                }
                                            }
                                            [keys1 release];
                                            
                                            CFDictionaryRef PPPSecValue = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                                            CFStringRef keys[] = {kSCNetworkInterfaceTypeIPSec, kSCNetworkInterfaceTypePPP};
                                            CFDictionaryRef values[] = {IPSecValue, PPPSecValue};
                                            userOptions = CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)values, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                                            CFRelease(IPSecValue);
                                            CFRelease(PPPSecValue);
                                            CFRelease(password);
                                        }
                                        SCNetworkConnectionStart(connection, userOptions, true);
                                        if (userOptions) {
                                            CFRelease(userOptions);
                                        }
                                    } else {
                                        SCNetworkConnectionStop(connection, true);
                                    }
                                    SCNetworkConnectionUnscheduleFromRunLoop(connection, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
                                }
                                CFRelease(connection);
                            }
                            MCVPNPreferencesUnlock(preferences);
                        }
                        break;
                    }
                }
            }
            CFRelease(services);
        }
        CFRelease(preferences);
    }
}

@end

//
//  PRSizeFormatter.m
//  ProjectRhinestone
//
//  Created by Alex Rezit on 15/12/2013.
//  Copyright (c) 2013 Project Rhinestone Committee. All rights reserved.
//

#import "PRSizeFormatter.h"

NSUInteger const kPRSizeFactorDecimal = 1000;
NSUInteger const kPRSizeFactorBinary = 1024;

float const kPRSizeDefaultAbbrevCapMultiplier = 0.9;

@interface PRSizeFormatter ()

@property (assign) NSUInteger factor;

- (NSString *)stringForPrefix:(PRSizePrefix)prefix
                 ofPrefixType:(PRSizePrefixType)prefixType
                     expanded:(BOOL)expanded;
- (NSString *)stringForBaseUnit:(PRSizeBaseUnit)baseUnit
                       expanded:(BOOL)expanded
                         plural:(BOOL)plural;

@end

@implementation PRSizeFormatter

@synthesize standard = _standard;
@synthesize prefixType = _prefixType;
@synthesize minUnitPrefix = _minUnitPrefix;
@synthesize maxUnitPrefix = _maxUnitPrefix;
@synthesize abbrevCap = _abbrevCap;
@synthesize decimals = _decimals;

- (NSString *)stringFromSize:(NSUInteger)size
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    // Append abbreviated number
    NSString *format = [NSString stringWithFormat:@"%%.%luLf", self.decimals];
    PRSizePrefix prefix = self.minUnitPrefix;
    long double abbrev = 0;
    do {
        if (prefix == self.maxUnitPrefix ||
            (NSUInteger) size / self.abbrevCap < (NSUInteger) pow(self.factor, prefix)) {
            abbrev = (long double) size / pow(self.factor, prefix);
            break;
        } else {
            prefix++;
        }
    } while (prefix <= self.maxUnitPrefix);
    [string appendFormat:format, abbrev];
    
    // Trim trailing 0s if needed
    if (prefix == PRSizePrefixNone ||
        self.trimDecimals) {
        NSUInteger idx = string.length;
        do {
            idx--;
        } while ([string characterAtIndex:idx] == '0');
        if ([string characterAtIndex:idx] != '.') {
            idx++;
        }
        [string deleteCharactersInRange:NSMakeRange(idx, string.length - idx)];
    }
    
    if (self.useZeroText &&
        size == 0) {
        string.string = @"Zero";
    }
    
    [string appendString:@" "];
    
    // Append unit prefix and unit
    BOOL unitExpanded = (
                         (self.unitOptions & PRSizeUnitOptionsExpandBaseUnit) == PRSizeUnitOptionsExpandBaseUnit &&
                         (!((self.unitOptions & PRSizeUnitOptionsExpandBaseUnitOnlyWithoutPrefix) == PRSizeUnitOptionsExpandBaseUnitOnlyWithoutPrefix) ||
                          prefix == PRSizePrefixNone)
                         );
    BOOL prefixExpanded = (
                           (self.unitOptions & PRSizeUnitOptionsExpandPrefix) == PRSizeUnitOptionsExpandPrefix &&
                           unitExpanded
                           );
    BOOL plural = (prefix == PRSizePrefixNone) && (abbrev != 1);
    [string appendString:[self stringForPrefix:prefix
                                  ofPrefixType:self.prefixType
                                      expanded:prefixExpanded]];
    [string appendString:[self stringForBaseUnit:self.baseUnit
                                        expanded:unitExpanded
                                          plural:plural]];
    
    return string;
}

#pragma mark - Utils

- (NSString *)stringForPrefix:(PRSizePrefix)prefix
                 ofPrefixType:(PRSizePrefixType)prefixType
                     expanded:(BOOL)expanded
{
    NSArray *prefixStrings = nil;
    if (expanded) {
        switch (prefixType) {
            case PRSizePrefixTypeHybrid:
                prefixStrings = @[@"", @"kilo", @"mega", @"giga", @"tera", @"peta", @"exa", @"zetta", @"yotta"];
                break;
            case PRSizePrefixTypeMetric:
                prefixStrings = @[@"", @"kilo", @"mega", @"giga", @"tera", @"peta", @"exa", @"zetta", @"yotta"];
                break;
            case PRSizePrefixTypeJEDEC:
                prefixStrings = @[@"", @"kilo", @"mega", @"giga"];
                break;
            case PRSizePrefixTypeIEC:
                prefixStrings = @[@"", @"kibi", @"mebi", @"gibi", @"tebi", @"pebi", @"exbi", @"zebi", @"yobi"];
            default:
                break;
        }
    } else {
        switch (prefixType) {
            case PRSizePrefixTypeHybrid:
                prefixStrings = @[@"", @"K", @"M", @"G", @"T", @"P", @"E", @"Z", @"Y"];
                break;
            case PRSizePrefixTypeMetric:
                prefixStrings = @[@"", @"k", @"M", @"G", @"T", @"P", @"E", @"Z", @"Y"];
                break;
            case PRSizePrefixTypeJEDEC:
                prefixStrings = @[@"", @"K", @"M", @"G"];
                break;
            case PRSizePrefixTypeIEC:
                prefixStrings = @[@"", @"Ki", @"Mi", @"Gi", @"Ti", @"Pi", @"Ei", @"Zi", @"Yi"];
            default:
                break;
        }
    }
    
    NSString *prefixString = nil;
    @try {
        prefixString = prefixStrings[prefix];
    }
    @catch (NSException *exception) {
        NSLog(@"%s Error getting string for prefix %lu.", __PRETTY_FUNCTION__, prefix);
        prefixString = @"";
    }
    return prefixString;
}

- (NSString *)stringForBaseUnit:(PRSizeBaseUnit)baseUnit
                       expanded:(BOOL)expanded
                         plural:(BOOL)plural
{
    NSArray *baseUnitStrings = expanded ? (plural ? @[@"bits", @"bytes"] : @[@"bit", @"byte"]) : @[@"b", @"B"];
    NSString *baseUnitString = nil;
    @try {
        baseUnitString = baseUnitStrings[baseUnit];
    }
    @catch (NSException *exception) {
        NSLog(@"%s Error getting string for base unit %lu.", __PRETTY_FUNCTION__, baseUnit);
        baseUnitString = @"";
    }
    return baseUnitString;
}

#pragma mark - Getters and setters

- (PRSizeStandard)standard
{
    @synchronized(self) {
        return _standard;
    }
}

- (void)setStandard:(PRSizeStandard)standard
{
    @synchronized(self) {
        if (standard != _standard) {
            _standard = standard;
        }
        
        // Set factor
        switch (standard) {
            case PRSizeStandardDecimal:
                self.factor = kPRSizeFactorDecimal;
                break;
            case PRSizeStandardBinary:
                self.factor = kPRSizeFactorBinary;
                break;
            default:
                self.standard = PRSizeStandardDecimal;
                NSLog(@"%s Invalid value for standard %lu. Set to default value %lu.", __PRETTY_FUNCTION__, standard, self.standard);
                break;
        }
        
        if (self.prefixType != PRSizePrefixTypeHybrid) {
            switch (standard) {
                case PRSizeStandardDecimal:
                    if (self.prefixType != PRSizePrefixTypeMetric) {
                        NSLog(@"%s Prefix type %lu does not support standard %lu. Set to %lu.", __PRETTY_FUNCTION__, self.prefixType, standard, PRSizePrefixTypeHybrid);
                        self.prefixType = PRSizePrefixTypeHybrid;
                    }
                    break;
                case PRSizeStandardBinary:
                    if (self.prefixType != PRSizePrefixTypeJEDEC &&
                        self.prefixType != PRSizePrefixTypeIEC) {
                        NSLog(@"%s Prefix type %lu does not support standard %lu. Set to %lu.", __PRETTY_FUNCTION__, self.prefixType, standard, PRSizePrefixTypeHybrid);
                        self.prefixType = PRSizePrefixTypeHybrid;
                    }
                    break;
                default:
                    break;
            }
        }
    }
}

- (PRSizePrefixType)prefixType
{
    @synchronized(self) {
        return _prefixType;
    }
}

- (void)setPrefixType:(PRSizePrefixType)prefixType
{
    @synchronized(self) {
        if (prefixType != _prefixType) {
            _prefixType = prefixType;
        }
        
        switch (prefixType) {
            case PRSizePrefixTypeMetric:
                if (self.standard == PRSizeStandardBinary) {
                    NSLog(@"%s Standard %lu not supported by prefix type %lu. Set to %lu.", __PRETTY_FUNCTION__, self.standard, prefixType, PRSizeStandardDecimal);
                    self.standard = PRSizeStandardDecimal;
                }
                break;
            case PRSizePrefixTypeJEDEC:
            case PRSizePrefixTypeIEC:
                if (self.standard == PRSizeStandardDecimal) {
                    NSLog(@"%s Standard %lu not supported by prefix type %lu. Set to %lu.", __PRETTY_FUNCTION__, self.standard, prefixType, PRSizeStandardBinary);
                    self.standard = PRSizeStandardBinary;
                }
                break;
            default:
                break;
        }
        
        if (prefixType == PRSizePrefixTypeJEDEC) {
            self.maxUnitPrefix = PRSizePrefixG;
        }
    }
}

- (PRSizePrefix)minUnitPrefix
{
    @synchronized(self) {
        return _minUnitPrefix;
    }
}

- (void)setMinUnitPrefix:(PRSizePrefix)minUnitPrefix
{
    @synchronized(self) {
        if (minUnitPrefix != _minUnitPrefix) {
            _minUnitPrefix = minUnitPrefix;
        }
        
        // Adjust max prefix if conflicted
        if (minUnitPrefix > self.maxUnitPrefix) {
            self.maxUnitPrefix = minUnitPrefix;
        }
    }
}

- (PRSizePrefix)maxUnitPrefix
{
    @synchronized(self) {
        return _maxUnitPrefix;
    }
}

- (void)setMaxUnitPrefix:(PRSizePrefix)maxUnitPrefix
{
    @synchronized(self) {
        if (maxUnitPrefix != _maxUnitPrefix) {
            _maxUnitPrefix = maxUnitPrefix;
        }
        
        // Adjust min prefix if conflicted
        if (maxUnitPrefix < self.minUnitPrefix) {
            self.minUnitPrefix = maxUnitPrefix;
        }
        
        if (self.prefixType == PRSizePrefixTypeJEDEC &&
            maxUnitPrefix > PRSizePrefixG) {
            NSLog(@"%s Prefix type %lu doesn't support unit prefix %lu. Set to %lu", __PRETTY_FUNCTION__, self.prefixType, maxUnitPrefix, PRSizePrefixTypeHybrid);
            self.prefixType = PRSizePrefixTypeHybrid;
        }
    }
}

- (NSUInteger)abbrevCap
{
    @synchronized(self) {
        return _abbrevCap ? _abbrevCap : self.factor * kPRSizeDefaultAbbrevCapMultiplier;
    }
}

- (void)setAbbrevCap:(NSUInteger)abbrevCap
{
    @synchronized(self) {
        if (abbrevCap != _abbrevCap) {
            _abbrevCap = abbrevCap;
        }
    }
}

- (NSUInteger)decimals
{
    @synchronized(self) {
        return _decimals;
    }
}

- (void)setDecimals:(NSUInteger)decimals
{
    @synchronized(self) {
        if (decimals != _decimals) {
            _decimals = MIN(decimals, 3);
            if (_decimals != decimals) {
                NSLog(@"%s Invalid value for decimals %lu. Set to max value %lu.", __PRETTY_FUNCTION__, decimals, self.decimals);
            }
        }
    }
}

#pragma mark - Life cycle

- (id)init
{
    self = [super init];
    if (self) {
        self.standard = PRSizeStandardDecimal;
        self.prefixType = PRSizePrefixTypeHybrid;
        self.baseUnit = PRSizeBaseUnitByte;
        self.unitOptions = (PRSizeUnitOptionsExpandBaseUnit |
                            PRSizeUnitOptionsExpandBaseUnitOnlyWithoutPrefix);
        
        self.minUnitPrefix = PRSizePrefixMin;
        self.maxUnitPrefix = PRSizePrefixMax;
        
        self.decimals = 2;
        self.trimDecimals = YES;
        self.useZeroText = YES;
    }
    return self;
}

@end

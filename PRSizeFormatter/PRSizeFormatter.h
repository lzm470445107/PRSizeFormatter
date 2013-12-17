//
//  PRSizeFormatter.h
//  ProjectRhinestone
//
//  Created by Alex Rezit on 15/12/2013.
//  Copyright (c) 2013 Project Rhinestone Committee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PRSizeStandard) {
    PRSizeStandardDecimal,
    PRSizeStandardBinary
};

typedef NS_ENUM(NSUInteger, PRSizePrefixType) {
    PRSizePrefixTypeHybrid,
    PRSizePrefixTypeMetric,
    PRSizePrefixTypeJEDEC,
    PRSizePrefixTypeIEC
};

typedef NS_ENUM(NSUInteger, PRSizeBaseUnit) {
    PRSizeBaseUnitBit,
    PRSizeBaseUnitByte
};

typedef NS_ENUM(NSUInteger, PRSizePrefix) {
    PRSizePrefixNone = 0,
    PRSizePrefixK,
    PRSizePrefixM,
    PRSizePrefixG,
    PRSizePrefixT,
    PRSizePrefixP,
    PRSizePrefixE,
    PRSizePrefixZ,
    PRSizePrefixY,
    
    PRSizePrefixMin = PRSizePrefixNone,
    PRSizePrefixMax = PRSizePrefixY
};

typedef NS_OPTIONS(NSUInteger, PRSizeUnitOptions) {
    PRSizeUnitOptionsNone                            = 0,
    PRSizeUnitOptionsExpandBaseUnit                  = 1 << 0,
    PRSizeUnitOptionsExpandBaseUnitOnlyWithoutPrefix = 1 << 1,
    PRSizeUnitOptionsExpandPrefix                    = 1 << 2
};

@interface PRSizeFormatter : NSObject

@property (assign) PRSizeStandard standard;
@property (assign) PRSizePrefixType prefixType;
@property (assign) PRSizeBaseUnit baseUnit;
@property (assign) PRSizeUnitOptions unitOptions;

@property (assign) PRSizePrefix minUnitPrefix;
@property (assign) PRSizePrefix maxUnitPrefix;
@property (assign) NSUInteger abbrevCap;
@property (assign) NSUInteger decimals; // Max value is 3
@property (assign) BOOL trimDecimals;
@property (assign) BOOL useZeroText;

- (NSString *)stringFromSize:(NSUInteger)size;

@end

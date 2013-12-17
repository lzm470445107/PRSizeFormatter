# PRSizeFormatter

Format sizes to human readable format.

## Features

* 2 standards: Decimal (1000), Binary (1024);
* 9 prefixes: none, K, M, G, T, P, E, Z, Y;
* 4 prefix types (expanded & abbreviated): Hybrid (used by Apple), Metric, JEDEC, IEC;
* 2 base units (expanded & abbreviated): byte (B), bit (b);
* Customizable available prefixes range;
* Customizable abbrev cap;
* Customizable number of digits after decimal point;
* Customizable option for trimming trailing zeros after decimal point;
* Customizable option for whether to use "Zero" to replace "0" when the size is 0.

## Usage

```Objective-C
/*
 * Create a formatter instance
 */
PRSizeFormatter *sizeFormatter = [[PRSizeFormatter alloc] init];

/*
 * Set format standard
 *
 * Decimal (default): 1000
 * Binary: 1024
 *
 * NOTE: If it is not supported by currently selected prefix, prefix type will be automatically changed to default.
 */
sizeFormatter.standard = PRSizeStandardDecimal;

/*
 * Set type of prefix
 *
 * Hybrid (of Metric and JEDEC) (default): none, K (kilo), M (mega), G (giga), T (tera), P (peta), E (exa), Z (zetta), Y (yotta)
 * Metric: none, k (kilo), M (mega), G (giga), T (tera), P (peta), E (exa), Z (zetta), Y (yotta)
 * JEDEC: none, K (kilo), M (mega), G (giga)
 * IEC: none, Ki (kibi), Mi (mebi), Gi (gibi), Ti (tebi), Pi (pebi), Ei (exbi), Zi (zebi), Yi (yobi)
 *
 * NOTE: Metric only supports decimal standard. JEDEC and IEC only support binary standard. Standard will be automatically changed if currently selected standard is not supported.
 * NOTE: If JEDEC is selected, max unit prefix will be limited to G.
 */
sizeFormatter.prefixType = PRSizePrefixTypeHybrid;

/*
 * Set base unit
 *
 * Byte (default): B(byte)
 * Bit: b(bit)
 */
sizeFormatter.baseUnit = PRSizeBaseUnitByte;

/*
 * Set unit options
 *
 * 0: None
 * 1: Expand base unit (default)
 * 2: Expand base unit only when there is no prefix (default)
 * 3: Expand prefix
 *
 * NOTE: 2 is ignored when 1 is off.
 * NOTE: 3 is ignored when 1 is off or 2 is on.
 */
sizeFormatter.unitOptions = (PRSizeUnitOptionsExpandBaseUnit |
                             PRSizeUnitOptionsExpandBaseUnitOnlyWithoutPrefix);

/*
 * Set min and max unit prefix
 *
 * All prefixes are available by default.
 *
 * NOTE: If it is not supported by currently selected prefix type, prefix type will be automatically changed to default.
 */
sizeFormatter.minUnitPrefix = PRSizePrefixMin;
sizeFormatter.maxUnitPrefix = PRSizePrefixMax;

/*
 * Set abbrev cap
 *
 * This option decides when to use larger unit prefix. Default value is 0.9 * [1000 | 1024] (decided by currently selected standard).
 */
sizeFormatter.abbrevCap = 1000 * 0.9;

/*
 * Set decimals
 *
 * This option indicates the number of digits it keeps after the decimal point.
 * Available range: 0-3 (2 by default)
 */
sizeFormatter.decimals = 2;

/*
 * Set trim decimal option
 *
 * This option indicates whether trailing 0s after decimal point will be trimmed.
 * Default: YES
 */
sizeFormatter.trimDecimals = YES;

/*
 * Set use zero text option
 *
 * This option indicates whether "0" will be replaced by "Zero" text when the size is 0.
 * Default: YES
 */
sizeFormatter.useZeroText = YES;

/*
 * Format sizes
 *
 * The type of input value is NSUInteger, which is about 18.447 E in decimal or 16 E in binary.
 * The output string with default options is the same format OS X is using.
 */
NSUInteger sizeOfMyFile = 666666;
NSLog(@"%@", [sizeFormatter stringFromSize:sizeOfMyFile]);
```

Output:

```
666.67 KB
```

## License

This code is distributed under the terms and conditions of the [MIT license](http://opensource.org/licenses/MIT).

The original author, Alex Rezit, reserves the right to change the license.

## Donate

You can support me in various ways: Cash donation, purchasing items on my Amazon Wishlist, or improve my code and send a pull request.

Via:

* [Alipay](https://me.alipay.com/alexrezit)
* [Amazon Wishlist](http://www.amazon.cn/wishlist/P8YMPIX8QFTN/)


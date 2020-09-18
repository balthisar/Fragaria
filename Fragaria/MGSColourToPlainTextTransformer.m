//
//  MGSFontToTextTransformer.m
//  Fragaria
//
//  Created by Jim Derry on 3/23/15.
//
//

#import "MGSColourToPlainTextTransformer.h"


@implementation MGSColourToPlainTextTransformer


/*
 * + transformedValueClass
 */
+ (Class)transformedValueClass
{
	return [NSColor class];
}


/*
 * + allowsReverseTransformation
 */
+ (BOOL)allowsReverseTransformation
{
	return YES;
}


/*
 * - transformedValue:
 */
- (id)transformedValue:(id)col
{
    NSColor *nc;
    NSMutableString *tmp = [NSMutableString string];
    
    if ([col colorUsingColorSpaceName:NSNamedColorSpace]) {
        [tmp appendFormat:@"%@ %@", [col catalogNameComponent], [col colorNameComponent]];
        
    } else if ((nc = [col colorUsingColorSpaceName:NSCalibratedRGBColorSpace])) {
        [tmp appendFormat:@"%lf %lf %lf", nc.redComponent, nc.greenComponent, nc.blueComponent];
        if (nc.alphaComponent != 1.0)
            [tmp appendFormat:@" %lf", nc.alphaComponent];
            
    } else {
        NSLog(@"MGSStringFromColor: can't convert %@, returning red", col);
        return @"1.0 0.0 0.0";
    }
    
    return [tmp copy];
}


/*
 * - reverseTransformedValue:
 */
-(id)reverseTransformedValue:(id)str
{
    NSScanner *scan = [NSScanner scannerWithString:str];
    
    CGFloat r, g, b, a = 1.0;
    if (([scan scanDouble:&r] && [scan scanDouble:&g] && [scan scanDouble:&b])) {
        [scan scanDouble:&a];
        return [NSColor colorWithCalibratedRed:r green:g blue:b alpha:a];
    }
    
    [scan setScanLocation:0];
    NSString *catalog, *color;
    if ([scan scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&catalog] &&
            [scan scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&color]) {
        NSColor *res = [NSColor colorWithCatalogName:catalog colorName:color];
        if (res)
            return res;
    }
    
    NSLog(@"MGSColorFromString: can't parse %@, returning red", str);
    return [NSColor redColor];
}


@end

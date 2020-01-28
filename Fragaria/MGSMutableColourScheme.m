//
//  MGSMutableColourScheme.m
//  Fragaria
//
//  Created by Daniele Cattaneo on 20/09/18.
//

#import <objc/message.h>
#import "MGSMutableColourScheme.h"
#import "MGSColourSchemePrivate.h"


@implementation MGSMutableColourScheme


@dynamic displayName;
@dynamic textColor;
@dynamic backgroundColor;
@dynamic defaultSyntaxErrorHighlightingColour;
@dynamic textInvisibleCharactersColour;
@dynamic currentLineHighlightColour;
@dynamic insertionPointColor;
@dynamic gutterTextColor;
@dynamic gutterBackgroundColor;
@dynamic syntaxGroupOptions;


- (id)copyWithZone:(NSZone *)zone
{
    return [[MGSMutableColourScheme alloc] initWithColourScheme:self];
}


- (BOOL)loadFromSchemeFileURL:(NSURL *)file error:(NSError * _Nullable __autoreleasing *)err
{
    return [super loadFromSchemeFileURL:file error:err];
}


- (void)setOptions:(NSDictionary<MGSColourSchemeGroupOptionKey, id> *)options forSyntaxGroup:(MGSSyntaxGroup)syntaxGroup;
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(syntaxGroupOptions))];
    
    MGSColourSchemeGroupData *data = [[MGSColourSchemeGroupData alloc] initWithOptionDictionary:options];
    [_groupData setObject:data forKey:syntaxGroup];
    
    [self didChangeValueForKey:NSStringFromSelector(@selector(syntaxGroupOptions))];
}


- (MGSColourSchemeGroupData *)returnOrCreateDataForGroup:(MGSSyntaxGroup)group
{
    MGSColourSchemeGroupData *data = [_groupData objectForKey:group];
    if (data)
        return data;
    data = [[MGSColourSchemeGroupData alloc] init];
    [_groupData setObject:data forKey:group];
    return data;
}


- (void)setColour:(NSColor *)color forSyntaxGroup:(MGSSyntaxGroup)group
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(syntaxGroupOptions))];
    
    MGSColourSchemeGroupData *data = [self returnOrCreateDataForGroup:group];
    data.color = color;
    
    [self didChangeValueForKey:NSStringFromSelector(@selector(syntaxGroupOptions))];
}


- (void)setFontVariant:(MGSFontVariant)variant forSyntaxGroup:(MGSSyntaxGroup)syntaxGroup;
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(syntaxGroupOptions))];
    
    MGSColourSchemeGroupData *data = [self returnOrCreateDataForGroup:syntaxGroup];
    data.fontVariant = variant;
    
    [self didChangeValueForKey:NSStringFromSelector(@selector(syntaxGroupOptions))];
}


- (void)setColours:(BOOL)enabled syntaxGroup:(MGSSyntaxGroup)group
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(syntaxGroupOptions))];
    
    MGSColourSchemeGroupData *data = [self returnOrCreateDataForGroup:group];
    data.enabled = enabled;
    
    [self didChangeValueForKey:NSStringFromSelector(@selector(syntaxGroupOptions))];
}


@end

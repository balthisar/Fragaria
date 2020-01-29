//
//  MGSColourSchemePrivate.h
//  Fragaria
//
//  Created by Daniele Cattaneo on 20/09/18.
//
/// @cond PRIVATE

#import <Foundation/Foundation.h>
#import "MGSColourScheme.h"

NS_ASSUME_NONNULL_BEGIN


extern NSString * const MGSColourSchemeKeySyntaxGroupOptions;


@interface MGSColourSchemeGroupData : NSObject

- (instancetype)initWithOptionDictionary:(NSDictionary<MGSColourSchemeGroupOptionKey, id> *)optionDictionary;
- (NSDictionary<MGSColourSchemeGroupOptionKey, id> *)optionDictionary;

@property (nonatomic) BOOL enabled;
@property (nonatomic, nullable) NSColor *color;
@property (nonatomic) MGSFontVariant fontVariant;

@end


@interface MGSColourScheme ()
{
    @protected
    NSMutableDictionary<MGSSyntaxGroup, MGSColourSchemeGroupData *> *_groupData;
}

- (BOOL)loadFromSchemeFileURL:(NSURL *)file error:(NSError **)err;

@property (nonatomic, strong) NSString *displayName;

@property (nonatomic, strong) NSColor *textColor;
@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic, strong) NSColor *defaultSyntaxErrorHighlightingColour;
@property (nonatomic, strong) NSColor *textInvisibleCharactersColour;
@property (nonatomic, strong) NSColor *currentLineHighlightColour;
@property (nonatomic, strong) NSColor *insertionPointColor;
@property (nonatomic, strong) NSColor *selectionBackgroundColor;
@property (nonatomic, strong) NSColor *gutterTextColor;
@property (nonatomic, strong) NSColor *gutterBackgroundColor;

@property (nonatomic, copy) NSDictionary<MGSSyntaxGroup, NSDictionary<MGSColourSchemeGroupOptionKey, id> *> *syntaxGroupOptions;

@end


NS_ASSUME_NONNULL_END


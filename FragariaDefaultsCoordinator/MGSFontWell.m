//
//  MGSFontWell.m
//  Fragaria
//
//  Created by Daniele Cattaneo on 27/05/15.
//
//

#import "MGSFontWell.h"
#import "NSObject+Fragaria.h"


static NSNumberFormatter *formatter;


@implementation MGSFontWell {
    NSFont *baseFont;
    BOOL wasActivatedOnce;
}


#pragma mark - Initialization


+ (void)initialize
{
    if ([self class] == [MGSFontWell class]) {
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    }
}


+ (Class)cellClass
{
    return [NSTextFieldCell class];
}


- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (!self) return nil;
    
    [self awakeFromNib];
    _selectedFont = [NSFont userFontOfSize:0];
    [self updateCellContents];
    
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (!self) return nil;
    
    self.cell = [[[[self class] cellClass] alloc] initTextCell:@""];
    _selectedFont = [NSFont userFontOfSize:0];
    [self updateCellContents];
    
    return self;
}


- (void)awakeFromNib
{
    [self.cell setAlignment:NSCenterTextAlignment];
    [self.cell setScrollable:YES];
    [self.cell setWraps:NO];
    [self.cell setSelectable:NO];
    [self.cell setBezeled:YES];
    [self.cell setShowsFirstResponder:YES];
    [self.cell setDrawsBackground:YES];
    [self setFocusRingType:NSFocusRingTypeExterior];
    wasActivatedOnce = NO;
}


- (NSSize)intrinsicContentSize
{
    return NSMakeSize(NSViewNoInstrinsicMetric, NSViewNoInstrinsicMetric);
}


#pragma mark - Actions


- (void)mouseDown:(NSEvent *)theEvent
{
}


- (BOOL)canBecomeKeyView
{
    return YES;
}


- (BOOL)acceptsFirstResponder
{
    return YES;
}


- (void)activate:(id)sender
{
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    
    wasActivatedOnce = YES;
    baseFont = self.selectedFont;
    [[self window] makeFirstResponder:self];
    [fontManager setSelectedFont:baseFont isMultiple:NO];
    [fontManager orderFrontFontPanel:self];
}


#pragma mark - Properties


- (id)objectValue
{
    return _selectedFont;
}


- (void)setObjectValue:(id)objectValue
{
    self.selectedFont = objectValue;
    [self mgs_propagateValue:objectValue forBinding:@"object"];
}


- (void)setFont:(NSFont *)font
{
    [self setSelectedFont:font];
}


- (NSFont *)font
{
    return _selectedFont;
}


- (void)setSelectedFont:(NSFont *)font
{
    [self willChangeValueForKey:@"objectValue"];
    [self willChangeValueForKey:@"font"];
    _selectedFont = font;
    [self didChangeValueForKey:@"font"];
    [self didChangeValueForKey:@"objectValue"];
    
    [self updateCellContents];
    
    [self mgs_propagateValue:font forBinding:@"font"];
}


- (void)updateCellContents
{
    NSString *desc, *fontName, *pointSize;
    
    fontName = [self.selectedFont fontName];
    pointSize = [formatter stringFromNumber:@([self.selectedFont pointSize])];
    desc = [NSString stringWithFormat:@"%@ - %@pt", fontName, pointSize];
    [self.cell setStringValue:desc];
    [self.cell setFont:self.selectedFont];
    [self setNeedsDisplay:YES];
}


- (void)changeFont:(id)sender
{
    if (self.isEnabled) {
        self.selectedFont = [sender convertFont:baseFont];
        [self sendAction:self.action to:self.target];
    }
}


- (void)takeFontFrom:(id)sender
{
    self.selectedFont = [sender font];
}


#pragma mark - Drawing


- (void)drawFocusRingMask
{
    if (wasActivatedOnce)
        NSRectFill([self bounds]);
}


- (NSRect)focusRingMaskBounds
{
    return [self bounds];
}


@end

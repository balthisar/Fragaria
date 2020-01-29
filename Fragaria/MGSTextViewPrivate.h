//
//  MGSTextViewPrivate.h
//  Fragaria
//
//  Created by Daniele Cattaneo on 26/02/15.
//
/// @cond PRIVATE

#import <Cocoa/Cocoa.h>
#import "MGSTextView.h"


@class MGSExtraInterfaceController;
@class MGSSyntaxColouring;
@class MGSLayoutManager;
@class MGSMutableColourScheme;


@interface MGSTextView ()


/// @name Private properties


/** The controller which manages the accessory user interface for this text
 * view. */
@property (readonly) MGSExtraInterfaceController *interfaceController;

/** Instances of this class will perform syntax highlighting in text views. */
@property (readonly) MGSSyntaxColouring *syntaxColouring;

/** MGSTextView's layout manager is an MGSLayoutManager internally, but that
 * class is not exposed. */
@property (assign, readonly) MGSLayoutManager *layoutManager;

/** The shared color scheme, set by MGSFragariaView */
@property (nonatomic, strong) MGSMutableColourScheme *colourScheme;

@property (nonatomic) BOOL useSystemSelectionColor;

- (void)updateLineWrap;


@end

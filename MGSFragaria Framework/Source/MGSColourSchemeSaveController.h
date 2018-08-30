//
//  MGSColourSchemeSaveController.h
//  Fragaria
//
//  Created by Jim Derry on 3/21/15.
//
/// @cond PRIVATE

#import <Foundation/Foundation.h>

/**
 *  Provides a scheme naming service for MGSColourSchemeController, as well
 *  as a file deletion confirmation service.
 **/
@interface MGSColourSchemeSaveController : NSWindowController


/**
 *  The name of the scheme. You can retrieve this after showSchemeNameGetter
 *  returns.
 **/
@property (nonatomic, strong) NSString *schemeName;

/**
 *  The filename of the scheme. You can retrieve this after showSchemeNameGetter
 *  returns. The filename will be a slightly sanitized version of `schemeName`
 *  (to remove unwanted characters).
 **/
@property (nonatomic, strong) NSString *fileName;


/**
 *  Provide a pre-made alert panel for deleting a scheme.
 */
- (NSAlert *)alertPanel;

@end

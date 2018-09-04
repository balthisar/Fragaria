//
//  MGSPreferencesProxyDictionary.h
//  Fragaria
//
//  Created by Jim Derry on 3/14/15.
//
/// @cond PRIVATE

#import <Foundation/Foundation.h>

@class MGSUserDefaultsController;


/** This macro defines the groupID that should correspond to the global group
 *  for MGSUserDefaults and, by extension, MGSUserDefaultsController. */
#define MGSPREFERENCES_DEFAULT_ID @"Uninitialized"

/**
 *  An NSMutableDictionary subclass used by MGSUserDefaultsController that:
 *  - can persist keys in the user defaults system, if desired.
 *  - store multiple set of properties, controlled by the owning controller's
 *    `subgroupID` property. For example, different sets of colors might be
 *    stored for multiple view appearance modes.
 */
@interface MGSPreferencesProxyDictionary : NSMutableDictionary

/**
 *  A convenience initializer to assign the controller and dictionary contents.
 *  @param controller The instance of MGSUserDefaultsController owning this dictionary.
 *  @param dictionary An initial dictionary of values to populate this dictionary.
 **/
- (instancetype)initWithController:(MGSUserDefaultsController *)controller dictionary:(NSDictionary *)dictionary;

/** A reference to the controller that owns an instance of this class. */
@property (weak) MGSUserDefaultsController *controller;

@end

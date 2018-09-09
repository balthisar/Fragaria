//
//  MGSPreferencesProxyDictionary.h
//  Fragaria
//
//  Created by Jim Derry on 3/14/15.
//
/// @cond PRIVATE

#import <Foundation/Foundation.h>

@class MGSUserDefaultsController;


/**
 *  An NSMutableDictionary subclass implemented by MGSUserDefaultsController so
 *  that it can persist keys in the user defaults system, if desired.
 */
@interface MGSPreferencesProxyDictionary : NSMutableDictionary

/*
 *  A convenience initializer to assign the controller and dictionary contents.
 *  using a different ID for preferences.
 *  @param controller The instance of MGSUserDefaultsController owning this dictionary.
 *  @param dictionary An initial dictionary of values to populate this dictionary.
 *  @param preferencesID Specify a different groupID for this controller's
 *         NSUserDefaults storage. The default if nil is the groupID of the
 *         specified controller.
 */
- (instancetype)initWithController:(MGSUserDefaultsController *)controller
                        dictionary:(NSDictionary *)dictionary
                     preferencesID:(NSString *)preferencesID;

/**
 *  A convenience initializer to assign the controller and dictionary contents.
 *  @param controller The instance of MGSUserDefaultsController owning this dictionary.
 *  @param dictionary An initial dictionary of values to populate this dictionary.
 **/
- (instancetype)initWithController:(MGSUserDefaultsController *)controller dictionary:(NSDictionary *)dictionary;

/** A reference to the controller that owns an instance of this class. */
@property (nonatomic,weak,readonly) MGSUserDefaultsController *controller;


@end

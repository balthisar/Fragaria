//
//  MGSUserDefaultsDelegate.h
//  Fragaria
//
//  Created by Jim Derry on 9/6/18.
//
#include <Cocoa/Cocoa.h>


@protocol MGSUserDefaultsDelegate

/** Ask the delegate to provide a dictionary of MGSFragariaView properties
 *  to be used for the given appearance. Properties not supplied by this
 *  delegate method will use the built-in defaults, so a complete list is
 *  not required.
 */
- (NSDictionary *)defaultsForAppearanceName:(NSString *)appearanceName;


@end

//
//  MGSHybridUserDefaultsController.m
//  Fragaria
//
//  Created by Jim Derry on 3/24/15.
//
//

#import "MGSHybridUserDefaultsController.h"
#import "MGSUserDefaultsController.h"


/*
 *  This bindable proxy object exists to support the managedProperties
 *  property, whereby we return a @(BOOL) indicating whether or not the
 *  view controller's NSUserDefaultsController is managing the property
 *  in the keypath, e.g., `viewController.managedProperties.textColour`.
 */
@interface MGSHybridValuesProxy : NSObject

@property (nonatomic, weak) MGSHybridUserDefaultsController *controller;

@end


@implementation MGSHybridValuesProxy


/*
 * - initWithController:
 */
- (instancetype)initWithController:(MGSHybridUserDefaultsController *)controller
{
    if ((self = [super init]))
    {
        self.controller = controller;
    }
    MGSUserDefaultsController *group = [MGSUserDefaultsController sharedControllerForGroupID:self.controller.groupID];
    MGSUserDefaultsController *global = [MGSUserDefaultsController sharedController];

    for (NSString *property in group.managedProperties)
        [group addObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", property] options:NSKeyValueObservingOptionPrior|NSKeyValueObservingOptionNew context:@"values_context"];

    for (NSString *property in global.managedProperties)
        [global addObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", property] options:NSKeyValueObservingOptionPrior|NSKeyValueObservingOptionNew context:@"values_context"];

    return self;
}


/*
 * - dealloc
 */
- (void)dealloc
{
    MGSUserDefaultsController *group = [MGSUserDefaultsController sharedControllerForGroupID:self.controller.groupID];
    MGSUserDefaultsController *global = [MGSUserDefaultsController sharedController];
    for (NSString *property in group.managedProperties)
        [group removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", property]];
    
    for (NSString *property in global.managedProperties)
        [global removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", property]];
}


/*
 * - setValue:forKey:
 */
- (void)setValue:(id)value forKey:(NSString *)key
{
    MGSUserDefaultsController *group = [MGSUserDefaultsController sharedControllerForGroupID:self.controller.groupID];
    MGSUserDefaultsController *global = [MGSUserDefaultsController sharedController];

    if ([self.controller.managedProperties containsObject:key])
    {
        if ([group.managedProperties containsObject:key])
        {
            [group setValue:value forKeyPath:[NSString stringWithFormat:@"values.%@", key]];
        }
        if ([global.managedProperties containsObject:key])
        {
            [global setValue:value forKeyPath:[NSString stringWithFormat:@"values.%@", key]];
        }
        return;
    }

    [super setValue:value forKey:key];
}


/*
 * - valueForKey:
 */
- (id)valueForKey:(NSString *)key
{
    MGSUserDefaultsController *group = [MGSUserDefaultsController sharedControllerForGroupID:self.controller.groupID];
    MGSUserDefaultsController *global = [MGSUserDefaultsController sharedController];

    if ([self.controller.managedProperties containsObject:key])
    {
        if ([group.managedProperties containsObject:key])
        {
            return [group valueForKeyPath:[NSString stringWithFormat:@"values.%@",key]];
        }
        if ([global.managedProperties containsObject:key])
        {
            return [global valueForKeyPath:[NSString stringWithFormat:@"values.%@",key]];
        }
    }

    return [super valueForKey:key];
}


/*
 * - allKeys:
 */
- (NSArray *)allKeys
{
    return [self.controller.managedProperties allObjects];
}


/*
 * - observeValueForKeyPath:ofObject:change:context:
 *   We must monitor our nested controllers for changes to their properties,
 *   so that we can report that we've changed, too.
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context == @"values_context")
    {
        NSString *path = [keyPath componentsSeparatedByString:@"."][1];
        if (change[NSKeyValueChangeNotificationIsPriorKey])
            [self.controller.values willChangeValueForKey:path];
        else
            [self.controller.values didChangeValueForKey:path];
    }
}


@end


@implementation MGSHybridUserDefaultsController

#pragma mark - Class Methods - Singleton Controllers

/*
 *  + sharedControllerForGroupID:
 */
+ (instancetype)sharedControllerForGroupID:(NSString *)groupID
{
    static NSMutableDictionary *controllerInstances;

    NSAssert(groupID && [groupID length] > 0, @"groupID cannot be nil");

    @synchronized(self) {

        if (!controllerInstances)
        {
            controllerInstances = [[NSMutableDictionary alloc] init];
        }

        if ([[controllerInstances allKeys] containsObject:groupID])
        {
            return [controllerInstances objectForKey:groupID];
        }

        MGSHybridUserDefaultsController *newController = [[[self class] alloc] initWithGroupID:groupID];
        [controllerInstances setObject:newController forKey:groupID];
        return newController;
    }
}


#pragma mark - Initializers (not exposed)

/*
 *  - initWithGroupID:
 */
- (instancetype)initWithGroupID:(NSString *)groupID
{
    if ((self = [super init]))
    {
        _values = [[MGSHybridValuesProxy alloc] initWithController:self];
        _groupID = groupID;
    }
    
    return self;
}


#pragma mark - Protocol Conformance

/*
 * @property managedInstances
 */
- (NSSet *)managedInstances
{
    NSSet *groupSet = [[MGSUserDefaultsController sharedControllerForGroupID:self.groupID] managedInstances];
    NSSet *globalSet = [[MGSUserDefaultsController sharedController] managedInstances];
    return [groupSet setByAddingObjectsFromSet:globalSet];
}


/*
 * @property managedProperties
 */
- (NSSet *)managedProperties
{
    NSSet *groupSet = [[MGSUserDefaultsController sharedControllerForGroupID:self.groupID] managedProperties];
    NSSet *globalSet = [[MGSUserDefaultsController sharedController] managedProperties];
    return [groupSet setByAddingObjectsFromSet:globalSet];
}


/*
 * @property appearanceSubgroups
 */
- (MGSSupportedAppearance)appearanceSubgroups
{
    return [[MGSUserDefaultsController sharedControllerForGroupID:self.groupID] appearanceSubgroups];
}

- (void)setAppearanceSubgroups:(MGSSupportedAppearance)appearanceSubgroups
{
    [[MGSUserDefaultsController sharedControllerForGroupID:self.groupID] setAppearanceSubgroups:appearanceSubgroups];
    [[MGSUserDefaultsController sharedController] setAppearanceSubgroups:appearanceSubgroups];
}


@end

//
//  MGSUserDefaultsController.m
//  Fragaria
//
//  Created by Jim Derry on 3/3/15.
//
//

#import "MGSPreferencesProxyDictionary.h"
#import "MGSUserDefaultsController.h"
#import "MGSFragariaView+Definitions.h"
#import "MGSUserDefaults.h"
#import "MGSFragariaView.h"


#pragma mark - CATEGORY MGSUserDefaultsController


@interface MGSUserDefaultsController ()

@property (nonatomic, strong, readwrite) id values;
@property (nonatomic, strong, readwrite) id valuesStore;
@property (nonatomic, strong, readonly) NSArray <NSString *> *validAppearances;
@property (nonatomic, assign, readonly) NSString *workingID;

@end


#pragma mark - CLASS MGSUserDefaultsController - Implementation


static NSMutableDictionary *controllerInstances;
static NSHashTable *allManagedInstances;
static NSCountedSet *allNonGlobalProperties;


@implementation MGSUserDefaultsController {
    NSHashTable *_managedInstances;
}


#pragma mark - Class Methods - Singleton Controllers


/*
 *  + sharedControllerForGroupID:
 */
+ (instancetype)sharedControllerForGroupID:(NSString *)groupID
{
    MGSUserDefaultsController *res;
    
    if (!groupID || [groupID length] == 0)
        groupID = MGSUSERDEFAULTS_GLOBAL_ID;

	@synchronized(self) {
        if (!controllerInstances)
            controllerInstances = [[NSMutableDictionary alloc] init];
        else if ((res = [controllerInstances objectForKey:groupID]))
			return res;
	
		res = [[[self class] alloc] initWithGroupID:groupID];
		[controllerInstances setObject:res forKey:groupID];
        
		return res;
	}
}


/*
 *  + sharedController
 */
+ (instancetype)sharedController
{
	return [[self class] sharedControllerForGroupID:MGSUSERDEFAULTS_GLOBAL_ID];
}


#pragma mark - Property Accessors


- (BOOL)isGlobal
{
    return [self.groupID isEqual:MGSUSERDEFAULTS_GLOBAL_ID];
}


/*
 *  @property managedInstances
 */
- (NSSet *)managedInstances
{
    return [NSSet setWithArray:[self.managedInstancesHashTable allObjects]];
}


- (NSHashTable *)managedInstancesHashTable
{
    if ([self isGlobal])
        return allManagedInstances;
    return _managedInstances;
}


/*
 *  @property managedProperties
 */
- (void)setManagedProperties:(NSSet *)new
{
    NSSet *old = _managedProperties;
    NSMutableSet *added, *removed, *diag, *glob;
    
    added = [new mutableCopy];
    [added minusSet:old];
    removed = [old mutableCopy];
    [removed minusSet:new];
    
    if ([self isGlobal]) {
        if ([allNonGlobalProperties intersectsSet:new]) {
            diag = [NSMutableSet setWithSet:allNonGlobalProperties];
            [diag intersectSet:new];
            [NSException raise:@"MGSUserDefaultsControllerPropertyClash" format:
             @"Tried to manage globally properties which are already managed "
             "locally.\nConflicting properties: %@", diag];
        }
    } else {
        if (!allNonGlobalProperties)
            allNonGlobalProperties = [NSCountedSet set];
        [allNonGlobalProperties minusSet:old];
        [allNonGlobalProperties unionSet:new];
        glob = [[[[self class] sharedController] managedProperties] mutableCopy];
        [glob minusSet:new];
        [[[self class] sharedController] setManagedProperties:glob];
    }
    
    [self unregisterBindings:removed];
    _managedProperties = new;
	[self registerBindings:added];
}


/*
 *  @property persistent
 */
- (void)setPersistent:(BOOL)persistent
{
    NSDictionary *defaultsDict, *currentDict, *defaultsValues;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSUserDefaultsController *udc = [NSUserDefaultsController sharedUserDefaultsController];
    NSString *groupKeyPath;
    
	if (_persistent == persistent) return;
    _persistent = persistent;

    groupKeyPath = [NSString stringWithFormat:@"values.%@", self.groupID];
	if (persistent) {
        // We weren't persistent, so make sure our current values are added
        // to user defaults, and then KVO on values to capture changes.
        defaultsDict = [self archiveForDefaultsDictionary:self.values];
        [ud setObject:defaultsDict forKey:self.groupID];
		[udc addObserver:self forKeyPath:groupKeyPath options:NSKeyValueObservingOptionNew context:nil];
	} else {
        // We're no longer persistent, so stop observing self.values
        // changes, and ensure values reflects last user defaults state.
		[udc removeObserver:self forKeyPath:groupKeyPath context:nil];
        currentDict = [ud objectForKey:self.groupID];
        defaultsValues = [self unarchiveFromDefaultsDictionary:currentDict];
        for (NSString *key in self.values) {
            if (![[self.values valueForKey:key] isEqual:[defaultsValues valueForKey:key]])
                [self.values setValue:[defaultsValues valueForKey:key] forKey:key];
        }
	}
}


/**
 *  @property validAppearances
 */
- (NSArray <NSString *> *)validAppearances
{
    NSMutableArray *appearances = [NSMutableArray arrayWithObject:NSAppearanceNameAqua];

    if (@available(macos 10.14, *))
    {
        if (self.appearanceSubgroups & MGSAppearanceNameAccessibilityHighContrastAqua)
            [appearances addObject:NSAppearanceNameAccessibilityHighContrastAqua];
        if (self.appearanceSubgroups & MGSAppearanceNameDarkAqua)
            [appearances addObject:NSAppearanceNameDarkAqua];
        if (self.appearanceSubgroups & MGSAppearanceNameAccessibilityHighContrastDarkAqua)
            [appearances addObject:NSAppearanceNameAccessibilityHighContrastDarkAqua];
    }

    return appearances;
}


/**
 *  @property workingID
 */
- (NSString *)workingID
{
    NSString *workingGroup = NSAppearanceNameAqua;

    if (@available(macos 10.14, *))
    {
        NSAppearance *current = [self.managedInstances anyObject].effectiveAppearance;
        workingGroup = [current bestMatchFromAppearancesWithNames:self.validAppearances];
    }

    return [NSString stringWithFormat:@"%@-%@", self.groupID, workingGroup];
}



#pragma mark - Instance Methods


/*
 * - addFragariaToManagedSet:
 */
- (void)addFragariaToManagedSet:(MGSFragariaView *)object
{
    MGSUserDefaultsController *shc;

    if (!allManagedInstances)
        allManagedInstances = [NSHashTable weakObjectsHashTable];
    if ([allManagedInstances containsObject:object])
        [NSException raise:@"MGSUserDefaultsControllerClash" format:@"Trying "
         "to manage Fragaria %@ with more than one MGSUserDefaultsController!", object];

    [self registerBindings:_managedProperties forFragaria:object];

    if (![self isGlobal]) {
        shc = [MGSUserDefaultsController sharedController];
        [shc registerBindings:shc.managedProperties forFragaria:object];
    }

    [_managedInstances addObject:object];
    [allManagedInstances addObject:object];
}


/*
 * - removeFragariaFromManagedSet:
 */
- (void)removeFragariaFromManagedSet:(MGSFragariaView *)object
{
    MGSUserDefaultsController *shc;

    if (![_managedInstances containsObject:object]) {
        NSLog(@"Attempted to remove Fragaria %@ from %@ but it was not "
              "registered in the first place!", object, self);
        return;
    }

    [self unregisterBindings:_managedProperties forFragaria:object];
    if (![self isGlobal]) {
        shc = [MGSUserDefaultsController sharedController];
        [shc unregisterBindings:shc.managedProperties forFragaria:object];
    }

    [_managedInstances removeObject:object];
    [allManagedInstances addObject:object];
}


#pragma mark - Initializers (not exposed)

/*
 *  - initWithGroupID:
 */
- (instancetype)initWithGroupID:(NSString *)groupID
{
    NSDictionary *defaults;
    
	if (!(self = [super init]))
        return self;
    
    _groupID = groupID;

    if ( @available(macos 10.14, *) )
        _appearanceSubgroups = MGSAppearanceNameAqua|MGSAppearanceNameDarkAqua;
    else
        _appearanceSubgroups = MGSAppearanceNameAqua;

    defaults = [MGSFragariaView defaultsDictionary];
    
    if ([self isGlobal])
        _managedProperties = [NSSet setWithArray:[defaults allKeys]];
    else
        _managedProperties = [NSSet set];

    _managedInstances = [NSHashTable weakObjectsHashTable];

    // Even if this item is not persistent, register with defaults system.
    [[MGSUserDefaults sharedUserDefaultsForGroupID:self.workingID] registerDefaults:defaults];

    // If this item *is* persistent, get the state of the defaults. If the
    // controller isn't persistent, it will be identical to what was just
    // registered.
    defaults = [[NSUserDefaults standardUserDefaults] valueForKey:self.workingID];
    
    // Populate self.values with the current user defaults. This proxy object
    // keeps values in memory, and if persistent writes them to defaults.
    // However as we are a new instance and haven't set persistent yet,
    // these values won't be re-written to defaults.
    self.values = [[MGSPreferencesProxyDictionary alloc] initWithController:self
                                                                 dictionary:[self unarchiveFromDefaultsDictionary:defaults]
                                                              preferencesID:self.workingID];
	
    // We probably should observe one of our managed fragarias for state
    // change, but they should only be changing based on the OS anyway, so
    // this is a good hook into knowing when their appearance might change.
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(appearanceChanged:)
                                                            name:@"AppleInterfaceThemeChangedNotification"
                                                          object:nil];

    return self;
}


/*
 *  - init
 *    Just in case someone tries to create their own instance
 *    of this class, we'll make sure it's always "Global".
 */
- (instancetype)init
{
	return [self initWithGroupID:MGSUSERDEFAULTS_GLOBAL_ID];
}


#pragma mark - Binding Registration/Unregistration and KVO Handling


/*
 *  - registerBindings
 */
- (void)registerBindings:(NSSet *)propertySet
{
    NSHashTable *fragarias = [self managedInstancesHashTable];
    for (MGSFragariaView *fragaria in fragarias)
        [self registerBindings:propertySet forFragaria:fragaria];
}


/*
 *  - registerBindings:forFragaria:
 */
- (void)registerBindings:(NSSet *)propertySet forFragaria:(MGSFragariaView *)fragaria
{
    for (NSString *key in propertySet) {
        [fragaria bind:key toObject:self.values withKeyPath:key options:nil];
    }
}


/*
 *  - unregisterBindings:
 */
- (void)unregisterBindings:(NSSet *)propertySet
{
    NSHashTable *fragarias = [self managedInstancesHashTable];
    for (MGSFragariaView *fragaria in fragarias)
        [self unregisterBindings:propertySet forFragaria:fragaria];
}


/*
 *  - unregisterBindings:forFragaria:
 */
- (void)unregisterBindings:(NSSet *)propertySet forFragaria:(MGSFragariaView *)fragaria
{
    for (NSString *key in propertySet) {
        [fragaria unbind:key];
    }
}


/*
 * - observeValueForKeyPath:ofObject:change:context:
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSDictionary *currentDict, *defaultsValues;
    
	// The only keypath we've registered, but let's check in case we accidentally something.
	if ([[NSString stringWithFormat:@"values.%@", self.groupID] isEqual:keyPath])
	{
        currentDict = [[NSUserDefaults standardUserDefaults] objectForKey:self.groupID];
        defaultsValues = [self unarchiveFromDefaultsDictionary:currentDict];
        
        for (NSString *key in defaultsValues) {
            // If we use self.value valueForKey: here, we will get the value from defaults.
            if (![[defaultsValues valueForKey:key] isEqual:[self.values objectForKey:key]])
                [self.values setValue:[defaultsValues valueForKey:key] forKey:key];
        }
	}
}


/*
 *  -appearanceChanged:
 */
- (void)appearanceChanged:(NSNotification *)notif
{
    NSLog(@"appearanceChanged");
}


#pragma mark - Utilities


/*
 *  - unarchiveFromDefaultsDictionary:
 *    The fragariaDefaultsDictionary is meant to be written to userDefaults as
 *    is, but it's not good for internal storage, where we want real instances,
 *    and not archived data.
 */
- (NSDictionary *)unarchiveFromDefaultsDictionary:(NSDictionary *)source
{
    NSMutableDictionary *destination;
    
    destination = [NSMutableDictionary dictionaryWithCapacity:source.count];
    for (NSString *key in source) {
        id object = [source objectForKey:key];
        
        if ([object isKindOfClass:[NSData class]])
            object = [NSUnarchiver unarchiveObjectWithData:object];
        [destination setObject:object forKey:key];
    }

    return destination;
}


/*
 * - archiveForDefaultsDictionary:
 *   If we're copying things to user defaults, we have to make sure that any
 *   objects the requiring archiving are archived.
 */
- (NSDictionary *)archiveForDefaultsDictionary:(NSDictionary *)source
{
    NSMutableDictionary *destination;
    
    destination = [NSMutableDictionary dictionaryWithCapacity:source.count];
    for (NSString *key in source) {
        id object = [source objectForKey:key];
        
        if ([object isKindOfClass:[NSFont class]] || [object isKindOfClass:[NSColor class]])
            object = [NSArchiver archivedDataWithRootObject:object];
        [destination setObject:object forKey:key];
    }

    return destination;
}


@end

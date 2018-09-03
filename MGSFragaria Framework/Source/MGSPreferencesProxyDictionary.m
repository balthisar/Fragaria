//
//  MGSPreferencesProxyDictionary.m
//  Fragaria
//
//  Created by Jim Derry on 3/14/15.
//
//

#import "MGSPreferencesProxyDictionary.h"
#import "MGSUserDefaults.h"
#import "MGSUserDefaultsController.h"


@interface MGSPreferencesProxyDictionary ()

@property (nonatomic, strong) NSMutableDictionary *storage;
@property (nonatomic, strong) NSString *groupAndSubgroupID;

@end


@implementation MGSPreferencesProxyDictionary


#pragma mark - KVC

/*
 *  - setValue:forKey:
 */
- (void)setValue:(id)value forKey:(NSString *)key
{
    [self willChangeValueForKey:key];
    if (value)
    {
        [self setObject:value forKey:key];
    }
    else
    {
        [self removeObjectForKey:key];
    }
    
    if (self.controller.persistent)
    {
        [[MGSUserDefaults sharedUserDefaultsForGroupID:self.groupAndSubgroupID] setObject:value forKey:key];
    }
    [self didChangeValueForKey:key];
}


/*
 *  - valueForKey:
 */
- (id)valueForKey:(NSString *)key
{
    if (self.controller.persistent)
    {
        return [[MGSUserDefaults sharedUserDefaultsForGroupID:self.groupAndSubgroupID] objectForKey:key];
    }

    return [self objectForKey:key];
}


#pragma mark - Initializers


/*
 *  - initWithController:dictionary:capacity
 *    The pseudo-designated initializer for the subclass.
 */
- (instancetype)initWithController:(MGSUserDefaultsController *)controller dictionary:(NSDictionary *)dictionary capacity:(NSUInteger)numItems
{
    if ((self = [super init]))
    {
        self.controller = controller;

        if (dictionary)
        {
            self.storage = [[NSMutableDictionary alloc] initWithDictionary:@{ self.controller.groupID : [[NSMutableDictionary alloc] initWithDictionary:dictionary] }];
        }
        else
        {
            self.storage = [[NSMutableDictionary alloc] initWithCapacity:numItems];
        }
    }

    return self;
}


/*
 *  - initWithController:dictionary:
 */
- (instancetype)initWithController:(MGSUserDefaultsController *)controller dictionary:(NSDictionary *)dictionary
{
    return [self initWithController:controller dictionary:dictionary capacity:1];
}


/*
 *  - init:
 */
- (instancetype)init
{
    return [self initWithController:nil dictionary:nil capacity:1];
}


/*
 *  - initWithCapacity:
 */
- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    return [self initWithController:nil dictionary:nil capacity:numItems];
}


#pragma mark - Property Accessors


/**
 *  @property groupAndSubgroupID
 */
- (NSString *)groupAndSubgroupID
{
    if (self.controller.subgroupID) {
        // It's possible/likely that we've not been configured for the current
        // subgroup; if this subgroup doesn't exist, take new defaults and
        // values from the current settings.
        NSString *fullID = [NSString stringWithFormat:@"%@_%@", self.controller.groupID, self.controller.subgroupID];

        if (!self.storage[fullID])
        {
            NSMutableDictionary *newdict = [NSMutableDictionary dictionaryWithDictionary:self.storage[self.controller.groupID]];  // [self.storage[self.controller.groupID] copy];
            [self.storage setObject:newdict forKey:fullID];
            NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] valueForKey:self.controller.groupID];
            [[MGSUserDefaults sharedUserDefaultsForGroupID:fullID] registerDefaults:defaults];
        }
        return [NSString stringWithFormat:@"%@_%@", self.controller.groupID, self.controller.subgroupID];
    } else {
        return self.controller.groupID;
    }
}


#pragma mark - Archiving


/*
 * + classForKeyedUnarchiver
 */
+ (Class)classForKeyedUnarchiver
{
    return [MGSPreferencesProxyDictionary class];
}


/*
 * - classForKeyedArchiver
 */
- (Class)classForKeyedArchiver
{
    return [MGSPreferencesProxyDictionary class];
}


#pragma mark - Internal Storage Wrapping


/*
 * - count
 */
- (NSUInteger)count
{
    NSDictionary *subdict = self.storage[self.groupAndSubgroupID];
    return subdict.count;
}


/*
 * - keyEnumerator
 */
- (NSEnumerator *)keyEnumerator
{
    NSDictionary *subdict = self.storage[self.groupAndSubgroupID];
    return subdict.keyEnumerator;
}


/*
 * - objectForKey:
 */
- (id)objectForKey:(id)aKey
{
    id object = [self.storage[self.groupAndSubgroupID] objectForKey:aKey];
    if ([object isKindOfClass:[NSData class]])
    {
        object = [NSUnarchiver unarchiveObjectWithData:object];
    }

    return object;
}


/*
 * - removeObjectForKey:
 */
- (void)removeObjectForKey:(id)aKey
{
    [self.storage[self.groupAndSubgroupID] removeObjectForKey:aKey];
}


/*
 * - setObject:forKey:
 */
- (void)setObject:(id)anObject forKey:(id)aKey
{
    if ([anObject isKindOfClass:[NSFont class]] || [anObject isKindOfClass:[NSColor class]])
    {
        [self.storage[self.groupAndSubgroupID] setObject:[NSArchiver archivedDataWithRootObject:anObject] forKey:aKey];
    }
    else
    {
        [self.storage[self.groupAndSubgroupID] setObject:anObject forKey:aKey];
    }
}


@end

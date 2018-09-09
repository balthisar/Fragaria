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
@property (nonatomic,strong,readwrite) NSString *preferencesID;

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
        [[MGSUserDefaults sharedUserDefaultsForGroupID:self.preferencesID] setObject:value forKey:key];
    }
    [self didChangeValueForKey:key];
}


/*
 *  - valueForKey:
 */
- (id)valueForKey:(NSString *)key
{
    id result;
    if (self.controller.persistent)
    {
        result = [[MGSUserDefaults sharedUserDefaultsForGroupID:self.preferencesID] objectForKey:key];
        [self setObject:result forKey:key]; // Keep consistent with preferences.
    }
    else
    {
        result = [self objectForKey:key];
    }

    return result;
}


#pragma mark - Initializers


/*
 *  - initWithController:dictionary:capacity:preferencesID:
 *    The pseudo-designated initializer for the subclass.
 */
- (instancetype)initWithController:(MGSUserDefaultsController *)controller
                        dictionary:(NSDictionary *)dictionary
                          capacity:(NSUInteger)numItems
                     preferencesID:(NSString *)preferencesID
{
    if ((self = [super init]))
    {
        if (dictionary)
        {
            self.storage = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
        }
        else
        {
            self.storage = [[NSMutableDictionary alloc] initWithCapacity:numItems];
        }

        _controller = controller;
        _preferencesID = preferencesID;
    }

    return self;
}

/*
 *  - initWithController:dictionary:preferencesID:
 */
- (instancetype)initWithController:(MGSUserDefaultsController *)controller
                        dictionary:(NSDictionary *)dictionary
                     preferencesID:(NSString *)preferencesID
{
    return [self initWithController:controller dictionary:dictionary capacity:1 preferencesID:preferencesID ?: controller.groupID];
}


/*
 *  - initWithController:dictionary:capacity
 */
- (instancetype)initWithController:(MGSUserDefaultsController *)controller dictionary:(NSDictionary *)dictionary capacity:(NSUInteger)numItems
{
    return [self initWithController:controller dictionary:dictionary capacity:numItems preferencesID:controller.groupID];
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
 *    The actual designated initializer for this class.
 */
- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    return [self initWithController:nil dictionary:nil capacity:numItems];
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
    return self.storage.count;
}


/*
 * - keyEnumerator
 */
- (NSEnumerator *)keyEnumerator
{
    return self.storage.keyEnumerator;
}


/*
 * - objectForKey:
 */
- (id)objectForKey:(id)aKey
{
    id object = [self.storage objectForKey:aKey];
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
    [self.storage removeObjectForKey:aKey];
}


/*
 * - setObject:forKey:
 */
- (void)setObject:(id)anObject forKey:(id)aKey
{
    if ([anObject isKindOfClass:[NSFont class]] || [anObject isKindOfClass:[NSColor class]])
    {
        [self.storage setObject:[NSArchiver archivedDataWithRootObject:anObject] forKey:aKey];
    }
    else
    {
        [self.storage setObject:anObject forKey:aKey];
    }
}


@end


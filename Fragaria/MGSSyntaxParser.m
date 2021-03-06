//
//  MGSSyntaxParser.m
//  Fragaria
//
//  Created by Daniele Cattaneo on 30/10/2018.
//

#import "MGSSyntaxParser.h"
#import "NSScanner+Fragaria.h"
#import "MGSSyntaxAwareEditor.h"
#import "MGSMutableSubstring.h"


@implementation MGSSyntaxParser


- (NSRange)parseForClient:(id<MGSSyntaxParserClient>)client
{
    return NSMakeRange(0, client.stringToParse.length);
}


#pragma mark - Editor


- (BOOL)providesCommentOrUncomment
{
    return NO;
}


- (void)commentOrUncomment:(NSMutableString *)string
{
}


#pragma mark - Autocompletion


- (NSArray <NSString *> *)completions
{
    return @[];
}


- (NSArray <NSString *> *)autocompletionKeywords
{
    return @[];
}


@end

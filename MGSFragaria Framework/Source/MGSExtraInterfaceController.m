/*
 
 MGSFragaria
 Written by Jonathan Mitchell, jonathan@mugginsoft.com
 Find the latest version at https://github.com/mugginsoft/Fragaria
 
 Smultron version 3.6b1, 2009-09-12
 Written by Peter Borg, pgw3@mac.com
 Find the latest version at http://smultron.sourceforge.net

 Licensed under the Apache License, Version 2.0 (the "License"); you may not use
 this file except in compliance with the License. You may obtain a copy of the
 License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed
 under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 CONDITIONS OF ANY KIND, either express or implied. See the License for the
 specific language governing permissions and limitations under the License.
*/

#import "MGSExtraInterfaceController.h"
#import "SMLTextView+MGSTextActions.h"


@implementation MGSExtraInterfaceController {
    SMLTextView *_completionTarget;
}


- (NSMenu*)contextMenu
{
    if (!_contextMenu)
        [[NSBundle bundleForClass:[self class]] loadNibNamed:@"MGSContextMenu"
                                                       owner:self
                                             topLevelObjects:nil];
    return _contextMenu;
}


#pragma mark -
#pragma mark Tabbing


/*
 * - displayEntab
 */
- (void)displayEntabForTarget:(SMLTextView *)target
{
    NSWindow *wnd;
    
	if (entabWindow == nil) {
        [[NSBundle bundleForClass:[self class]] loadNibNamed:@"SMLEntab"
                                                       owner:self
                                             topLevelObjects:nil];
        spacesTextFieldEntabWindow.integerValue = target.tabWidth;
	}
	
    _completionTarget = target;
    wnd = [_completionTarget window];
    [wnd beginSheet:entabWindow completionHandler:nil];
}


/*
 * - displayDetab
 */
- (void)displayDetabForTarget:(SMLTextView *)target
{
    NSWindow *wnd;
    
	if (detabWindow == nil) {
        [[NSBundle bundleForClass:[self class]] loadNibNamed:@"SMLDetab"
                                                       owner:self
                                             topLevelObjects:nil];
        spacesTextFieldDetabWindow.integerValue = target.tabWidth;
	}
	
    _completionTarget = target;
    wnd = [_completionTarget window];
    [wnd beginSheet:detabWindow completionHandler:nil];
}


/*
 * - entabButtonEntabWindowAction:
 */
- (IBAction)entabButtonEntabWindowAction:(id)sender
{
	NSWindow *wnd = [_completionTarget window];
	
    [wnd endSheet:[wnd attachedSheet]];

    [_completionTarget performEntabWithNumberOfSpaces:[spacesTextFieldEntabWindow integerValue]];
    _completionTarget = nil;
}


/*
 * - detabButtonDetabWindowAction
 */
- (IBAction)detabButtonDetabWindowAction:(id)sender
{
    NSWindow *wnd = [_completionTarget window];
    
    [wnd endSheet:[wnd attachedSheet]];

	[_completionTarget performDetabWithNumberOfSpaces:[spacesTextFieldDetabWindow integerValue]];
    _completionTarget = nil;
}


#pragma mark -
#pragma mark Goto 


/*
 * - cancelButtonEntabDetabGoToLineWindowsAction:
 */
- (IBAction)cancelButtonEntabDetabGoToLineWindowsAction:(id)sender
{
    NSWindow *wnd = [_completionTarget window];

    [wnd endSheet:[wnd attachedSheet]];

    _completionTarget = nil;
}


/*
 * - displayGoToLine
 */
- (void)displayGoToLineForTarget:(SMLTextView *)target
{
    _completionTarget = target;
    NSWindow *wnd = [_completionTarget window];
    
	if (goToLineWindow == nil) {
        [[NSBundle bundleForClass:[self class]] loadNibNamed:@"SMLGoToLine"
                                                       owner:self
                                             topLevelObjects:nil];
	}
	
    [wnd beginSheet:goToLineWindow completionHandler:nil];
}


/*
 * - goButtonGoToLineWindowAction
 */
- (IBAction)goButtonGoToLineWindowAction:(id)sender
{
    NSWindow *wnd = [_completionTarget window];
    
    [NSApp endSheet:[wnd attachedSheet]];
    [[wnd attachedSheet] close];
	
	[_completionTarget performGoToLine:[lineTextFieldGoToLineWindow integerValue] setSelected:YES];
    _completionTarget = nil;
}

@end

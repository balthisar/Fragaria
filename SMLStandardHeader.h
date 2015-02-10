/*
 
 MGSFragaria
 Written by Jonathan Mitchell, jonathan@mugginsoft.com
 Find the latest version at https://github.com/mugginsoft/Fragaria
 
Smultron version 3.6b1, 2009-09-12
Written by Peter Borg, pgw3@mac.com
Find the latest version at http://smultron.sourceforge.net

Copyright 2004-2009 Peter Borg
 
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 
http://www.apache.org/licenses/LICENSE-2.0
 
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/


typedef enum : NSUInteger
{
	SMLDefaultsLineEndings = 0,
	SMLUnixLineEndings = 1,
	SMLMacLineEndings = 2,
	SMLDarkSideLineEndings = 3,
	SMLLeaveLineEndingsUnchanged = 6
} SMLLineEndings;


#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

#import <ApplicationServices/ApplicationServices.h>

#import <WebKit/WebKit.h>

#import <QuartzCore/QuartzCore.h>


#import <unistd.h>

#import <unistd.h>
#import <sys/param.h>
#import <sys/mount.h>
#import <sys/xattr.h>


#define NAME_FOR_UNDO_CHANGE_LINE_ENDINGS NSLocalizedString(@"Change Line Endings", @"Name for undo Change Line Endings")

#define COMMAND_RESULT_WINDOW_TITLE NSLocalizedStringFromTable(@"Command Result - Smultron", @"Localizable3", @"Command Result - Smultron")


#define SMLDefaults [[NSUserDefaultsController sharedUserDefaultsController] values]



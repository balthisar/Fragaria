//
//  MGSColourSchemeSaveController.m
//  Fragaria
//
//  Created by Jim Derry on 3/21/15.
//
//

#import "MGSColourSchemeSaveController.h"


@interface MGSColourSchemeSaveController ()

@property (nonatomic, strong) IBOutlet NSTextField *schemeNameField;

@property (nonatomic, strong) IBOutlet NSButton *bCancel;
@property (nonatomic, strong) IBOutlet NSButton *bSave;

@property (nonatomic, assign) BOOL saveButtonEnabled;

@end

@implementation MGSColourSchemeSaveController {

    void (^deleteCompletion)(BOOL);
}

/*
 * - init
 */
- (instancetype)init
{
    if ((self = [self initWithWindowNibName:@"MGSColourSchemeSave" owner:self]))
    {
    }

    return self;
}


/*
 * - awakeFromNib
 */
- (void)awakeFromNib
{
    [self.window setDefaultButtonCell:[self.bSave cell]];
}


#pragma mark - File Naming Sheet


/*
 * - closeSheet
 */
- (IBAction)closeSheet:(id)sender
{
    NSModalResponse response;
    
    if (sender == self.bSave) {
        NSCharacterSet *cleanCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
        self.fileName = [[self.schemeName componentsSeparatedByCharactersInSet:cleanCharacters] componentsJoinedByString:@""];
        response = NSModalResponseOK;
    } else {
        response = NSModalResponseCancel;
    }

    [self.window.sheetParent endSheet:self.window returnCode:response];
}


/*
 * @property saveButtonEnabled
 */
+ (NSSet *)keyPathsForValuesAffectingSaveButtonEnabled
{
    return [NSSet setWithObject:@"schemeName"];
}

- (BOOL)saveButtonEnabled
{
    NSString *untitled = NSLocalizedStringFromTableInBundle(@"New Scheme", nil, [NSBundle bundleForClass:[self class]],  @"Default name for new schemes.");
    
    return (self.schemeName && [self.schemeName length] > 0 && ![self.schemeName isEqualToString:untitled]);
}


#pragma mark - Delete Dialogue


/*
 * - alertPanel
 */
- (NSAlert *)alertPanel
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Delete", nil, [NSBundle bundleForClass:[self class]],  @"String for delete button.")];
    [alert addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [NSBundle bundleForClass:[self class]],  @"String for cancel button.")];
    [alert setMessageText:NSLocalizedStringFromTableInBundle(@"Delete the scheme?", nil, [NSBundle bundleForClass:[self class]],  @"String to alert.")];
    [alert setInformativeText:NSLocalizedStringFromTableInBundle(@"Deleted schemes cannot be restored.", nil, [NSBundle bundleForClass:[self class]],  @"String for alert information.")];
    [alert setAlertStyle:NSWarningAlertStyle];

    return alert;
}

@end

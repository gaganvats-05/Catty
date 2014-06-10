/**
 *  Copyright (C) 2010-2013 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

#import "BrickDetailViewController.h"
#import "UIDefines.h"
#import "Brick.h"
#import "LanguageTranslationDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "StartScriptCell.h"
#import "WhenScriptCell.h"
#import "BroadcastScriptCell.h"
#import "CellMotionEffect.h"

NS_ENUM(NSInteger, ButtonIndex) {
    kButtonIndexDelete = 0,
    kButtonIndexCopyOrHighlight = 1,
    kButtonIndexEditOrCancel = 2,
    kButtonIndexCancel = 3
};

@interface BrickDetailViewController () <IBActionSheetDelegate>
@property (strong, nonatomic) UITapGestureRecognizer *recognizer;
@property (strong, nonatomic) NSNumber *deleteBrickOrScriptFlag;
@property (strong, nonatomic) NSNumber *brickCopyFlag;
@property (strong, nonatomic) UIMotionEffectGroup *motionEffects;
@property (strong, nonatomic) IBActionSheet *brickMenu;

@end

@implementation BrickDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
    self.deleteBrickOrScriptFlag = [[NSNumber alloc]initWithBool:NO];
    self.brickCopyFlag = [[NSNumber alloc]initWithBool:NO];
    [CellMotionEffect addMotionEffectForView:self.brickCell withDepthX:0.0f withDepthY:25.0f withMotionEffectGroup:self.motionEffects];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.brickMenu showInView:self.view];
    self.recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.recognizer.numberOfTapsRequired = 1;
    self.recognizer.cancelsTouchesInView = NO;
    [self.view.window addGestureRecognizer:self.recognizer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [CellMotionEffect removeMotionEffect:self.motionEffects fromView:self.brickCell];
    self.motionEffects = nil;
    if ([self.view.window.gestureRecognizers containsObject:self.recognizer]) {
        [self.view.window removeGestureRecognizer:self.recognizer];
    }
}


- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if ([sender isKindOfClass:UITapGestureRecognizer.class]) {
        if (sender.state == UIGestureRecognizerStateEnded) {
            CGPoint location = [sender locationInView:nil];
            if (![self.brickCell pointInside:[self.brickCell convertPoint:location fromView:self.view] withEvent:nil] &&
                ![self.brickMenu pointInside:[self.brickMenu convertPoint:location fromView:self.view] withEvent:nil]) {
                [self dismissBrickDetailViewController];
            } else {
                if (!self.brickMenu.visible) {
                    [self.brickMenu showInView:self.view];
                }
            }
        }
    }
}

#pragma mark - getters
- (IBActionSheet *)brickMenu
{
    if (! _brickMenu) {
        _brickMenu = [[IBActionSheet alloc] initWithTitle:nil
                                                 delegate:self
                                        cancelButtonTitle:kUIActionSheetButtonTitleClose
                                   destructiveButtonTitle:[self deleteMenuItemNameWithBrickCell:self.brickCell]
                                        otherButtonTitles:[self secondMenuItemWithBrickCell:self.brickCell],
                      [self editFormulaMenuItemWithVrickCell:self.brickCell], nil];
//        UIColor *color = self.brickCell.brickCategoryColors[self.brickCell.brick.brickCategoryType];
        [_brickMenu setButtonBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.6f]];
        [_brickMenu setButtonTextColor:UIColor.lightOrangeColor];
//        [_brickMenu setButtonBackgroundColor:UIColor.redColor forButtonAtIndex:0];
        [_brickMenu setButtonTextColor:UIColor.redColor forButtonAtIndex:0];
        _brickMenu.transparentView = nil;
    }
    return _brickMenu;
}

- (UIMotionEffectGroup *)motionEffects {
    if (!_motionEffects) {
        _motionEffects = [UIMotionEffectGroup new];
    }
    return _motionEffects;
}

#pragma mark - Action Sheet Delegate
- (void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case kButtonIndexDelete: {
            self.deleteBrickOrScriptFlag = [NSNumber numberWithBool:YES];
            [self dismissBrickDetailViewController];
            break;
        }
            
        case kButtonIndexCopyOrHighlight:
            self.brickCopyFlag = [NSNumber numberWithBool:![self isScript:self.brickCell]];
            [self isScript:self.brickCell] ? NSLog(@"Highlight script...") : [self dismissBrickDetailViewController];
            
            break;
            
        case kButtonIndexEditOrCancel:
            [self isScript:self.brickCell] ? [self dismissBrickDetailViewController] : NSLog(@"Edit Brick...");
            break;
            
            
        case kButtonIndexCancel:
            [self dismissBrickDetailViewController];
            break;
            
        default:
            break;
    }
}

#pragma mark - helper methods
- (void)dismissBrickDetailViewController
{
    if (! self.presentingViewController.isBeingDismissed) {
        [self.brickMenu dismissWithClickedButtonIndex:-1 animated:YES];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            [NSNotificationCenter.defaultCenter postNotificationName:kBrickDetailViewDismissed
                                                              object:NULL
                                                            userInfo:@{@"brickDeleted": self.deleteBrickOrScriptFlag,
                                                                       @"isScript": @([self isScript:self.brickCell]),
                                                                       @"copy": self.brickCopyFlag,
                                                                       @"copiedCell": self.brickCell }];
        }];
    }
}

- (NSString *)deleteMenuItemNameWithBrickCell:(BrickCell *)cell
{
    if ([self isScript:cell]) {
        return kUIActionSheetButtonTitleDeleteScript;
    }
    return kUIActionSheetButtonTitleDeleteBrick;
}

- (NSString *)secondMenuItemWithBrickCell:(BrickCell *)cell
{
    if ([self isScript:cell]) {
        return kUIActionSheetButtonTitleHighlightScript;
    }
    return kUIActionSheetButtonTitleCopyBrick;
}

- (NSString *)editFormulaMenuItemWithVrickCell:(BrickCell *)cell
{
    if ([self isScript:cell]) {
        return nil;
    }
    return kUIActionSheetButtonTitleEditFormula;
}

- (BOOL)isScript:(BrickCell *)brickcell
{
    if ([brickcell isKindOfClass:StartScriptCell.class] ||
        [brickcell isKindOfClass:WhenScriptCell.class] ||
        [brickcell isKindOfClass:BroadcastScriptCell.class]) {
        return YES;
    }
    return NO;
}

@end

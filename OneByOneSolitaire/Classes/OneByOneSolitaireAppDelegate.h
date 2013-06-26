//
//  OneByOneSolitaireAppDelegate.h
//  OneByOneSolitaire
//
//  Created by Javier Alvarez on 10/26/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OneByOneSolitaireViewController;

@interface OneByOneSolitaireAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    OneByOneSolitaireViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet OneByOneSolitaireViewController *viewController;

- (void)createEditableCopyOfDatabaseIfNeeded;

@end


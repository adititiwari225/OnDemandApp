//
//  ConfirmationViewController.h
//  Customer
//
//  Created by Jamshed Ali on 21/06/16.
//  Copyright © 2016 Jamshed Ali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmationViewController : UIViewController<UITextViewDelegate> {
    
    IBOutlet UITextField *activationCodeTextField;
}

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;

@end

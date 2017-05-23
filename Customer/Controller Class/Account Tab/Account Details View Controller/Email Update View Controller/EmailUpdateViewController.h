
//  EmailUpdateViewController.h
//  Customer
//  Created by Jamshed Ali on 20/06/16.
//  Copyright © 2016 Jamshed Ali. All rights reserved.


#import <UIKit/UIKit.h>

@interface EmailUpdateViewController : UIViewController<UITextFieldDelegate> {
    
    IBOutlet UITextField *emailTextField;
}

@property(nonatomic,strong)NSString *userFirstNameStr;
@property(nonatomic,strong)NSString *userEmailStr;

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)nextButtonClicked:(id)sender;

@end

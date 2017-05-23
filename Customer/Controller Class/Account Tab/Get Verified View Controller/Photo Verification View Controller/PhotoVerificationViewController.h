
//  PhotoVerificationViewController.h
//  Customer
//  Created by Jamshed Ali on 21/06/16.
//  Copyright © 2016 Jamshed Ali. All rights reserved.


#import <UIKit/UIKit.h>

@interface PhotoVerificationViewController : UIViewController <UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)proceedButtonClicked:(id)sender;



@end

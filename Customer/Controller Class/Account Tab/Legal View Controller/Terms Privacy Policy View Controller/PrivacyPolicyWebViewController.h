//
//  PrivacyPolicyWebViewController.h
//  Customer
//
//  Created by Jamshed Ali on 15/06/16.
//  Copyright © 2016 Jamshed Ali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrivacyPolicyWebViewController : UIViewController {
    
    IBOutlet UILabel *titleLabel;
}

@property(nonatomic,strong)NSString *termsPrivacyStr;

- (IBAction)backButtonClicked:(id)sender;

@end

//
//  CreditCardVerificationViewController.h
//  Customer
//
//  Created by Jamshed Ali on 21/06/16.
//  Copyright © 2016 Jamshed Ali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreditCardVerificationViewController : UIViewController  {
    IBOutlet UILabel *cardTypeLabel;
}

@property (strong, nonatomic) IBOutlet UITextField *amount;
@property(strong,nonatomic)NSMutableDictionary *accountDataDictionary;
@property(strong,nonatomic)NSString *accountDataStr;
@property(strong,nonatomic)NSString *accountNumberStr;
@property(strong,nonatomic)NSString *accountKeyStr;


@property (assign) BOOL isFromCreditCardAddStr;
@property (assign) BOOL isFromCreditCardAddSxreen;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)submit:(id)sender;


@end

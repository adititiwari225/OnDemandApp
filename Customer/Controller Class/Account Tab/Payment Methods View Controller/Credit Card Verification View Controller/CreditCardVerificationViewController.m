
//  CreditCardVerificationViewController.m
//  Customer
//  Created by Jamshed Ali on 21/06/16.
//  Copyright © 2016 Jamshed Ali. All rights reserved.

#import "CreditCardVerificationViewController.h"
#import "ServerRequest.h"
#import "AccountViewController.h"
#import "AlertView.h"
#import "AppDelegate.h"
@interface CreditCardVerificationViewController () {
    
    SingletonClass *sharedInstance;
    SingletonClass *customObject ;
}
@end

@implementation CreditCardVerificationViewController
@synthesize accountDataDictionary;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    sharedInstance = [SingletonClass sharedInstance];
    customObject = (SingletonClass *)accountDataDictionary;
    NSString *accountStr = [NSString stringWithFormat:@"%@",customObject.accountNumStr];
    
    NSString *codeNumberStr = [accountStr substringFromIndex: [accountStr length] - 4];
    if (_isFromCreditCardAddStr) {
        cardTypeLabel.text =  [NSString stringWithFormat:@"%@",_accountDataStr];
    }
    else{
        cardTypeLabel.text =  [NSString stringWithFormat:@"%@ - XXXX XXXX %@",customObject.bankName,codeNumberStr];
    }
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    _amount.inputAccessoryView = numberToolbar;
    //_amount.text = [NSString stringWithFormat:@"%@",customObject.paymentAmount];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBar.hidden=YES;
    [self.tabBarController.tabBar setHidden:YES];
    if (APPDELEGATE.hubConnection) {
        [APPDELEGATE.hubConnection  reconnecting];
    }
    
}

- (IBAction)backButtonClicked:(id)sender {
    if (self.isFromCreditCardAddStr) {
        AccountViewController *accountView = [self.storyboard instantiateViewControllerWithIdentifier:@"account"];
        accountView.isFromOrderProcess = NO;
        accountView.isFromCreditCardProcess = YES;
        [self.navigationController pushViewController:accountView animated:NO];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
}

- (IBAction)submit:(id)sender {
    
    NSString *encodedUrl ;
    
    if([_amount.text length]==0) {
        UIAlertView *alrtShow=[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Please enter the amount." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alrtShow show];
    }
    else
    {
        if (_isFromCreditCardAddStr) {
            NSString *userIdStr = sharedInstance.userId;
            NSString *urlstr=[NSString stringWithFormat:@"%@?userID=%@&cardNumber=%@&authenticationAmount=%@&VerifyID=%@",APIVerifyCreditCardApiCall,userIdStr,self.accountNumberStr,_amount.text,self.accountKeyStr];
            encodedUrl = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
            NSString *userIdStr = sharedInstance.userId;
            NSString *urlstr=[NSString stringWithFormat:@"%@?userID=%@&cardNumber=%@&authenticationAmount=%@&VerifyID=%@",APIVerifyCreditCardApiCall,userIdStr,customObject.accountNumStr,_amount.text,customObject.VerifyId];
            encodedUrl = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        [ProgressHUD show:@"Please wait..." Interaction:NO];
        [ServerRequest AFNetworkPostRequestUrlForQAPurpose:encodedUrl withParams:nil CallBack:^(id responseObject, NSError *error)
         {
             
             NSLog(@"response object Get UserInfo List %@",responseObject);
             [ProgressHUD dismiss];
             
             if(!error)
             {
                 NSLog(@"Response is --%@",responseObject);
                 if ([[responseObject objectForKey:@"StatusCode"] intValue] ==1)
                 {
                     [[AlertView sharedManager] presentAlertWithTitle:@"Success" message:[responseObject objectForKey:@"Message"]
                                                  andButtonsWithTitle:@[@"Ok"] onController:self
                                                        dismissedWith:^(NSInteger index, NSString *buttonTitle) {
                                                            if ([buttonTitle isEqualToString:@"Ok"]) {
                                                                if (_isFromCreditCardAddSxreen) {
                                                                    AccountViewController *accountView = [self.storyboard instantiateViewControllerWithIdentifier:@"account"];
                                                                    accountView.isFromOrderProcess = NO;
                                                                    accountView.isFromCreditCardProcess = YES;
                                                                    [self.navigationController pushViewController:accountView animated:NO];
                                                                }
                                                                else
                                                                {
                                                                    [self.navigationController popViewControllerAnimated:YES];
                                                                    
                                                                }
                                                            }
                                                        }];
                     
                 }
                 else
                 {
                     [self.view endEditing:YES];
                     [CommonUtils showAlertWithTitle:@"Alert!" withMsg:[responseObject objectForKey:@"Message"] inController:self];
                 }
             } else {
                 
                 NSLog(@"Error");
             }
         }];
    }
    
}

-(void)doneWithNumberPad{
    [self.view endEditing:YES];
}

- (IBAction)comeBackLater:(id)sender {
    
    NSArray *viewControlles = self.navigationController.viewControllers;
    for (id object in viewControlles) {
        if ([object isKindOfClass:[AccountViewController class]]) {
            AccountViewController *accountView = [self.storyboard instantiateViewControllerWithIdentifier:@"account"];
            [self.navigationController pushViewController:accountView animated:NO];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

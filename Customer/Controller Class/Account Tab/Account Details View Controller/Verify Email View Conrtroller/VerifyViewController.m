
//  VerifyViewController.m
//  Customer
//  Created by Jamshed Ali on 20/06/16.
//  Copyright © 2016 Jamshed Ali. All rights reserved.


#import "VerifyViewController.h"
#import "AccountViewController.h"
#import "ServerRequest.h"
#import "AppDelegate.h"
@interface VerifyViewController () {
    
    SingletonClass *sharedInstance;
    NSString *userIdStr;
    
}

@end

@implementation VerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    sharedInstance = [SingletonClass sharedInstance];
    userIdStr = sharedInstance.userId;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden=YES;
    [self.tabBarController.tabBar setHidden:YES];
    
    if (APPDELEGATE.hubConnection) {
        [APPDELEGATE.hubConnection  start];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Done Button Method Call

- (IBAction)doneButtonClicked:(id)sender {
    
    if([codeTextField.text length]==0) {
        
        UIAlertView *alrtShow=[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Please insert the code." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alrtShow show];
        
    }
    else {
        
        [self updateEmailApiCall];
        
    }
}


#pragma mark-- Update Email Code Verify API Call

- (void)updateEmailApiCall {
    
    NSString *urlstr=[NSString stringWithFormat:@"%@?userID=%@&VerificationCode=%@",APIEmailCodeVerify,userIdStr,codeTextField.text];
    NSString *encodedUrl = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [ProgressHUD show:@"Please wait..." Interaction:NO];
    [ServerRequest AFNetworkPostRequestUrl:encodedUrl withParams:nil CallBack:^(id responseObject, NSError *error) {
        NSLog(@"response object Get UserInfo List %@",responseObject);
        [ProgressHUD dismiss];
        if(!error){
            
            NSLog(@"Response is --%@",responseObject);
            
            if ([[responseObject objectForKey:@"StatusCode"] intValue] ==1) {
                
                AccountViewController *confirmCodeView = [self.storyboard instantiateViewControllerWithIdentifier:@"account"];
                [self.navigationController pushViewController:confirmCodeView animated:YES];
                
            } else {
                
                [CommonUtils showAlertWithTitle:@"Alert!" withMsg:[responseObject objectForKey:@"Message"] inController:self];
            }
        }
    }];
}

@end


//  EmailNotificationTypeSelectViewController.m
//  Customer
//  Created by Jamshed Ali on 15/06/16.
//  Copyright © 2016 Jamshed Ali. All rights reserved.


#import "EmailNotificationTypeSelectViewController.h"
#import "NotificationTableViewCell.h"
#import "ServerRequest.h"
#import "AppDelegate.h"
@interface EmailNotificationTypeSelectViewController () {
    
    NSArray *titleArray;
    NSString *settingsOnStr;
    
    SingletonClass *sharedInstance;
    
    NSString *userIdStr;
}

@end

@implementation EmailNotificationTypeSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBar.hidden=YES;
    [self.tabBarController.tabBar setHidden:YES];
    sharedInstance = [SingletonClass sharedInstance];
    userIdStr = sharedInstance.userId;
    titleArray = @[@"Announcements",@"New Messages",@"Date Accepted",@"Date Declined",@"Date Expired",@"Date Arrived",@"Date Started",@"Date Completed",@"Date Cancelled",@"Date Summary"];
    emailSettingsData = [[NSMutableArray alloc]init];
    if (APPDELEGATE.hubConnection) {
        [APPDELEGATE.hubConnection  reconnecting];
    }
    [self fetchEmailNotificationSettingsApiCall];
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (emailSettingsData.count) {
        return emailSettingsData.count;
        
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NotificationTableViewCell *cell;
    cell = nil;
    SingletonClass *customObject = [emailSettingsData objectAtIndex:indexPath.row];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right-dark.png"]];
    [imageView setFrame:CGRectMake(0, 0, 15, 15)];
    
    if (cell == nil) {
        
        cell = (NotificationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Noti"];
        BOOL settingOnValue = customObject.strIsEmailNotification;
        if (settingOnValue == 1) {
            UIImageView *selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width, 15, 20, 20)];
            selectImageView.image = [UIImage imageNamed:@"select"];
            [cell.contentView addSubview:selectImageView];
        }
    }
    cell.nameLbl.text = customObject.strEventType;
    if(customObject.strIsSelectedNotification == YES){
        cell.accessoryView = imageView;
        //customObject.checkLocationStr = NO;
    }
    else {
        cell.accessoryView = NULL;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }     return cell;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SingletonClass *customObj= [emailSettingsData objectAtIndex:indexPath.row];
    
    if (customObj.strIsSelectedNotification) {
        settingsOnStr = customObj.strEventType;
        [self updateEmailNotificationSettingsApiData:customObj.strEventType withStatus:@"0"];
    }
    else{
        [self updateEmailNotificationSettingsApiData:customObj.strEventType withStatus:@"1"];
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)backButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark-- Get Push Notificatioin API Call

-(void)fetchEmailNotificationSettingsApiCall
{
    NSString *userIdString = sharedInstance.userId;
    NSMutableDictionary *params=[[NSMutableDictionary alloc]initWithObjectsAndKeys:userIdString,@"userID",@"listEmailNotification",@"NotificationType",nil];
    [ProgressHUD show:@"Please wait..." Interaction:NO];
    [ServerRequest requestWithUrlForQA:APIEmailNotificationSettings withParams:params CallBack:^(id responseObject, NSError *error) {
        NSLog(@"response object Get UserInfo List %@",responseObject);
        
        [ProgressHUD dismiss];
        
        if(!error){
            NSLog(@"Response is --%@",responseObject);
            if ([[responseObject objectForKey:@"StatusCode"] intValue] ==1) {
                NSDictionary *pushSettingsDictionary = [responseObject objectForKey:@"result"];
                NSArray *arrData = [pushSettingsDictionary objectForKey:@"MasterValues"];
                emailSettingsData = [SingletonClass parseDateForLocation:arrData];
                for (SingletonClass *customerObject in emailSettingsData) {
                    NSString *string = [NSString stringWithFormat:@"%@", customerObject.strIsEmailNotification];
                    if ([string  isEqualToString:@"1"]) {
                        customerObject.strIsSelectedNotification = YES;
                    }
                }
                [emailNotificationTableView reloadData];
            }
            else
            {
                [CommonUtils showAlertWithTitle:@"Alert!" withMsg:[responseObject objectForKey:@"Message"] inController:self];
            }
        }
    }];
}


#pragma mark-- Update Email Notification API

- (void)updateEmailNotificationSettingsApiData:(NSString *)value withStatus:(NSString *)status
{
    NSString *userIdString = sharedInstance.userId;
    //    NSMutableDictionary *params=[[NSMutableDictionary alloc]initWithObjectsAndKeys:userIdStr,@"userID",@"listEmailNotification",@"NotificationType",nil];
    NSString *urlstr=[NSString stringWithFormat:@"%@?userID=%@&eventName=%@&status=%@",APIUpdateEmailNotificationSettings,userIdString,value,status];
    NSString *encodedUrl = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [ProgressHUD show:@"Please wait..." Interaction:NO];
    [ServerRequest AFNetworkPostRequestUrlForQA:encodedUrl withParams:nil CallBack:^(id responseObject, NSError *error) {
        NSLog(@"response object Get UserInfo List %@",responseObject);
        
        [ProgressHUD dismiss];
        if(!error){
            
            NSLog(@"Response is --%@",responseObject);
            
            if ([[responseObject objectForKey:@"StatusCode"] intValue] ==1) {
                
                NSDictionary *pushSettingsDictionary = [responseObject objectForKey:@"result"];
                NSArray *arrData = [pushSettingsDictionary objectForKey:@"MasterValues"];
                emailSettingsData = [SingletonClass parseDateForLocation:arrData];
                for (SingletonClass *customerObject in emailSettingsData) {
                    NSString *string = [NSString stringWithFormat:@"%@", customerObject.strIsEmailNotification];
                    if( [string isEqualToString:@"1"]) {
                        customerObject.strIsSelectedNotification = YES;
                    }
                }
                [emailNotificationTableView reloadData];
            } else {
                
                [CommonUtils showAlertWithTitle:@"Alert!" withMsg:[responseObject objectForKey:@"Message"] inController:self];
            }
        }
        
    }];
}


@end

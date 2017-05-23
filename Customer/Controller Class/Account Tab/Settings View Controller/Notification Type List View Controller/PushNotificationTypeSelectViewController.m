//
//  PushNotificationTypeSelectViewController.m
//  Customer
//
//  Created by Jamshed Ali on 15/06/16.
//  Copyright © 2016 Jamshed Ali. All rights reserved.
//

#import "PushNotificationTypeSelectViewController.h"
#import "NotificationTableViewCell.h"
#import "ServerRequest.h"
#import "AppDelegate.h"
@interface PushNotificationTypeSelectViewController () {
    
    NSArray *titleArray;
    NSString *settingOnStr;
    NSInteger selectedIndex;
    NSInteger selectedSection;
    NSMutableArray *arrDataSource;
    SingletonClass *sharedInstance;
    NSString *userIdStr;
    
}

@end

@implementation PushNotificationTypeSelectViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    pushSettingsData = [[NSMutableArray alloc]init];
    arrDataSource = [NSMutableArray array];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBar.hidden=YES;
    [self.tabBarController.tabBar setHidden:YES];
    
    sharedInstance = [SingletonClass sharedInstance];
    userIdStr = sharedInstance.userId;
    if (APPDELEGATE.hubConnection) {
        [APPDELEGATE.hubConnection  reconnecting];
    }
    titleArray = @[@"Announcements",@"New Messages",@"Date Accepted",@"Date Declined",@"Date Expired",@"Date Arrived",@"Date Started",@"Date Completed",@"Date Cancelled",@"Data Summary"];
    
    pushNotificationTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self fetchPushNotificationSettingsApiCall];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (pushSettingsData.count) {
        return pushSettingsData.count;
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
    SingletonClass *customObject = [pushSettingsData objectAtIndex:indexPath.row];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right-dark.png"]];
    [imageView setFrame:CGRectMake(0, 0, 15, 15)];
    
    if (cell == nil) {
        
        cell = (NotificationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Noti"];
        BOOL settingOnValue = customObject.strIsMobileNotification;
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
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SingletonClass *customObj= [pushSettingsData objectAtIndex:indexPath.row];
    
    if (customObj.strIsSelectedNotification) {
        settingOnStr = customObj.strEventType;
        [self updatePushNotificationSettingsApiDataWithData:customObj.strEventType withStatus:@"0"];
        
        
    }
    else{
        [self updatePushNotificationSettingsApiDataWithData:customObj.strEventType withStatus:@"1"];
        
    }
    //  [self updatePushNotificationSettingsApiData];
    
    // [pushNotificationTableView reloadData];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)backButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark-- Get Push Notificatioin API Call

-(void)fetchPushNotificationSettingsApiCall
{
    //   NSString *userIdStr = [[NSUserDefaults standardUserDefaults]objectForKey:@"USERIDDATA"];
    
    NSString *userIdString = sharedInstance.userId;
    
    NSMutableDictionary *params=[[NSMutableDictionary alloc]initWithObjectsAndKeys:userIdString,@"userID",@"listMobilelNotification",@"NotificationType",nil];
    
    [ProgressHUD show:@"Please wait..." Interaction:NO];
    [ServerRequest requestWithUrlForQA:APIGetPushnotificationSettings withParams:params CallBack:^(id responseObject, NSError *error) {
        NSLog(@"response object Get UserInfo List %@",responseObject);
        
        [ProgressHUD dismiss];
        
        if(!error){
            NSLog(@"Response is --%@",responseObject);
            if ([[responseObject objectForKey:@"StatusCode"] intValue] ==1) {
                
                
                NSDictionary *pushSettingsDictionary = [responseObject objectForKey:@"result"];
                NSArray *arrData = [pushSettingsDictionary objectForKey:@"MasterValues"];
                pushSettingsData = [SingletonClass parseDateForLocation:arrData];
                for (SingletonClass *customerObject in pushSettingsData) {
                    NSString *string = [NSString stringWithFormat:@"%@", customerObject.strIsMobileNotification];
                    if ([string  isEqualToString:@"1"]) {
                        customerObject.strIsSelectedNotification = YES;
                    }
                }
                [pushNotificationTableView reloadData];
            }
            else
            {
                [CommonUtils showAlertWithTitle:@"Alert!" withMsg:[responseObject objectForKey:@"Message"] inController:self];
            }
        }
    }];
}

#pragma mark-- Update Push Notification API

- (void)updatePushNotificationSettingsApiDataWithData:(NSString *)value withStatus:(NSString *)status
{
    
    // Update push Notification   http://ondemandapi.flexsin.in/API/Account/UpdateMobileNotification?userID=Cu009fe53&eventName=Announcements&status=0
    //  NSString *userIdStr = [[NSUserDefaults standardUserDefaults]objectForKey:@"USERIDDATA"];
    NSString *userIdString = sharedInstance.userId;
    NSString *urlstr=[NSString stringWithFormat:@"%@?userID=%@&eventName=%@&status=%@",APIUpdatePushnotificationSettings,userIdString,value,status];
    //    NSMutableDictionary *params=[[NSMutableDictionary alloc]initWithObjectsAndKeys:userIdStr,@"userID",@"eventName",@"attributeType",@"1",value,nil];
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
                pushSettingsData = [SingletonClass parseDateForLocation:arrData];
                for (SingletonClass *customerObject in pushSettingsData) {
                    NSString *string = [NSString stringWithFormat:@"%@", customerObject.strIsMobileNotification];
                    if( [string isEqualToString:@"1"]) {
                        customerObject.strIsSelectedNotification = YES;
                    }
                }
                [pushNotificationTableView reloadData];
                
            } else {
                
                [CommonUtils showAlertWithTitle:@"Alert!" withMsg:[responseObject objectForKey:@"Message"] inController:self];
            }
        }
        
    }];
}

@end

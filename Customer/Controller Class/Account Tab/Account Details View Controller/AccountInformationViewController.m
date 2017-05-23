
//  AccountInformationViewController.m
//  Customer
//  Created by Jamshed Ali on 15/06/16.
//  Copyright © 2016 Jamshed Ali. All rights reserved.

#import "AccountInformationViewController.h"
#import "EmailUpdateViewController.h"
#import "ChangePasswordViewController.h"
#import "InterestViewController.h"
#import "UpdateMobileNumberViewController.h"
#import "CloseAccountViewController.h"
#import "SingletonClass.h"
#import "ServerRequest.h"
#import "NotificationTableViewCell.h"
#import "AppDelegate.h"

@interface AccountInformationViewController () {
    
    NSArray *titleArray;
    NSArray *dataArray;
    NSString *firstNameStr;
    NSString *emailStr;
    NSString *passwordStr;
    NSString *mobileNumberStr;
    NSString *interestedInStr;
    NSString *userIdStr;
    SingletonClass *sharedInstance;
    UITextField  *alertText ;
    UIDatePicker *picker;
    NSDateFormatter *dateFormat;
    NSDate *convertDate;
}

@end

@implementation AccountInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    tabledataArray = [[NSMutableArray alloc]init];
    sharedInstance = [SingletonClass sharedInstance];
    userIdStr = sharedInstance.userId;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    if (APPDELEGATE.hubConnection) {
        [APPDELEGATE.hubConnection  reconnecting];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"UserInfoDataarr"];
    tabledataArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSDictionary *dictdata = [tabledataArray objectAtIndex:0];
    emailStr = [dictdata valueForKey:@"Email"];
    passwordStr = [dictdata valueForKey:@"Password"];
    firstNameStr = [dictdata valueForKey:@"FirstName"];
    NSString *lastNameStr = [dictdata valueForKey:@"LastName"];
    NSString *birthDateStr = [dictdata valueForKey:@"BirthDate"];
    NSString *birthMonthStr = [dictdata valueForKey:@"BirthMonth"];
    NSString *birthYearStr = [dictdata valueForKey:@"BirthYear"];
    NSString *dateOfBirthStr= [NSString stringWithFormat: @"%@/%@/%@",birthMonthStr,birthDateStr,birthYearStr];
    NSString *genderStr = [dictdata valueForKey:@"Gender"];
    interestedInStr = [dictdata valueForKey:@"InterestedIn"];
    mobileNumberStr = [dictdata valueForKey:@"MobileNumber"];
    titleArray = @[@"Email",@"Password",@"First Name",@"Last Name",@"Date of Birth",@"I am a"];
    dataArray = @[emailStr,passwordStr,firstNameStr,lastNameStr,dateOfBirthStr,genderStr];
    accountTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.navigationBar.hidden=YES;
    [self.tabBarController.tabBar setHidden:YES];
    [self fetchUserInfoApiData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationTableViewCell *cell;
    cell = (NotificationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Noti"];
    cell.nameLbl.text = [titleArray objectAtIndex:indexPath.row];
    cell.dateLbl.text = [dataArray objectAtIndex:indexPath.row];
    
    if (indexPath.row == 0 ||indexPath.row == 1) {
        
        cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
        
        if (indexPath.row == 1) {
            NSString *myPickerValue = [dataArray objectAtIndex:indexPath.row];
            cell.dateLbl.text = [@"" stringByPaddingToLength: [myPickerValue length] withString: @"*" startingAtIndex:0];
        }
    }
    if (indexPath.row == 4){
        dateFormat = [[NSDateFormatter alloc]init];
        //   [dateFormat setDateStyle:NSDateFormatterMediumStyle];
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
        convertDate = [dateFormat dateFromString:[dataArray objectAtIndex:indexPath.row]];
    }
    
    if (indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4) {
        if ([sharedInstance.isEditStr isEqualToString:@"0"]) {
            [cell setUserInteractionEnabled:NO];
        }
        else{
            [cell setUserInteractionEnabled:YES];
        }
    }
    
    if (indexPath.row == 5 ||indexPath.row == 6 || indexPath.row == 7) {
        [cell setUserInteractionEnabled:NO];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertView * alert ;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:{
            EmailUpdateViewController *emailView = [self.storyboard instantiateViewControllerWithIdentifier:@"emailUpdate"];
            emailView.userEmailStr = emailStr;
            emailView.userFirstNameStr = firstNameStr;
            [self.navigationController pushViewController:emailView animated:YES];
        }
            break;
            
        case 1:{
            
            ChangePasswordViewController *changePasswordView = [self.storyboard instantiateViewControllerWithIdentifier:@"changePassword"];
            changePasswordView.userPasswordStr = passwordStr;
            [self.navigationController pushViewController:changePasswordView animated:YES];
        }
            break;
        case 2:{
            alert = [[UIAlertView alloc ] initWithTitle:@"First Name" message:@"Enter Your First Name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = ALERT_TYPE_FIRSTNAME;
            alertText = [alert textFieldAtIndex:0];
            [alertText setText:[dataArray objectAtIndex:indexPath.row]];
            [alertText setPlaceholder:@"Enter Your First Name"];
            
            [alert addButtonWithTitle:@"Update"];
            [alert show];
        }
            break;
        case 3:{
            alert = [[UIAlertView alloc ] initWithTitle:@"Last Name" message:@"Enter Your Last Name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = ALERT_TYPE_LASTNAME;
            alertText = [alert textFieldAtIndex:0];
            [alertText setText:[dataArray objectAtIndex:indexPath.row]];
            [alertText setPlaceholder:@"Enter Your Last Name"];
            [alert addButtonWithTitle:@"Update"];
            [alert show];
        }
            break;
        case 4:{
            
            alert = [[UIAlertView alloc ] initWithTitle:@"Date Of Birth" message:@"Select Your DOB" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(10, alert.bounds.size.height, 320, 216)];
            picker.datePickerMode = UIDatePickerModeDate;
            [picker setDate:convertDate];
            alertText = [alert textFieldAtIndex:0];
            [alertText setText:[dataArray objectAtIndex:indexPath.row]];
          // [self setMinAndMaxDateForPicker:picker];
            alertText.inputView=picker;
            [picker addTarget:self action:@selector(firstTF) forControlEvents:UIControlEventValueChanged];
            [alertText setPlaceholder:@"Select Your DOB"];
            alert.tag = ALERT_TYPE_DOB;
            [alert addButtonWithTitle:@"Update"];
            [alert show];
        }
            break;
        case 5:{
            //            EmailUpdateViewController *emailView = [self.storyboard instantiateViewControllerWithIdentifier:@"emailUpdate"];
            //            emailView.userEmailStr = emailStr;
            //            emailView.userFirstNameStr = firstNameStr;
            //
            //            [self.navigationController pushViewController:emailView animated:YES];
        }
            break;
        case 6:{
            //            InterestViewController *interestView = [self.storyboard instantiateViewControllerWithIdentifier:@"interest"];
            //            interestView.self.userInterestedInStr = interestedInStr;
            //            [self.navigationController pushViewController:interestView animated:YES];
        }
            break;
        case 7:{
            //            UpdateMobileNumberViewController *updateMobileView = [self.storyboard instantiateViewControllerWithIdentifier:@"mobile"];
            //            updateMobileView.userMobileNmbrStr = mobileNumberStr;
            //            [self.navigationController pushViewController:updateMobileView animated:YES];
        }
            break;
        default:
            break;
    }
}

-(void)setMinAndMaxDateForPicker:(UIDatePicker *)pickerSelected{
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:30];
    //  NSDate *maxDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    [comps setYear:-90];
    NSDate *minDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    pickerSelected.minimumDate = minDate;
    pickerSelected.maximumDate = [NSDate date];
}

- (void)firstTF
{
    
    NSDate *date = picker.date;
    NSDateFormatter *date1 = [[NSDateFormatter alloc]init];
    [date1 setDateFormat:@"yyyy-MM-dd"];
    NSString *str = [date1 stringFromDate:date];
    alertText.text = [self changeDateINString:str WithFormate:@"yyyy-MM-dd"];
}

-(NSString *)changeDateINString :(NSString *)string WithFormate:(NSString *)formate{
    
    NSDateFormatter *date = [[NSDateFormatter alloc]init];
    [date setDateFormat:formate];
    NSDate *formatedDate = [date dateFromString:string];
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"MM/dd/yyyy"];
    NSString *dateRepresentation = [dateFormatter1 stringFromDate:formatedDate];
    return dateRepresentation;
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    NSLog(@"Alert Tag %ld",(long)alertView.tag);
    switch (alertView.tag) {
            
        case 100:{
            NSLog(@"Button Index =%ld",(long)buttonIndex);
            if (buttonIndex == 1) {
                UITextField *username = [alertView textFieldAtIndex:0];
                NSLog(@"username: %@", username.text);
                if([username.text length]==0) {
                    
                    UIAlertView *alrtShow=[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Please insert the firstname." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alrtShow show];
                    
                }
                else
                {
                    [self  callChangeProfieApiwithAttributeType:@"FirstName" withValue:username.text];
                    
                }
            }
            
        }
            break;
        case 101:{
            
            NSLog(@"Button Index =%ld",(long)buttonIndex);
            if (buttonIndex == 1) {
                UITextField *username = [alertView textFieldAtIndex:0];
                NSLog(@"username: %@", username.text);
                if([username.text length]==0) {
                    
                    UIAlertView *alrtShow=[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Please insert the lastname." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alrtShow show];
                    
                } else
                {
                    [self  callChangeProfieApiwithAttributeType:@"LastName" withValue:username.text];
                }
            }
            
        }
            break;
        case 102:{
            
            NSLog(@"Button Index =%ld",(long)buttonIndex);
            if (buttonIndex == 1) {
                
                UITextField *username = [alertView textFieldAtIndex:0];
                NSLog(@"username: %@", username.text);
                if([username.text length]==0) {
                    UIAlertView *alrtShow=[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Please select the DOB." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alrtShow show];
                    
                } else
                {
                    [self  callChangeProfieApiwithAttributeType:@"DateOfBirth" withValue:alertText.text];
                }
            }
        }
            break;
        default:
            break;
    }
}


#pragma mark:- Call Api For Update
-(void)callChangeProfieApiwithAttributeType:(NSString *)attribute withValue:(NSString *)attributeValue {
    
    NSString *usrId = sharedInstance.userId;
    NSLog(@"ID%@",usrId);
    NSString *urlstr =[NSString stringWithFormat:@"%@?userID=%@&attributeType=%@&attributeValue=%@",APIChangeProfileData,userIdStr,attribute,attributeValue];
    NSString *encoded = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [ProgressHUD show:@"Please wait..." Interaction:NO];
    [ServerRequest AFNetworkPostRequestUrlForQAPurpose:encoded withParams:nil CallBack:^(id responseObject, NSError *error) {
        NSLog(@"response object Get UserInfo List %@",responseObject);
        [ProgressHUD dismiss];
        if(!error){
            NSLog(@"Response is --%@",responseObject);
            if ([[responseObject objectForKey:@"StatusCode"] intValue] ==1)
            {
                [self fetchUserInfoApiData];
                [accountTableView reloadData];
            }
            else
            {
                [CommonUtils showAlertWithTitle:@"Alert!" withMsg:[responseObject objectForKey:@"Message"] inController:self];
            }
        }
    }];
}


- (void)fetchUserInfoApiData {
    
    //NSString *userIdStr = sharedInstance.userId;
    
    NSMutableDictionary *params=[[NSMutableDictionary alloc]initWithObjectsAndKeys:userIdStr,@"userID",nil];
    [ProgressHUD show:@"Please wait..." Interaction:NO];
    [ServerRequest requestWithUrlForQA:APIAccountUserInfo withParams:params CallBack:^(id responseObject, NSError *error) {
        NSLog(@"response object Get UserInfo List %@",responseObject);
        
        [ProgressHUD dismiss];
        
        if(!error){
            
            NSLog(@"Response is --%@",responseObject);
            
            if ([[responseObject objectForKey:@"StatusCode"] intValue] ==1) {
                NSDictionary *resultDict = [responseObject objectForKey:@"result"];
                sharedInstance.firstNameStr = [resultDict valueForKey:@"FirstName"];
                sharedInstance.lastNameStr = [resultDict valueForKey:@"LastName"];
                sharedInstance.isEditStr =       [resultDict valueForKey:@"IsVarEdit"];
                sharedInstance.interestedGender = [resultDict valueForKey:@"InterestedIn"];
                sharedInstance.mobileNumberStr = [resultDict valueForKey:@"MobileNumber"];
                userInfoArr = [[NSMutableArray alloc]init];
                [userInfoArr addObject:resultDict];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userInfoArr];
                [defaults setObject:data forKey:@"UserInfoDataarr"];
                
                NSData *dataObject = [defaults objectForKey:@"UserInfoDataarr"];
                tabledataArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataObject];
                
                NSDictionary *dictdata = [tabledataArray objectAtIndex:0];
                emailStr = [dictdata valueForKey:@"Email"];
                passwordStr = [dictdata valueForKey:@"Password"];
                firstNameStr = [dictdata valueForKey:@"FirstName"];
                
                NSString *lastNameStr = [dictdata valueForKey:@"LastName"];
                NSString *birthDateStr = [dictdata valueForKey:@"BirthDate"];
                NSString *birthMonthStr = [dictdata valueForKey:@"BirthMonth"];
                NSString *birthYearStr = [dictdata valueForKey:@"BirthYear"];
                NSString *dateOfBirthStr= [NSString stringWithFormat: @"%@/%@/%@", birthMonthStr,birthDateStr,birthYearStr];
                NSString *genderStr = [dictdata valueForKey:@"Gender"];
                interestedInStr = [dictdata valueForKey:@"InterestedIn"];
                mobileNumberStr = [dictdata valueForKey:@"MobileNumber"];
                titleArray = @[@"Email",@"Password",@"First Name",@"Last Name",@"Date of Birth",@"I am a"];
                dataArray = @[emailStr,passwordStr,firstNameStr,lastNameStr,dateOfBirthStr,genderStr];
                [accountTableView reloadData];
            }
            else
            {
                [CommonUtils showAlertWithTitle:@"Alert!" withMsg:[responseObject objectForKey:@"Message"] inController:self];
            }
        }
    }];
}


- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    
    if( [inputText length] > 0)
    {
        NSLog(@"alertViewShouldEnableFirstOtherButton: was called!");
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma maek : UIButton Action Method
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveInformationButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)closeAccountButtonClicked:(id)sender {
    CloseAccountViewController *closeAccountView = [self.storyboard instantiateViewControllerWithIdentifier:@"closeAccount"];
    [self.navigationController pushViewController:closeAccountView animated:YES];
}


@end


//  FavoritesViewController.m
//  Customer
//  Created by Jamshed Ali on 14/06/16.
//  Copyright © 2016 Jamshed Ali. All rights reserved.


#import "FavoritesViewController.h"
#import "ChatUserTableViewCell.h"
#import "ServerRequest.h"
#import "Define.h"
#import "AlertView.h"
#import "ProfileDetailsViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "AppDelegate.h"

@interface FavoritesViewController () {
    
    NSMutableArray *dataArray;
    SingletonClass *sharedInstance;
    NSString *userIdStr;
}

@property (weak, nonatomic) IBOutlet UILabel *dontHaveLabel;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteImageView;

@end

@implementation FavoritesViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    sharedInstance = [SingletonClass sharedInstance];
    userIdStr = sharedInstance.userId;
    self.tableDataArray = [[NSMutableArray alloc]init];
    [self.dontHaveLabel setHidden:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    [self.favoriteImageView setHidden:YES];
    dataArray = [[NSMutableArray alloc]initWithObjects:@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1", nil];
    favoritesTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self fetchFavoritesUserListApiData];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.navigationBar.hidden=YES;
    [self.tabBarController.tabBar setHidden:YES];
    if (APPDELEGATE.hubConnection) {
        [APPDELEGATE.hubConnection  reconnecting];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableDataArray.count) {
        return self.tableDataArray.count;
        
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 85.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    ChatUserTableViewCell *cell;
    cell = (ChatUserTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"chat"];
    cell.dateLbl.text = @"";
    NSMutableDictionary *dataDictionary = [self.tableDataArray objectAtIndex:indexPath.row];
    if ([[dataDictionary valueForKey:@"Name"] isKindOfClass:[NSString class]]) {
        cell.nameLbl.text = [dataDictionary valueForKey:@"Name"];
        
    } else {
        cell.nameLbl.text = @"";
    }
    
    cell.messageLbl.text = [NSString stringWithFormat:@"%@ | %@ | %@ ",[dataDictionary valueForKey:@"Ethnicity"],[dataDictionary valueForKey:@"Age"],[dataDictionary valueForKey:@"Height"]];
    NSURL *imageUrl = [NSURL URLWithString:[dataDictionary valueForKey:@"PicUrl"]];
    [cell.userImageView setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"user_default"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //    [cell.userImageView sd_setImageWithURL:imageUrl
    //                          placeholderImage:[UIImage imageNamed:@"user_default"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *contractorId = [NSString stringWithFormat:@"%@",[[self.tableDataArray objectAtIndex:indexPath.row]valueForKey:@"ID"]];
    NSString *isOfflinevlaue = [NSString stringWithFormat:@"%@",[[self.tableDataArray objectAtIndex:indexPath.row]valueForKey:@"isOnline"]];
    ProfileDetailsViewController *profileDetailsView = [self.storyboard instantiateViewControllerWithIdentifier:@"contractorProfile"];
    profileDetailsView.self.contractorIdStr = contractorId;
    if ([[[_tableDataArray objectAtIndex:indexPath.row]valueForKey:@"IsOnline"]isEqualToString:@"False"]) {
        profileDetailsView.self.isOnlineStr = @"0";
    }
    else{
        profileDetailsView.self.isOnlineStr = @"1";
        
    }
    profileDetailsView.isOnlineStr = isOfflinevlaue;
    [self.navigationController pushViewController:profileDetailsView animated:YES];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //        [[AlertView sharedManager] presentAlertWithTitle:@"Alert!" message:@"Are you sure you want to delete this user from favorite list."
        //                                     andButtonsWithTitle:@[@"No",@"Yes"] onController:self
        //                                           dismissedWith:^(NSInteger index, NSString *buttonTitle) {
        //                                               if ([buttonTitle isEqualToString:@"Yes"]) {
        NSMutableDictionary *dataDictionary = [self.tableDataArray objectAtIndex:indexPath.row];
        
        NSString *toUserIdStr = [dataDictionary valueForKey:@"ID"];
        
        NSString *urlstr=[NSString stringWithFormat:@"%@?userIDTO=%@&userIDFrom=%@",APIDeleteFavouriteUser,toUserIdStr,userIdStr];
        
        NSString *encodedUrl = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [ProgressHUD show:@"Please wait..." Interaction:NO];
        [ServerRequest AFNetworkPostRequestUrl:encodedUrl withParams:nil CallBack:^(id responseObject, NSError *error) {
            NSLog(@"response object Get UserInfo List %@",responseObject);
            [ProgressHUD dismiss];
            
            if(!error){
                NSLog(@"Response is --%@",responseObject);
                
                if ([[responseObject objectForKey:@"StatusCode"] intValue] ==1) {
                   NSMutableArray *tempArray = [self.tableDataArray mutableCopy];
                    [tempArray removeObjectAtIndex:indexPath.row];
                    self.tableDataArray = [tempArray mutableCopy];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    if (self.tableDataArray.count) {
                        [self.view setBackgroundColor:[UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0]];
                        
                        [self.dontHaveLabel setHidden:YES];
                        [self.favoriteImageView setHidden:YES];
                    }
                    else {
                        [self.view setBackgroundColor:[UIColor whiteColor]];
                        
                        [self.dontHaveLabel setHidden:NO];
                        [self.favoriteImageView setHidden:NO];
                    }
                    [favoritesTableView reloadData];
                    
                }
                else {
                    
                    [CommonUtils showAlertWithTitle:@"Alert!" withMsg:[responseObject objectForKey:@"Message"] inController:self];
                }
            }
        }];
    }
}

#pragma mark-- Favorites API

- (void)fetchFavoritesUserListApiData {
    
    
    NSMutableDictionary *params=[[NSMutableDictionary alloc]initWithObjectsAndKeys:userIdStr,@"userID",@"1",@"PageNumber",nil];
    
    [ProgressHUD show:@"Please wait..." Interaction:NO];
    
    [ServerRequest requestWithUrlForQA:APIFavouriteUserList withParams:params CallBack:^(id responseObject, NSError *error) {
        NSLog(@"response object Get favorites User List %@",responseObject);
        
        [ProgressHUD dismiss];
        
        if(!error){
            
            NSLog(@"Response is --%@",responseObject);
            
            if ([[responseObject objectForKey:@"StatusCode"] intValue] ==1) {
                
                NSDictionary *resultDict = [responseObject objectForKey:@"result"];
                self.tableDataArray =[[resultDict objectForKey:@"FavouriteList"] mutableCopy];
                
                if (self.tableDataArray.count) {
                    [self.dontHaveLabel setHidden:YES];
                    [self.favoriteImageView setHidden:YES];
                }
                else {
                    [self.dontHaveLabel setHidden:NO];
                    [self.favoriteImageView setHidden:NO];
                }
                [favoritesTableView reloadData];
            }
            
            else if (([[responseObject objectForKey:@"StatusCode"] intValue] ==2)){
                if (self.tableDataArray.count) {
                    [self.view setBackgroundColor:[UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0]];
                    
                    [self.dontHaveLabel setHidden:YES];
                    [self.favoriteImageView setHidden:YES];
                }
                else {
                    [self.view setBackgroundColor:[UIColor whiteColor]];
                    
                    [self.dontHaveLabel setHidden:NO];
                    [self.favoriteImageView setHidden:NO];
                }
                
            }
            
            else {
                
                [CommonUtils showAlertWithTitle:@"Alert!" withMsg:[responseObject objectForKey:@"Message"] inController:self];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end

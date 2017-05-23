
//  AddressValidateViewController.m
//  Customer
//  Created by Jamshed Ali on 25/08/16.
//  Copyright © 2016 Jamshed Ali. All rights reserved.


#import "AddressValidateViewController.h"
#import "ServerRequest.h"
#import "DropDownListView.h"
#import "AppDelegate.h"
#import "VSDropdown.h"

@interface AddressValidateViewController ()<kDropDownListViewDelegate,VSDropdownDelegate> {
    
    DropDownListView * Dropobj;
    NSInteger selectedIndex;
    NSString *countryNameStr;
    NSString *cityNameStr;
    NSString *stateNameStr;
    NSString *countryIDStr;
    NSString *cityIDStr;
    NSString *stateIDStr;
    SingletonClass *sharedInstance;
    VSDropdown *_dropdown;
}

@end

@implementation AddressValidateViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    countryNameStr = @"";
    sharedInstance = [SingletonClass sharedInstance];
    countryButton.layer.cornerRadius = 5;
    countryButton.layer.borderWidth = 1;
    [_countryTextField setDelegate:self];
    [countryButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    countryButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    countryButton.backgroundColor = [UIColor whiteColor];
    self.countryListpickerViewArray = [[NSMutableArray alloc] init];
    self.countryListpickerrray = [[NSMutableArray alloc] init];
    self.stateListpickerViewArray = [[NSMutableArray alloc] init];
    self.stateListpickerrray = [[NSMutableArray alloc] init];
    self.cityListpickerViewArray = [[NSMutableArray alloc] init];
    self.cityListpickerrray = [[NSMutableArray alloc] init];
    
    _dropdown = [[VSDropdown alloc]initWithDelegate:self];
    [_dropdown setAdoptParentTheme:YES];
    [_dropdown setShouldSortItems:YES];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    
    [numberToolbar sizeToFit];
    zipCodeTextField.inputAccessoryView = numberToolbar;
    [self getCountryApiCall];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    if (APPDELEGATE.hubConnection) {
        [APPDELEGATE.hubConnection  reconnecting];
    }
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

-(void)doneWithNumberPad{
    [self.view endEditing:YES];
}

#pragma  mark - UItextField Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (textField == self.countryTextField) {
        [textField resignFirstResponder];
        [self.view endEditing:YES];
        [self showDropDownForTextField:self.countryTextField adContents:_countryListpickerrray multipleSelection:NO];
    }
    else if (textField == self.cityTextField) {
        [textField resignFirstResponder];
        [self.view endEditing:YES];
        if ([stateNameStr length]) {
            [self showDropDownForTextField:self.cityTextField adContents:_cityListpickerrray multipleSelection:NO];
        }
        else
        {
            [CommonUtils showAlertWithTitle:@"Alert!" withMsg:@"Please select state first." inController:self];
        }
    }
    else if (textField == self.stateTextField) {
        [textField resignFirstResponder];
        [self.view endEditing:YES];
        
        if ([countryNameStr length]) {
            [self showDropDownForTextField:self.stateTextField adContents:_stateListpickerrray multipleSelection:NO];
        }
        else{
            [CommonUtils showAlertWithTitle:@"Alert!" withMsg:@"Please select country first." inController:self];
        }
    }
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if (textField == self.countryTextField) {
        [self.view endEditing:YES];
    }
    else if (textField == self.cityTextField) {
        [self.view endEditing:YES];
        
    }
    else if (textField == self.stateTextField) {
        [self.view endEditing:YES];
    }
}

// It is important for you to hide the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == locationNameTextField) {
        [streetAddressTextField becomeFirstResponder];
    }
    else{
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - VSDropdown Delegate methods.

- (void)dropdown:(VSDropdown *)dropDown didChangeSelectionForValue:(NSString *)str atIndex:(NSUInteger)index selected:(BOOL)selected
{
    UITextField *btn = (UITextField *)dropDown.dropDownView;
    btn .textAlignment = NSTextAlignmentLeft;
    NSString *allSelectedItems = nil;
    if (dropDown.selectedItems.count > 1)    {
        allSelectedItems = [dropDown.selectedItems componentsJoinedByString:@","];
    }
    else{
        allSelectedItems = [dropDown.selectedItems firstObject];
    }
    btn.text = allSelectedItems ;
    if (btn==_countryTextField) {
        stateNameStr = @"";
        _stateTextField.text = @"";
        countryNameStr = allSelectedItems ;
        
        for (SingletonClass *custObj in _countryListpickerViewArray) {
            if ([custObj.countryName isEqualToString:countryNameStr]) {
                countryIDStr = custObj.countryID;
                break;
            }
        }
        if (countryIDStr.length) {
            [self getStateApiCall];
        }
    }
    else if (btn ==_stateTextField){
        cityNameStr = @"";
        _cityTextField.text = @"";
        stateNameStr = allSelectedItems ;
        for (SingletonClass *custObj in _stateListpickerViewArray) {
            if ([custObj.countryName isEqualToString:stateNameStr]) {
                stateIDStr = custObj.countryID;
                break;
            }
        }
        if (stateIDStr.length) {
            [self getCityApiCall];
        }
        
    }
    else if (btn==_cityTextField){
        
        cityNameStr = allSelectedItems ;
        }
    
    //[self getLatLonFromAddress:allSelectedItems andCount:1];
}


-(void)showDropDownForTextField:(UITextField *)txt adContents:(NSArray *)contents multipleSelection:(BOOL)multipleSelection {
    
    [_dropdown setDrodownAnimation:rand()%1];
    [_dropdown setAllowMultipleSelection:multipleSelection];
    [_dropdown setIsSearchForPlaces:YES];
    [_dropdown setupDropdownForView:txt];
    [_dropdown setBackgroundColor:[UIColor whiteColor]];
    [_dropdown setSeparatorColor:[UIColor blackColor]];
    if (_dropdown.allowMultipleSelection)
    {
        [_dropdown reloadDropdownWithContents:contents andSelectedItems:@[txt.text] ];
    }
    else
    {
        [_dropdown reloadDropdownWithContents:contents andSelectedItems:@[txt.text]];
    }
    
}

- (UIColor *)outlineColorForDropdown:(VSDropdown *)dropdown
{
    UITextField *btn = (UITextField *)dropdown.dropDownView;
    
    return btn.textColor;
    
}

- (CGFloat)outlineWidthForDropdown:(VSDropdown *)dropdown
{
    return 0.0;
}

- (CGFloat)cornerRadiusForDropdown:(VSDropdown *)dropdown
{
    return 0.0;
}

- (CGFloat)offsetForDropdown:(VSDropdown *)dropdown
{
    return -2.0;
}


- (IBAction)doneButtonClicked:(id)sender {
    
    if([locationNameTextField.text length]==0) {
        
        UIAlertView *alrtShow=[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Please enter the location name." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alrtShow show];
        
    }
    else if([countryNameStr length]==0) {
        
        UIAlertView *alrtShow=[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Please select the country name." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alrtShow show];
        
    }
    else if([self.stateTextField.text length]==0) {
        
        UIAlertView *alrtShow=[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Please enter the state." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alrtShow show];
        
    }
    
    else if([streetAddressTextField.text length]==0) {
        
        UIAlertView *alrtShow=[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Please enter the street address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alrtShow show];
        
        //    } else if([self.cityTextField.text length]==0) {
        //
        //        UIAlertView *alrtShow=[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please enter the city." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //        [alrtShow show];
        //
        //    }
    }
    else if([zipCodeTextField.text length]==0) {
        
        UIAlertView *alrtShow=[[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Please enter the zipcode." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alrtShow show];
        
    } else  {
        
        [self addCustomAddressApiCall];
    }
    
}

- (IBAction)backButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark Add Custom Address Api Call

- (void)addCustomAddressApiCall {
    
    NSString *userIdStr = sharedInstance.userId;
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:userIdStr forKey:@"UserID"];
    [params setValue:locationNameTextField.text forKey:@"LocationName"];
    [params setValue:streetAddressTextField.text forKey:@"Address"];
    [params setValue:self.cityTextField.text.length?self.cityTextField.text:@"" forKey:@"City"];
    [params setValue:self.stateTextField.text forKey:@"State"];
    [params setValue:zipCodeTextField.text forKey:@"ZipCode"];
    [params setValue:countryNameStr forKey:@"Country"];
    [params setValue:self.stateTextField.text forKey:@"StateAbbrevation"];
    
    [ProgressHUD show:@"Please wait..." Interaction:NO];
    [ServerRequest AFNetworkPostRequestUrlForAddNewApi:APIAddCustomLocationCall withParams:params CallBack:^(id responseObject, NSError *error) {
        NSLog(@"response object Post Contractor Search List %@",responseObject);
        // NSLog(@"Url List %@",urlstr);
        [ProgressHUD dismiss];
        
        if(!error) {
            
            NSLog(@"Response is --%@",responseObject);
            if ([[responseObject objectForKey:@"StatusCode"] intValue] ==1) {
                [CommonUtils showAlertWithTitle:@"Location Added" withMsg:[responseObject objectForKey:@"Message"] inController:self];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
                
            } else {
                
                [CommonUtils showAlertWithTitle:@"Alert!" withMsg:[responseObject objectForKey:@"Message"] inController:self];
            }
        }
    }];
    
}

- (void)getCountryApiCall {
    
    NSString *urlstr=[NSString stringWithFormat:@"%@?Type=%@",APIGetCountryCall,@"Country"];
    NSString *encodedUrl = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //  [ProgressHUD show:@"Please wait..." Interaction:NO];
    [ServerRequest requestWithUrlForGetCustomLocation:encodedUrl withParams:nil CallBack:^(id responseObject, NSError *error) {
        NSLog(@"response object Post Contractor Search List %@",responseObject);
        // [ProgressHUD dismiss];
        
        if(!error) {
            
            NSLog(@"Response is --%@",responseObject);
            NSLog(@"response: %@",[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);
            
            [_countryListpickerViewArray removeAllObjects];
            [_countryListpickerrray removeAllObjects];
            
            if ([[responseObject objectForKey:@"StatusCode"] intValue] ==1) {
                
                NSArray *customLocation = [[responseObject objectForKey:@"result"] objectForKey:@"MasterValues"];
                _countryListpickerViewArray
                = [SingletonClass parselocationFromCustomCountry:customLocation];
                //NSLog(@"Array Of Custom Location %@",[arrayAllLocationData objectAtIndex:1]);
                [_countryListpickerrray removeAllObjects];
                for (SingletonClass *obj in _countryListpickerViewArray) {
                    [_countryListpickerrray addObject:obj.countryName];
                }
                NSLog(@"Country Count %lu",(unsigned long)_countryListpickerrray.count);
                
            }
            else if ([[responseObject objectForKey:@"StatusCode"] intValue] == 0){
            }
            else {
                [CommonUtils showAlertWithTitle:@"Alert!" withMsg:[responseObject objectForKey:@"Message"] inController:self];
            }
        }
    }];
}

-(void)getStateApiCall{
    ///http://ondemandapiqa.flexsin.in/API/Account/GetCountryStateCity?Type=State&id=US
    
    NSString *urlstr=[NSString stringWithFormat:@"%@?Type=%@&id=%@",APIGetCountryCall,@"State",countryIDStr];
    NSString *encodedUrl = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //  [ProgressHUD show:@"Please wait..." Interaction:NO];
    [ServerRequest requestWithUrlForGetCustomLocation:encodedUrl withParams:nil CallBack:^(id responseObject, NSError *error) {
        NSLog(@"response object Post Contractor Search List %@",responseObject);
        // [ProgressHUD dismiss];
        
        if(!error) {
            
            NSLog(@"Response is --%@",responseObject);
            NSLog(@"response: %@",[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);
            
            [_stateListpickerViewArray removeAllObjects];
            [_stateListpickerrray removeAllObjects];
            
            if ([[responseObject objectForKey:@"StatusCode"] intValue] ==1) {
                
                NSArray *customLocation = [[responseObject objectForKey:@"result"] objectForKey:@"MasterValues"];
                _stateListpickerViewArray
                = [SingletonClass parselocationFromCustomCountry:customLocation];
                //NSLog(@"Array Of Custom Location %@",[arrayAllLocationData objectAtIndex:1]);
                [_stateListpickerrray removeAllObjects];
                for (SingletonClass *obj in _stateListpickerViewArray) {
                    [_stateListpickerrray addObject:obj.countryName];
                }
                NSLog(@"state Count %lu",(unsigned long)_stateListpickerrray.count);
                
            }
            else if ([[responseObject objectForKey:@"StatusCode"] intValue] == 0){
            }
            else {
                
                [CommonUtils showAlertWithTitle:@"Alert!" withMsg:[responseObject objectForKey:@"Message"] inController:self];
            }
        }
    }];
}

-(void)getCityApiCall{
    ///http://ondemandapiqa.flexsin.in/API/Account/GetCountryStateCity?Type=State&id=US
    
    NSString *urlstr=[NSString stringWithFormat:@"%@?Type=%@&id=%@",APIGetCountryCall,@"City",stateIDStr];
    NSString *encodedUrl = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //  [ProgressHUD show:@"Please wait..." Interaction:NO];
    [ServerRequest requestWithUrlForGetCustomLocation:encodedUrl withParams:nil CallBack:^(id responseObject, NSError *error) {
        NSLog(@"response object Post Contractor Search List %@",responseObject);
        // [ProgressHUD dismiss];
        
        if(!error) {
            
            NSLog(@"Response is --%@",responseObject);
            NSLog(@"response: %@",[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);
            [_cityListpickerViewArray removeAllObjects];
            [_cityListpickerrray removeAllObjects];
            
            if ([[responseObject objectForKey:@"StatusCode"] intValue] ==1) {
                
                NSArray *customLocation = [[responseObject objectForKey:@"result"] objectForKey:@"MasterValues"];
                _cityListpickerViewArray
                = [SingletonClass parselocationFromCustomCountry:customLocation];
                //NSLog(@"Array Of Custom Location %@",[arrayAllLocationData objectAtIndex:1]);
                [_cityListpickerrray removeAllObjects];
                for (SingletonClass *obj in _cityListpickerViewArray) {
                    [_cityListpickerrray addObject:obj.countryName];
                }
                NSLog(@"city Count %lu",(unsigned long)_cityListpickerrray.count);
            }
            
            else if ([[responseObject objectForKey:@"StatusCode"] intValue] == 0){
            }
            
            else {
                [CommonUtils showAlertWithTitle:@"Alert!" withMsg:[responseObject objectForKey:@"Message"] inController:self];
            }
        }
    }];
}


@end

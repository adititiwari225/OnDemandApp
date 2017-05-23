
//  PayNowViewController.m
//  Customer
//  Created by Jamshed Ali on 15/09/16.
//  Copyright © 2016 Jamshed Ali. All rights reserved.

#import "PayNowViewController.h"
#import "CommonUtils.h"
#import "ServerRequest.h"
#import "TESignatureView.h"
#import "KGModal.h"

#import "SearchViewController.h"
#import "DatesViewController.h"
#import "MessagesViewController.h"
#import "NotificationsViewController.h"
#import "AccountViewController.h"
#import "AppDelegate.h"
#import "HomeTabBarViewController.h"

#import "DropDownListView.h"

@interface PayNowViewController ()<kDropDownListViewDelegate> {
    
    NSMutableArray *monthsArray;
    NSMutableArray *yearsArray;
    NSString *checkPickerType;
    UIView *viewForPicker;
    NSString *dateCountStr;
    NSString *messageCountStr;
    NSString *notificationsCountStr;
    UIView *signaturePopUpView;
    LCTabBarController *tabBarC;
    SingletonClass *sharedInstance;
    NSString *userIdStr;
    DropDownListView * Dropobj;
    NSString *countryNameStr;
}

@end

@implementation PayNowViewController
@synthesize monthButton,signtureView,totalAmountStr;
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    sharedInstance = [SingletonClass sharedInstance];
    userIdStr = sharedInstance.userId;
    countryNameStr = @"";
    dateCountStr = @"";
    messageCountStr = @"";
    notificationsCountStr = @"";
    _signatureCreateButton.layer.borderColor = [UIColor grayColor].CGColor;
    _signatureCreateButton.layer.borderWidth = 1;
    _signatureCreateButton.layer.cornerRadius = 3;
    _signatureCreateButton.backgroundColor = [UIColor clearColor];
    
    self.countryListpickerViewArray = [[NSMutableArray alloc] init];
    self.countryListpickerViewArray = [[NSMutableArray alloc]initWithObjects:@"Afghanistan",
                                       @"Albania",
                                       @"Algeria",
                                       @"American Samoa",
                                       @"Andorra",
                                       @"Angola",
                                       @"Anguilla",
                                       @"Antarctica",
                                       @"Antigua and Barbuda",
                                       @"Argentina",
                                       @"Armenia",
                                       @"Aruba",
                                       @"Australia",
                                       @"Austria",
                                       @"Azerbaijan",
                                       @"Bahrain",
                                       @"Bangladesh",
                                       @"Barbados",
                                       @"Belarus",
                                       @"Belgium",
                                       @"Belize",
                                       @"Benin",
                                       @"Bermuda",
                                       @"Bhutan",
                                       @"Bolivia",
                                       @"Bosnia and Herzegovina",
                                       @"Botswana",
                                       @"Bouvet Island",
                                       @"Brazil",
                                       @"British Indian Ocean Territory",
                                       @"British Virgin Islands",
                                       @"Brunei",
                                       @"Bulgaria",
                                       @"Burkina Faso",
                                       @"Burundi",
                                       @"Cambodia",
                                       @"Cameroon",
                                       @"Canada",
                                       @"Cape Verde",
                                       @"Cayman Islands",
                                       @"Central African Republic",
                                       @"Chad",
                                       @"Chile",
                                       @"China",
                                       @"Christmas Island",
                                       @"Cocos (Keeling) Islands",
                                       @"Colombia",
                                       @"Comoros",
                                       @"Congo",
                                       @"Cook Islands",
                                       @"Costa Rica",
                                       @"Cote d\'Ivoire",
                                       @"Croatia",
                                       @"Cuba",
                                       @"Cyprus",
                                       @"Czech Republic",
                                       @"Democratic Republic of the Congo",
                                       @"Denmark",
                                       @"Djibouti",
                                       @"Dominica",
                                       @"Dominican Republic",
                                       @"East Timor",
                                       @"Ecuador",
                                       @"Egypt",
                                       @"El Salvador",
                                       @"Equatorial Guinea",
                                       @"Eritrea",
                                       @"Estonia",
                                       @"Ethiopia",
                                       @"Faeroe Islands",
                                       @"Falkland Islands",
                                       @"Fiji",
                                       @"Finland",
                                       @"Former Yugoslav Republic of Macedonia",
                                       @"France",
                                       @"French Guiana",
                                       @"French Polynesia",
                                       @"French Southern Territories",
                                       @"Gabon",
                                       @"Georgia",
                                       @"Germany",
                                       @"Ghana",
                                       @"Gibraltar",
                                       @"Greece",
                                       @"Greenland",
                                       @"Grenada",
                                       @"Guadeloupe",
                                       @"Guam",
                                       @"Guatemala",
                                       @"Guinea",
                                       @"Guinea-Bissau",
                                       @"Guyana",
                                       @"Haiti",
                                       @"Heard Island and McDonald Islands",
                                       @"Honduras",
                                       @"Hong Kong",
                                       @"Hungary",
                                       @"Iceland",
                                       @"India",
                                       @"Indonesia",
                                       @"Iran",
                                       @"Iraq",
                                       @"Ireland",
                                       @"Israel",
                                       @"Italy",
                                       @"Jamaica",
                                       @"Japan",
                                       @"Jordan",
                                       @"Kazakhstan",
                                       @"Kenya",
                                       @"Kiribati",
                                       @"Kuwait",
                                       @"Kyrgyzstan",
                                       @"Laos",
                                       @"Latvia",
                                       @"Lebanon",
                                       @"Lesotho",
                                       @"Liberia",
                                       @"Libya",
                                       @"Liechtenstein",
                                       @"Lithuania",
                                       @"Luxembourg",
                                       @"Macau",
                                       @"Madagascar",
                                       @"Malawi",
                                       @"Malaysia",
                                       @"Maldives",
                                       @"Mali",
                                       @"Malta",
                                       @"Marshall Islands",
                                       @"Martinique",
                                       @"Mauritania",
                                       @"Mauritius",
                                       @"Mayotte",
                                       @"Mexico",
                                       @"Micronesia",
                                       @"Moldova",
                                       @"Monaco",
                                       @"Mongolia",
                                       @"Montenegro",
                                       @"Montserrat",
                                       @"Morocco",
                                       @"Mozambique",
                                       @"Myanmar",
                                       @"Namibia",
                                       @"Nauru",
                                       @"Nepal",
                                       @"Netherlands",
                                       @"Netherlands Antilles",
                                       @"New Caledonia",
                                       @"New Zealand",
                                       @"Nicaragua",
                                       @"Niger",
                                       @"Nigeria",
                                       @"Niue",
                                       @"Norfolk Island",
                                       @"North Korea",
                                       @"Northern Marianas",
                                       @"Norway",
                                       @"Oman",
                                       @"Pakistan",
                                       @"Palau",
                                       @"Panama",
                                       @"Papua New Guinea",
                                       @"Paraguay",
                                       @"Peru",
                                       @"Philippines",
                                       @"Pitcairn Islands",
                                       @"Poland",
                                       @"Portugal",
                                       @"Puerto Rico",
                                       @"Qatar",
                                       @"Reunion",
                                       @"Romania",
                                       @"Russia",
                                       @"Rwanda",
                                       @"Sqo Tome and Principe",
                                       @"Saint Helena",
                                       @"Saint Kitts and Nevis",
                                       @"Saint Lucia",
                                       @"Saint Pierre and Miquelon",
                                       @"Saint Vincent and the Grenadines",
                                       @"Samoa",
                                       @"San Marino",
                                       @"Saudi Arabia",
                                       @"Senegal",
                                       @"Serbia",
                                       @"Seychelles",
                                       @"Sierra Leone",
                                       @"Singapore",
                                       @"Slovakia",
                                       @"Slovenia",
                                       @"Solomon Islands",
                                       @"Somalia",
                                       @"South Africa",
                                       @"South Georgia and the South Sandwich Islands",
                                       @"South Korea",
                                       @"South Sudan",
                                       @"Spain",
                                       @"Sri Lanka",
                                       @"Sudan",
                                       @"Suriname",
                                       @"Svalbard and Jan Mayen",
                                       @"Swaziland",
                                       @"Sweden",
                                       @"Switzerland",
                                       @"Syria",
                                       @"Taiwan",
                                       @"Tajikistan",
                                       @"Tanzania",
                                       @"Thailand",
                                       @"The Bahamas",
                                       @"The Gambia",
                                       @"Togo",
                                       @"Tokelau",
                                       @"Tonga",
                                       @"Trinidad and Tobago",
                                       @"Tunisia",
                                       @"Turkey",
                                       @"Turkmenistan",
                                       @"Turks and Caicos Islands",
                                       @"Tuvalu",
                                       @"Virgin Islands",
                                       @"Uganda",
                                       @"Ukraine",
                                       @"United Arab Emirates",
                                       @"United Kingdom",
                                       @"United States",
                                       @"United States Minor Outlying Islands",
                                       @"Uruguay",
                                       @"Uzbekistan",
                                       @"Vanuatu",
                                       @"Vatican City",
                                       @"Venezuela",
                                       @"Vietnam",
                                       @"Wallis and Futuna",
                                       @"Western Sahara",
                                       @"Yemen",
                                       @"Yugoslavia",
                                       @"Zambia",
                                       @"Zimbabwe", nil];
    
    monthsArray=[[NSMutableArray alloc]initWithObjects:@"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December",nil];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    
    yearsArray=[[NSMutableArray alloc]init];
    
    for (int i=0; i<13; i++)
    {
        [yearsArray addObject:[NSString stringWithFormat:@"%d",[yearString intValue]+i]];
    }
    
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSDate *currentDate = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:30];
//    NSDate *maxDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    [comps setYear:30];
//    NSDate *minDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];

  //  [self setBorderlayerOnTextField];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBar.hidden=YES;
    [self.tabBarController.tabBar setHidden:YES];
    
    if (APPDELEGATE.hubConnection) {
        [APPDELEGATE.hubConnection  reconnecting];
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}


- (void)doneClicked:(id)sender {
    
    NSLog(@"Done Clicked.");
    [self.view endEditing:YES];
}

- (void)dateTextField:(id)sender {
    
    [self.view endEditing:YES];
    
    if ([monthTxt isFirstResponder]) {
        
        UIDatePicker *picker = (UIDatePicker*)monthTxt.inputView;
        [picker setMaximumDate:[NSDate date]];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        NSDate *eventDate = picker.date;
        [dateFormat setDateFormat:@"MMMM"];
        NSString *dateString = [dateFormat stringFromDate:eventDate];
        
        NSDate *aDate = [dateFormat dateFromString:dateString];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:aDate];
        
        monthTxt.text = [NSString stringWithFormat:@"%@ %li",dateString,(long)[components month]];
        
        if([monthStr isEqualToString:@"January"]) {
            monthStr = @"01";
        } else if([monthStr isEqualToString:@"February"]) {
            monthStr = @"02";
        } else if([monthStr isEqualToString:@"March"]) {
            monthStr = @"03";
        } else if([monthStr isEqualToString:@"April"]) {
            monthStr = @"04";
        } else if([monthStr isEqualToString:@"May"]) {
            monthStr = @"05";
        } else if([monthStr isEqualToString:@"June"]) {
            monthStr = @"06";
        } else if([monthStr isEqualToString:@"July"]) {
            monthStr = @"07";
        } else if([monthStr isEqualToString:@"August"]) {
            monthStr = @"08";
        } else if([monthStr isEqualToString:@"September"]) {
            monthStr = @"09";
        } else if([monthStr isEqualToString:@"October"]) {
            monthStr = @"10";
        } else if([monthStr isEqualToString:@"November"]) {
            monthStr = @"11";
        } else if([monthStr isEqualToString:@"December"]) {
            monthStr = @"12";
        }
        
    }
    else if ([yearTxt isFirstResponder]) {
        
        UIDatePicker *picker = (UIDatePicker*)yearTxt.inputView;
        [picker setMaximumDate:[NSDate date]];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        NSDate *eventDate = picker.date;
        [dateFormat setDateFormat:@"YYYY"];
        NSString *dateString = [dateFormat stringFromDate:eventDate];
        yearTxt.text = [NSString stringWithFormat:@"%@",dateString];
        
    }
    
}

- (void)setBorderlayerOnTextField {
    
    cardNumberTxt.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cardNumberTxt.layer.borderWidth = 0.5;
    monthTxt.layer.borderColor = [UIColor lightGrayColor].CGColor;
    monthTxt.layer.borderWidth = 0.5;
    yearTxt.layer.borderColor = [UIColor lightGrayColor].CGColor;
    yearTxt.layer.borderWidth = 0.5;
    securityCodeNumberTxt.layer.borderColor = [UIColor lightGrayColor].CGColor;
    securityCodeNumberTxt.layer.borderWidth = 0.5;
    nameOfCardTxt.layer.borderColor = [UIColor lightGrayColor].CGColor;
    nameOfCardTxt.layer.borderWidth = 0.5;
    addressTxt.layer.borderColor = [UIColor lightGrayColor].CGColor;
    addressTxt.layer.borderWidth = 0.5;
    cityTxt.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cityTxt.layer.borderWidth = 0.5;
    stateOrProvinceTxt.layer.borderColor = [UIColor lightGrayColor].CGColor;
    stateOrProvinceTxt.layer.borderWidth = 0.5;
    zipOrPostalCodeTxt.layer.borderColor = [UIColor lightGrayColor].CGColor;
    zipOrPostalCodeTxt.layer.borderWidth = 0.5;
    countryTxt.layer.borderColor = [UIColor lightGrayColor].CGColor;
    countryTxt.layer.borderWidth = 0.5;
    //   signatureTxtView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //   signatureTxtView.layer.borderWidth = 0.5;
}

- (void)viewDidLayoutSubviews {
    
    bgScrollView.contentSize = CGSizeMake(320, 950);
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
    }
    
}

- (IBAction)pickerviewButtonClicked:(id)sender {
    
    /*
     CGFloat viewHeight = [[self view] frame].size.height;
     CGFloat pickerHeight;
     
     self.pickerView = [[UIPickerView alloc] init];
     pickerHeight = [self.pickerView frame].size.height;
     [self.pickerView setFrame:CGRectMake(0, viewHeight - pickerHeight, self.view.bounds.size.width, pickerHeight)];
     self.pickerView.backgroundColor = [UIColor grayColor];
     self.pickerView.delegate = self;
     self.pickerView.dataSource = self;
     [[self view] addSubview:self.pickerView];
     
     UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.pickerView.frame.size.width,44)];
     [toolBar setBarStyle:UIBarStyleBlackOpaque];
     UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
     style:UIBarButtonItemStyleBordered target:self action:@selector(pickerViewDoneButtonClicked:)];
     toolBar.items = @[barButtonDone];
     barButtonDone.tintColor=[UIColor whiteColor];
     [self.pickerView addSubview:toolBar];
     
     */
    
}

- (void)pickerViewDoneButtonClicked:(id)sender {
    NSLog(@"Done Clicked.");
    self.pickerView.hidden = YES;
}


#pragma mark Country List Button Method Call
- (IBAction)countryListButtonClicked:(id)sender {
    
//    [Dropobj fadeOut];
//    [self showPopUpWithTitle:@"Select Country" withOption:self.countryListpickerViewArray xy:CGPointMake(20, 70) size:CGSizeMake(self.view.frame.size.width-40, self.view.frame.size.height-80) isMultiple:NO];
    [self.view endEditing:YES];
    
    viewForPicker.hidden = YES;
    
    [self.view endEditing:YES];
    checkPickerType = @"3";
    
    
    CGFloat viewHeight = [[self view] frame].size.height;
    CGFloat pickerHeight;
    viewForPicker = [[UIView alloc]initWithFrame:CGRectMake(0, viewHeight - pickerHeight-200, self.view.bounds.size.width, pickerHeight+200)];
    viewForPicker.backgroundColor = [UIColor whiteColor];
    
    self.pickerView = [[UIPickerView alloc] init];
    pickerHeight = [self.pickerView frame].size.height;
    //[self.pickerView setFrame:CGRectMake(0, viewHeight - pickerHeight, self.view.bounds.size.width, pickerHeight)];
    
    [self.pickerView setFrame:CGRectMake(0, 20, self.view.bounds.size.width, viewForPicker.frame.size.height-20)];
    self.pickerView.backgroundColor = [UIColor whiteColor];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [[self view] addSubview:viewForPicker];
    [viewForPicker addSubview:self.pickerView];
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.pickerView.frame.size.width,44)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleBordered target:self action:@selector(pickerViewDoneButtonClickedCall:)];
    toolBar.items = @[barButtonDone];
    barButtonDone.tintColor=[UIColor whiteColor];
    [viewForPicker addSubview:toolBar];

    
}

-(void)pickerViewDoneButtonClickedCall:(id)sender
{
    NSLog(@"Done Clicked.");
    if ([checkPickerType isEqualToString:@"3"]) {
        [countryButton setTitle:@"" forState:UIControlStateNormal];
    }
    viewForPicker.hidden = YES;
}


# pragma  mark Reward Amount Popup Show

-(void)showPopUpWithTitle:(NSString*)popupTitle withOption:(NSArray*)arrOptions xy:(CGPoint)point size:(CGSize)size isMultiple:(BOOL)isMultiple{
    
    Dropobj = [[DropDownListView alloc] initWithTitle:popupTitle options:arrOptions xy:point size:size isMultiple:isMultiple];
    Dropobj.delegate = self;
    [Dropobj showInView:self.view animated:YES];
    
    //----------------Set DropDown backGroundColor-----------------
    [Dropobj SetBackGroundDropDown_R:0.0 G:108.0 B:194.0 alpha:0.70];
    
}


- (void)DropDownListView:(DropDownListView *)dropdownListView didSelectedIndex:(NSInteger)anIndex {
    
    //----------------Get Selected Value[Single selection]-----------------
    
    [countryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [countryButton setTitle:[NSString stringWithFormat:@"%@",[self.countryListpickerViewArray objectAtIndex:anIndex]] forState:UIControlStateNormal];
    
    countryNameStr =  [NSString stringWithFormat:@"%@",[self.countryListpickerViewArray objectAtIndex:anIndex]];
    
    // [countryButton setTitle:@"James" forState:UIControlStateNormal];
    
    //    [countryButton setTitle:[NSString stringWithFormat:@"$%.2f",[[[self.countryListpickerViewArray objectAtIndex:anIndex]objectForKey:@"Amount"] floatValue]] forState:UIControlStateNormal];
    // rewardIDStr = [NSString stringWithFormat:@"%@",[[self.countryListpickerViewArray objectAtIndex:anIndex]objectForKey:@"ID"]];
    
}


- (void)DropDownListView:(DropDownListView *)dropdownListView Datalist:(NSMutableArray*)ArryData{
    
    //----------------Get Selected Value[Multiple selection]-----------------
    if (ArryData.count>0) {
        
    }
    else{
        
    }
}


- (IBAction)clearButtonClicked:(id)sender {
    
    cardNumberTxt.text = @"";
    monthTxt.text = @"";
    yearTxt.text = @"";
    securityCodeNumberTxt.text = @"";;
    nameOfCardTxt.text = @"";
    addressTxt.text = @"";
    cityTxt.text = @"";
    stateOrProvinceTxt.text = @"";
    zipOrPostalCodeTxt.text = @"";
    countryTxt.text = @"";
    //  signatureTxtView.text = @"";
    monthStr= @"";
}

- (IBAction)backButtonMethodClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)AddCreditCardClicked:(id)sender {
    
    if ([cardNumberTxt.text isEqualToString:@""]) {
        
        [CommonUtils showAlertWithTitle:@"Alert!" withMsg:@"Please enter the card number." inController:self];
        
    }
    else if ([monthStr isEqualToString:@""]) {
        
        [CommonUtils showAlertWithTitle:@"Alert!" withMsg:@"Please select the expiry month." inController:self];
        
    }else if ([yearTxt.text isEqualToString:@""]) {
        
        [CommonUtils showAlertWithTitle:@"Alert!" withMsg:@"Please select the expiry year." inController:self];
        
    }
    else if ([securityCodeNumberTxt.text isEqualToString:@""]) {
        
        [CommonUtils showAlertWithTitle:@"Alert!" withMsg:@"Please enter the cvv number." inController:self];
        
    }
    else if ([nameOfCardTxt.text isEqualToString:@""]) {
        
        [CommonUtils showAlertWithTitle:@"Alert!" withMsg:@"Please enter the name of card." inController:self];
        
    }
    else if ([addressTxt.text isEqualToString:@""]) {
        
        [CommonUtils showAlertWithTitle:@"Alert!" withMsg:@"Please enter the address." inController:self];
        
    }
    else if ([cityTxt.text isEqualToString:@""]) {
        
        [CommonUtils showAlertWithTitle:@"Alert!" withMsg:@"Please enter the city." inController:self];
        
    }
    else if ([stateOrProvinceTxt.text isEqualToString:@""]) {
        
        [CommonUtils showAlertWithTitle:@"Alert!" withMsg:@"Please enter the state." inController:self];
        
    }
    else if ([zipOrPostalCodeTxt.text isEqualToString:@""]) {
        
        [CommonUtils showAlertWithTitle:@"Alert!" withMsg:@"Please enter the zipcode." inController:self];
        
    }
    else if ([countryNameStr isEqualToString:@""]) {
        
        [CommonUtils showAlertWithTitle:@"Alert!" withMsg:@"Please select the country name." inController:self];
        
    } else if (!_signatureImageView.image) {
        
        [CommonUtils showAlertWithTitle:@"Alert!" withMsg:@"Please add the signature." inController:self];
        
    } else {
        
        [self sendPayNowApiCall];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

// It is important for you to hide the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark PickerView DataSource Delegate Method

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    NSInteger rowsInComponent;
    if ([checkPickerType isEqualToString:@"1"]) {
        
        rowsInComponent=[monthsArray count];
        
    } else if ([checkPickerType isEqualToString:@"2"]) {
        rowsInComponent=[yearsArray count];
    }
    else if ([checkPickerType isEqualToString:@"3"]) {
        rowsInComponent=[self.countryListpickerViewArray count];
    }
    return rowsInComponent;
    
}



- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    NSString * nameInRow;
    if ([checkPickerType isEqualToString:@"1"])
    {
        nameInRow=[monthsArray objectAtIndex:row];
    }
    else if ([checkPickerType isEqualToString:@"2"])
    {
        nameInRow=[yearsArray objectAtIndex:row];
    }
    else if ([checkPickerType isEqualToString:@"3"]) {
        nameInRow=[self.countryListpickerViewArray objectAtIndex:row];
    }
    return nameInRow;
    
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat componentWidth ;
    
    if (component==0)
    {
        componentWidth = 150;
    }
    else  {
        componentWidth = 150;
    }
    
    return componentWidth;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSString * nameInRow;
    if ([checkPickerType isEqualToString:@"1"]) {
        
        nameInRow=[monthsArray objectAtIndex:row];
        monthTxt.text = nameInRow;
        
    } else if ([checkPickerType isEqualToString:@"2"]) {
        
        nameInRow=[yearsArray objectAtIndex:row];
        yearTxt.text = nameInRow;
    }
    else if ([checkPickerType isEqualToString:@"3"]) {
        
        nameInRow=[self.countryListpickerViewArray objectAtIndex:row];
        countryTxt.text = nameInRow;
        countryNameStr =  nameInRow;
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)monthButtonClicked:(id)sender {
    
    [self.view endEditing:YES];
    checkPickerType = @"1";
    
    CGFloat viewHeight = [[self view] frame].size.height;
    CGFloat pickerHeight;
    viewForPicker = [[UIView alloc]initWithFrame:CGRectMake(0, viewHeight - pickerHeight-200, self.view.bounds.size.width, pickerHeight+200)];
    viewForPicker.backgroundColor = [UIColor whiteColor];
    self.pickerView = [[UIPickerView alloc] init];
    pickerHeight = [self.pickerView frame].size.height;
    //[self.pickerView setFrame:CGRectMake(0, viewHeight - pickerHeight, self.view.bounds.size.width, pickerHeight)];
    
    [self.pickerView setFrame:CGRectMake(0, 44, self.view.bounds.size.width, viewForPicker.frame.size.height-43)];
    self.pickerView.backgroundColor = [UIColor grayColor];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [[self view] addSubview:viewForPicker];
    [viewForPicker addSubview:self.pickerView];
    
    
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.pickerView.frame.size.width,44)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleBordered target:self action:@selector(pickerViewDoneButtonClickedCall:)];
    toolBar.items = @[barButtonDone];
    barButtonDone.tintColor=[UIColor whiteColor];
    [viewForPicker addSubview:toolBar];
    
}

- (IBAction)clearSIgnButtonClicked:(id)sender {
    
    [_signatureCreateButton setTitle:@"Your Signature Here" forState:UIControlStateNormal];
    
    _signatureImageView.image = nil;
}

- (IBAction)saveSignButtonClicked:(id)sender {
    
    UIImageWriteToSavedPhotosAlbum([signtureView getSignatureImage], nil, nil, nil);
}

- (IBAction)signatureCreateButtonClicked:(id)sender {
    
    [self signturePopupButtonPushed];
}

- (IBAction)yearButtonClicked:(id)sender {
    
    checkPickerType = @"2";
    
    CGFloat viewHeight = [[self view] frame].size.height;
    CGFloat pickerHeight;
    viewForPicker = [[UIView alloc]initWithFrame:CGRectMake(0, viewHeight - pickerHeight-200, self.view.bounds.size.width, pickerHeight+200)];
    viewForPicker.backgroundColor = [UIColor whiteColor];
    
    self.pickerView = [[UIPickerView alloc] init];
    pickerHeight = [self.pickerView frame].size.height;
    
    [self.pickerView setFrame:CGRectMake(0, 44, self.view.bounds.size.width, viewForPicker.frame.size.height-43)];
    self.pickerView.backgroundColor = [UIColor grayColor];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [[self view] addSubview:viewForPicker];
    [viewForPicker addSubview:self.pickerView];
    
    
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.pickerView.frame.size.width,44)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleBordered target:self action:@selector(pickerViewDoneButtonClickedCall:)];
    toolBar.items = @[barButtonDone];
    barButtonDone.tintColor=[UIColor whiteColor];
    [viewForPicker addSubview:toolBar];
    
}

//-(void)pickerViewDoneButtonClickedCall:(id)sender
//{
//    NSLog(@"Done Clicked.");
//    viewForPicker.hidden = YES;
//}

#pragma mark Product Weight Price Popup

-(void)signturePopupButtonPushed {
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width-40, 360)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 4.0;
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(1, 5, contentView.frame.size.width-2, 354)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:whiteView];
    signtureView = [[TESignatureView alloc]init];
    signtureView.frame = CGRectMake(1, 5, contentView.frame.size.width-2, 346);
    signtureView.backgroundColor = [UIColor whiteColor];
    [whiteView addSubview:signtureView];
    UIButton *clearSignButton = [CommonUtils createButtonWithRect:CGRectMake(20, 310, 60, 40) andText:@"CLEAR" andTextColor:[UIColor whiteColor] andFontSize:@"" andImgName:@""];
    [clearSignButton addTarget:self action:@selector(clearSigntureButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [clearSignButton setBackgroundColor:[UIColor colorWithRed:101/255.0 green:53/255.0 blue:123/255.0 alpha:1.0]];
    clearSignButton.layer.cornerRadius = 3.0;
    [contentView addSubview:clearSignButton];
    UIButton *signDoneButton = [CommonUtils createButtonWithRect:CGRectMake(whiteView.frame.size.width-80, 310, 60, 40) andText:@"DONE" andTextColor:[UIColor whiteColor] andFontSize:@"" andImgName:@""];
    [signDoneButton addTarget:self action:@selector(signtureDoneButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [signDoneButton setBackgroundColor:[UIColor colorWithRed:101/255.0 green:53/255.0 blue:123/255.0 alpha:1.0]];
    signDoneButton.layer.cornerRadius = 3.0;
    [contentView addSubview:signDoneButton];
    [[KGModal sharedInstance] showWithContentView:contentView andAnimated:YES];
    
}

- (void)clearSigntureButtonClicked {
    [signtureView clearSignature];
}

- (void)signtureDoneButtonClicked {
    
    _signatureImageView.image = nil;
    _signatureImageView.image = [signtureView getSignatureImage];
    
    if (_signatureImageView.image) {
        [_signatureCreateButton setTitle:@"" forState:UIControlStateNormal];
    }
    
    [signaturePopUpView removeFromSuperview];
    [[KGModal sharedInstance] hideAnimated:YES];
}


#pragma mark-- Api Call - Send Pay Now

- (void)sendPayNowApiCall {

    if (_signatureImageView.image) {
        
        [ProgressHUD show:@"Please wait..." Interaction:NO];
        
        if([monthTxt.text isEqualToString:@"January"]) {
            monthStr = @"01";
        }
        else if([monthTxt.text isEqualToString:@"February"]) {
            monthStr = @"02";
        }
        else if([monthTxt.text isEqualToString:@"March"]) {
            monthStr = @"03";
        }
        else if([monthTxt.text isEqualToString:@"April"]) {
            monthStr = @"04";
        }
        else if([monthTxt.text isEqualToString:@"May"]) {
            monthStr = @"05";
        }
        else if([monthTxt.text isEqualToString:@"June"]) {
            monthStr = @"06";
        }
        else if([monthTxt.text isEqualToString:@"July"]) {
            monthStr = @"07";
        }
        else if([monthTxt.text isEqualToString:@"August"]) {
            monthStr = @"08";
        }
        else if([monthTxt.text isEqualToString:@"September"]) {
            monthStr = @"09";
        }
        else if([monthTxt.text isEqualToString:@"October"]) {
            monthStr = @"10";
        }
        else if([monthTxt.text isEqualToString:@"November"]) {
            monthStr = @"11";
        }
        else if([monthTxt.text isEqualToString:@"December"]) {
            monthStr = @"12";
        }
        
        NSData *imageData = UIImagePNGRepresentation(_signatureImageView.image);
        NSString *imageString = [imageData base64EncodedStringWithOptions:0];
        NSLog(@"%@", imageString);
        NSString *ipAddressStr  = sharedInstance.ipAddressStr;
        float totalAmountValue = [totalAmountStr floatValue];
        int roundedDownVal = floor(totalAmountValue);
        NSString *amountStr = [NSString stringWithFormat:@"%d",roundedDownVal];
        NSLog(@"Pay Amount Value ==== %@",amountStr);
        NSMutableDictionary *params=[[NSMutableDictionary alloc] initWithObjectsAndKeys:userIdStr,@"UserID",cardNumberTxt.text,@"CreditCardNumber",monthStr,@"ExpiryMonth",yearTxt.text,@"ExpiryYear",securityCodeNumberTxt.text,@"SecurityCode",nameOfCardTxt.text,@"NameOnCreditCard",countryNameStr,@"CountryID",stateOrProvinceTxt.text,@"State",cityTxt.text,@"City",addressTxt.text,@"Address",zipOrPostalCodeTxt.text,@"Zipcode",ipAddressStr,@"IpAddress",imageString,@"Signature",amountStr,@"DueAmount",nil];
        NSLog(@"Pay Amount Paramtere ====== %@",params);
        [ProgressHUD show:@"Please wait..." Interaction:NO];
        [ServerRequest AFNetworkPostRequestUrl:APIPastDuePaymentCall withParams:params CallBack:^(id responseObject, NSError *error) {
            NSLog(@"response object Post Contractor Search List %@",responseObject);
            [ProgressHUD dismiss];
            if(!error) {
                NSLog(@"Response is --%@",responseObject);
                if ([[responseObject objectForKey:@"StatusCode"] intValue] ==1)
                {
                    [CommonUtils showAlertWithTitle:@"Alert!" withMsg:[responseObject objectForKey:@"Message"] inController:self];
                    [self tabBarCountApiCall];
                }
                else
                {
                    [CommonUtils showAlertWithTitle:@"Alert!" withMsg:[responseObject objectForKey:@"Message"] inController:self];
                }
            }
        }];
    }
}


- (void)tabBarCountApiCall {

    NSMutableDictionary *params=[[NSMutableDictionary alloc] initWithObjectsAndKeys:userIdStr,@"UserID",@"1" ,@"userType",nil];
    [ProgressHUD show:@"Please wait..." Interaction:NO];
    [ServerRequest requestWithUrl:APITabBarMessageCountApiCall withParams:params CallBack:^(id responseObject, NSError *error) {
        NSLog(@"response object Get Comments List %@",responseObject);
        [ProgressHUD dismiss];
        if(!error){
            NSLog(@"Response is --%@",responseObject);
            if ([[responseObject objectForKey:@"StatusCode"] intValue] ==1) {
                if ([[[responseObject objectForKey:@"result"] objectForKey:@"Dates"] isEqualToString:@"0"]) {
                    dateCountStr  = nil;
                }
                else {
                    dateCountStr = [[responseObject objectForKey:@"result"] objectForKey:@"Dates"];
                }
                
                if ([[[responseObject objectForKey:@"result"] objectForKey:@"Mesages"] isEqualToString:@"0"]) {
                    messageCountStr = nil;
                }
                else {
                    messageCountStr = [[responseObject objectForKey:@"result"] objectForKey:@"Mesages"];
                }
                
                if ([[[responseObject objectForKey:@"result"] objectForKey:@"Notifications"] isEqualToString:@"0"]) {
                    notificationsCountStr   = nil;
                }
                else {
                    notificationsCountStr = [[responseObject objectForKey:@"result"] objectForKey:@"Notifications"];
                }
            }
            else{
            }
        }
        else
        {
        }
        [self tabBarControllerClass];
        
    }];
}

- (void)tabBarControllerClass {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchViewController *searchScreenView = [storyboard instantiateViewControllerWithIdentifier:@"search"];
    searchScreenView.view.backgroundColor = [UIColor whiteColor];
    searchScreenView.title = @"Search";
    searchScreenView.tabBarItem.image = [UIImage imageNamed:@"search"];
    searchScreenView.tabBarItem.selectedImage = [UIImage imageNamed:@"search_hover"];
    
    DatesViewController *datesView = [storyboard instantiateViewControllerWithIdentifier:@"dates"];
    datesView.view.backgroundColor = [UIColor whiteColor];
    datesView.tabBarItem.badgeValue = dateCountStr;
    datesView.title = @"Dates";
    datesView.isFromDateDetails = NO;
    datesView.tabBarItem.image = [UIImage imageNamed:@"dates"];
    datesView.tabBarItem.selectedImage = [UIImage imageNamed:@"dates_hover"];
    
    MessagesViewController *messageView = [storyboard instantiateViewControllerWithIdentifier:@"messages"];
    messageView.view.backgroundColor = [UIColor whiteColor];
    messageView.tabBarItem.badgeValue =messageCountStr;
    messageView.title = @"Messages";
    messageView.tabBarItem.image = [UIImage imageNamed:@"message"];
    messageView.tabBarItem.selectedImage = [UIImage imageNamed:@"message_hover"];
    
    NotificationsViewController *notiView = [storyboard instantiateViewControllerWithIdentifier:@"notifications"];
    notiView.view.backgroundColor = [UIColor whiteColor];
    notiView.tabBarItem.badgeValue = notificationsCountStr;
    notiView.title = @"Notifications";
    notiView.tabBarItem.image = [UIImage imageNamed:@"notification"];
    notiView.tabBarItem.selectedImage = [UIImage imageNamed:@"notification_hover"];
    
    AccountViewController *accountView = [storyboard instantiateViewControllerWithIdentifier:@"account"];
    accountView.view.backgroundColor = [UIColor whiteColor];
    accountView.title = @"Account";
    accountView.tabBarItem.image = [UIImage imageNamed:@"user"];
    accountView.tabBarItem.selectedImage = [UIImage imageNamed:@"user_hover"];
    
    UINavigationController *navC1 = [[UINavigationController alloc] initWithRootViewController:searchScreenView];
    UINavigationController *navC2 = [[UINavigationController alloc] initWithRootViewController:datesView];
    UINavigationController *navC3 = [[UINavigationController alloc] initWithRootViewController:messageView];
    UINavigationController *navC4 = [[UINavigationController alloc] initWithRootViewController:notiView];
    UINavigationController *navC5 = [[UINavigationController alloc] initWithRootViewController:accountView];
    
    /**************************************** Key Code ****************************************/
    APPDELEGATE.tabBarC    = [[LCTabBarController alloc] init];
    APPDELEGATE.tabBarC.selectedItemTitleColor = [UIColor purpleColor];
    APPDELEGATE.tabBarC.viewControllers        = @[navC1, navC2, navC3, navC4, navC5];
    [self.navigationController pushViewController:APPDELEGATE.tabBarC animated:NO];
}

@end

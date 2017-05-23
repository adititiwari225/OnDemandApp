

//  AddressAutoCompleteViewController.m
//  Customer
//  Created by Jamshed Ali on 23/11/16.
//  Copyright © 2016 Jamshed Ali. All rights reserved.


#import "AddressAutoCompleteViewController.h"
#import "CommonUtils.h"
#import "ServerRequest.h"
#import "AlertView.h"
#import "NotificationTableViewCell.h"
#import "PlaceObj.h"
#define GOOGLE_GEOLOCATION_URL @"https://maps.googleapis.com/maps/api/place/autocomplete/"
#define PARAM_PRIDICTION    @"predictions"
#define GOOGLE_API_KEY   @"AIzaSyAW4AldQrkEsG5PJX8nDZL6_-ecYX9Z4-0"
#define GOOGLE_API_BASE_URLs @"https://maps.googleapis.com/maps/api/place/autocomplete/"
#define GOOGLE_API_BASE_URL_DETAIL @"https://maps.googleapis.com/maps/api/place/details/"

#import "AppDelegate.h"
@interface AddressAutoCompleteViewController () <CLLocationManagerDelegate>{
    
    NSString *streetStr;
    NSString *cityStr;
    NSString *stateStr;
    SingletonClass *sharedInstance;
    NSMutableArray * locationArray;
    NSMutableData *receivedData;
    NSArray *tableDataSource;
    NSURLConnection *connection;
    NSTimer *connectionTimer;
    NSInteger selectedIndex;
    BOOL isAlphbet;
}

@property (nonatomic,strong) NSURLConnection *connection;
@property (strong, nonatomic) IBOutlet UILabel *noResultLabel;
@property(nonatomic,strong)NSMutableArray *placeDetailsArray;
@property (strong, nonatomic) IBOutlet UITableView *tableViewSearchBar;
@end

@implementation AddressAutoCompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    locationArray = [[NSMutableArray alloc]init];
    selectedIndex = -1;
    searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] initWithApiKey:@"AIzaSyAW4AldQrkEsG5PJX8nDZL6_-ecYX9Z4-0"];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [_noResultLabel setHidden:YES];
    sharedInstance.selectedAddressStr = @"";
    sharedInstance.strChooseLocationName = @"";
    sharedInstance = [SingletonClass sharedInstance];
    [addressTextField addTarget:self
                         action:@selector(editingChanged:)
               forControlEvents:UIControlEventEditingChanged];
    sharedInstance.selectedAddressAutoComplete = @"Yes";
    sharedInstance.checkisSearchAllOverTheAreaValue = NO ;
    if (APPDELEGATE.hubConnection) {
        [APPDELEGATE.hubConnection  reconnecting];
    }
    [addressTextField becomeFirstResponder];
}

- (IBAction)cancelBtnClicked:(id)sender {
    [self.view endEditing:YES];
    if (self.isFromRequestNow) {
        if (!addressTextField.text) {
            sharedInstance.selectedAddressStr = @"";
        }
        [self presentNextViewCon];
    }
    else{
        if ([sharedInstance.selectedAddressStr length]) {
            [self.navigationController popViewControllerAnimated:YES];
            [self.delegate locationString:sharedInstance.selectedAddressStr];
        }
        else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma  mark - UItextField Delegate Methods
-(void)presentNextViewCon
{
    [self.view endEditing:YES];
    NSLog(@"Hello");
    [self dismissViewControllerAnimated:YES completion:^{
        self.isFromRequestNow = NO;
        [self.delegate locationString:sharedInstance.selectedAddressStr];
        //  [self.navigationController popViewControllerAnimated:YES];
        // here you can create a code for presetn C viewcontroller
    }];
    
}


-(void) editingChanged:(UITextField *)sender {
    [_noResultLabel setHidden:YES];
    if ([sender.text isEqualToString:@""]) {
        [locationArray removeAllObjects];
        [self.tableViewSearchBar reloadData];
        
    }
    else{
        if ([sender.text length]) {
            [self callApiToSearchGooglePlacesWithString:[NSString stringWithFormat:@"%@",sender.text]];
        }
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}


-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self.view endEditing:YES];
    if (textField.text.length >1) {
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ((textField = addressTextField)) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark Google Place Api Call

- (void)handleSearchForSearchString:(NSString *)searchString {
    
    //  searchQuery.location = currentLocation.coordinate;
    searchQuery.input = searchString;
    sharedInstance.checkisSearchAllOverTheArea = YES;
    [searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        NSLog(@"Error%@",error.localizedDescription);
        if (error) {
            [_noResultLabel setHidden:NO];
        }
        else
        {
            _autoCompleter.suggestionsDictionary =  places;
            if (places.count) {
                [_noResultLabel setHidden:YES];
                [self.autoCompleter textFieldValueChanged:addressTextField];
            }
            else
            {
                [_noResultLabel setHidden:NO];
            }
        }
    }];
}


- (AutocompletionTableView *)autoCompleter
{
    if (!_autoCompleter)
    {
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:2];
        [options setValue:[NSNumber numberWithBool:YES] forKey:ACOCaseSensitive];
        [options setValue:nil forKey:ACOUseSourceFont];
        _autoCompleter = [[AutocompletionTableView alloc] initWithTextField:addressTextField inViewController:self withOptions:options];
        _autoCompleter.backgroundColor =[UIColor whiteColor];
        _autoCompleter.autoCompleteDelegate = self;
    }
    return _autoCompleter;
}

- (NSArray*) autoCompletion:(AutocompletionTableView*) completer suggestionsFor:(NSString*) string{
    
    // with the prodided string, build a new array with suggestions - from DB, from a service, etc.
    NSLog(@"suggestions---%@",_autoCompleter.suggestionsDictionary);
    return _autoCompleter.suggestionsDictionary;
    
}

- (void) autoCompletion:(AutocompletionTableView*) completer didSelectAutoCompleteSuggestionWithIndex:(NSInteger) index withString:(NSString *)str{
    
    addressTextField.text = str;
    [addressTextField resignFirstResponder];
    [self checkThatTextIsNeumeric:addressTextField.text];
    if (!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    
    [self.geocoder geocodeAddressString:str completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0) {
            
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
            
            NSString  *streetString = [CommonUtils checkStringForNULL:placemark.thoroughfare];
            NSLog(@"street %@",streetString);
            
            cityStr = [CommonUtils checkStringForNULL:placemark.locality];
            stateStr = [CommonUtils checkStringForNULL:placemark.administrativeArea];
            NSString  *countryStr = [CommonUtils checkStringForNULL:placemark.country];
            if (!countryStr.length) {
                countryStr = @"";
            }
            if (!cityStr.length) {
                cityStr = @"";
            }
            if (!stateStr.length) {
                stateStr = @"";
            }
            
            NSString  * zipCodeStr = [CommonUtils checkStringForNULL:placemark.postalCode];
            CLLocation *location = placemark.location;
            float latitude=  location.coordinate.latitude;
            float longitude= location.coordinate.longitude;
            if (!zipCodeStr.length) {
                zipCodeStr = @"";
            }
            sharedInstance.customLatiValueStr = [NSString stringWithFormat:@"%.8f", location.coordinate.latitude];
            sharedInstance.customLongiValueStr = [NSString stringWithFormat:@"%.8f", location.coordinate.longitude];
            sharedInstance.selectedAddressLatitudeStr = [NSString stringWithFormat:@"%f",latitude];
            sharedInstance.selectedAddressLongitudeStr = [NSString stringWithFormat:@"%f",longitude];
            
            if (!cityStr.length)
            {
                sharedInstance.selectedAddressStr = locatedAt;
            }
            else{
                if (isAlphbet)
                {
                    sharedInstance.selectedAddressStr  = [NSString stringWithFormat:@"%@, %@,%@",zipCodeStr,cityStr,countryStr];
                }
                else
                {
                    sharedInstance.selectedAddressStr = [NSString stringWithFormat:@"%@, %@,%@",cityStr,stateStr,countryStr];
                }
            }
            NSLog(@"CustomLocation Value%@",sharedInstance.selectedAddressStr);
            if (self.isFromRequestNow) {
                [self presentNextViewCon];
            }
            else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
}

-(void) checkThatTextIsNeumeric:(NSString *)neumericString{
    NSString *string=neumericString;
    NSString *firstChar=[string substringToIndex:1];
    const char *character=[firstChar UTF8String];
    
    int intValue=(int)*character;//converted to ascii, however you can directly compare to character to 'a' and 'z'
    
    if ((intValue >= 97 && intValue <=122) || (intValue >= 65 && intValue <=90)) {
        NSLog(@"Alphabet");
        isAlphbet = NO;
    }
    else{
        isAlphbet = YES;
        NSLog(@"Non alphabet");
    }
}

#pragma mark:- Api For Google Place API
- (void)callApiToSearchGooglePlacesWithString:(NSString *)searchString{
    
    BOOL locationAllowed = [CLLocationManager locationServicesEnabled];
    if (locationAllowed) {
        NSString *latitudeStr = sharedInstance.latiValueStr;
        NSString *lonitudeStr = sharedInstance.longiValueStr;
        if ([latitudeStr length] && [lonitudeStr length]) {
            NSString   *requestStr = [NSString stringWithFormat:@"%@json?input=%@&sensor=%@&key=%@",GOOGLE_GEOLOCATION_URL,[[searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],@"true",GOOGLE_API_KEY];
            NSLog(@"Google Url is :%@",requestStr);
            NSString *encodedUrl = [requestStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            //  [ProgressHUD show:@"Please wait..." Interaction:NO];
            [ServerRequest AFNetworkPostRequestUrlForGooglePlace:requestStr withParams:nil CallBack:^(id responseObject, NSError *error) {
                NSLog(@"response object Post Contractor Search List %@",responseObject);
                // [ProgressHUD dismiss];
                
                if(!error) {
                    NSLog(@"Response is --%@",responseObject);
                    if ([[responseObject objectForKey:@"status"]isEqualToString:@"OK"]) {
                        [locationArray removeAllObjects];
                        NSArray *responseArray = [responseObject objectForKey:@"predictions"];
                        if (responseArray.count) {
                            [_noResultLabel setHidden:YES];
                            locationArray = [SingletonClass parseAutocompleteResponse:responseObject andError:error];
                            NSLog(@"Filtering Array >>>>>%lu",(unsigned long)locationArray.count);
                            [self.tableViewSearchBar reloadData];
                        }
                        else
                        {
                            [_noResultLabel setHidden:NO];
                        }
                        
                    } else
                    {
                        if ([[responseObject objectForKey:@"status"]isEqualToString:@"ZERO_RESULTS"]) {
                            [locationArray removeAllObjects];
                            [self.tableViewSearchBar reloadData];
                            [_noResultLabel setHidden:NO];
                        }
                    }
                }
                else{
                    [_noResultLabel setHidden:NO];
                }
            }];
        }
        else{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LATITUDEDATA"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LONGITUDEDATA"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[AlertView sharedManager] presentAlertWithTitle:@"Sorry!" message:@"We did not fetch your location.Do you want again to find the location?"
                                         andButtonsWithTitle:@[@"No",@"Yes"] onController:self
                                               dismissedWith:^(NSInteger index, NSString *buttonTitle) {
                                                   if ([buttonTitle isEqualToString:@"Yes"]) {
                                                       if ([APPDELEGATE locationManager] != nil) {
                                                           [[APPDELEGATE locationManager] startUpdatingLocation];
                                                           
                                                       }
                                                       else {
                                                           APPDELEGATE.locationManager= [[CLLocationManager alloc] init];
                                                           APPDELEGATE.locationManager.delegate = self;
                                                           APPDELEGATE.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                                                           [APPDELEGATE.locationManager requestWhenInUseAuthorization];
                                                           [APPDELEGATE.locationManager startUpdatingLocation];
                                                       }
                                                   }
                                               }];
        }
    }
    else {
        sharedInstance.latiValueStr = @"28.616789";
        sharedInstance.longiValueStr = @"77.74756";
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"LocationDataValue"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[AlertView sharedManager] presentAlertWithTitle:@"Location Service Disabled" message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                     andButtonsWithTitle:@[@"OK"] onController:self
                                           dismissedWith:^(NSInteger index, NSString *buttonTitle) {
                                               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                           }];
    }
}

-(void)callGetDetailForPlaceID:(NSString*)pladeID{
    
    NSString   *requestStr = [NSString stringWithFormat:@"%@json?placeid=%@&key=%@",GOOGLE_API_BASE_URL_DETAIL,pladeID,GOOGLE_API_KEY];
    requestStr = [requestStr stringByReplacingOccurrencesOfString:@"-" withString:@"%2D"];
    [ServerRequest AFNetworkPostRequestUrlForGooglePlace:requestStr withParams:nil CallBack:^(id responseObject, NSError *error) {
        NSLog(@"response object Post Contractor Search List %@",responseObject);
        [ProgressHUD dismiss];
        
        if(!error) {
            NSLog(@"Response is --%@",responseObject);
            if ([[responseObject objectForKey:@"status"]isEqualToString:@"OK"]) {
                _placeDetailsArray = [[NSMutableArray alloc]init];
                [_placeDetailsArray removeAllObjects];
                NSDictionary *placeDictionary = [responseObject valueForKey:@"result"];
                _placeDetailsArray = [placeDictionary objectForKey:@"address_components"] ;
                NSLog(@"Place dictionary %lu",(unsigned long)_placeDetailsArray.count);
                sharedInstance.selectedAddressStr  = [placeDictionary objectForKey:@""];
                NSLog(@"Place dictionary %@",placeDictionary);
                NSLog(@"Filtering Array >>>>>%lu",(unsigned long)_placeDetailsArray.count);
                //  [self.tableViewSearchBar reloadData];
                
            }
        }
    }];
}

#pragma mark - TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    //count of section
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (locationArray.count)
        return [locationArray count];
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"NotificationTableViewCellID";
    static NSString *MySecondIdentifier = @"NotificationID";
    NotificationTableViewCell *cell;
    if (_isFromGPSLocation) {
        cell = [tableView dequeueReusableCellWithIdentifier:MySecondIdentifier];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right-dark.png"]];
    [imageView setFrame:CGRectMake(0, 0, 15, 15)];
    
    if (locationArray.count) {
        
        PlaceObj *customObj= [locationArray objectAtIndex:indexPath.row];
        if (_isFromGPSLocation) {
            if ([customObj.placeDescription length]) {
                cell.nameLbl.text = [NSString stringWithFormat:@"%@",customObj.placeDescription];
            }
        }
        else{
            if ([customObj.placeNameWithDetails length]) {
                cell.messageLbl.text = [NSString stringWithFormat:@"%@",customObj.placeNameWithDetails];
                
            }
            if ([customObj.placeName length]) {
                cell.nameLbl.text = [NSString stringWithFormat:@"%@",customObj.placeName];
            }
            
        }
        if(customObj.checkLocationStr == YES){
            cell.accessoryView = imageView;
            customObj.checkLocationStr = NO;
        }
        else    {
            cell.accessoryView = NULL;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (locationArray.count) {
        if (_isFromGPSLocation) {
            return 50;
        }
        else
        {
            PlaceObj *customObj= [locationArray objectAtIndex:indexPath.row];
            if([customObj.placeNameWithDetails length]){
                return 65;
            }
            else{
                return 50;
            }
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedIndex = indexPath.row;
    if (locationArray.count) {
        
        PlaceObj *customObj= [locationArray objectAtIndex:indexPath.row];
        if (!customObj.checkLocationStr) {
            customObj.checkLocationStr = YES;
            sharedInstance.strChooseLocationName = [NSString stringWithFormat:@"%@",customObj.placeDescription];
            [self callGetDetailForPlaceID:customObj.placeID];
            [self getLatLongFromAddressWithString:sharedInstance.strChooseLocationName];
            // [self getLatLongAddressWithString:sharedInstance.strChooseLocationName];
            NSLog(@"Location Address %@", sharedInstance.strChooseLocationName );
        }
        else {
        }
    }
    [_tableViewSearchBar reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)getLatLongFromAddressWithString :(NSString *)str{
    addressTextField.text = str;
    [addressTextField resignFirstResponder];
    [self checkThatTextIsNeumeric:addressTextField.text];
    
    if (!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    
    [self.geocoder geocodeAddressString:str completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0) {
            
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
            
            NSString  *streetString = [CommonUtils checkStringForNULL:placemark.thoroughfare];
            NSLog(@"street %@",streetString);
            
            
            cityStr = [CommonUtils checkStringForNULL:placemark.locality];
            stateStr = [CommonUtils checkStringForNULL:placemark.administrativeArea];
            NSString  *countryStr = [CommonUtils checkStringForNULL:placemark.country];
            if (!countryStr.length) {
                countryStr = @"";
            }
            if (!cityStr.length) {
                cityStr = @"";
            }
            if (!stateStr.length) {
                stateStr = @"";
            }
            
            NSString  * zipCodeStr = [CommonUtils checkStringForNULL:placemark.postalCode];
            CLLocation *location = placemark.location;
            float latitude=  location.coordinate.latitude;
            float longitude= location.coordinate.longitude;
            
            if (!zipCodeStr.length) {
                zipCodeStr = @"";
            }
            sharedInstance.customLatiValueStr = [NSString stringWithFormat:@"%.8f", location.coordinate.latitude];
            sharedInstance.customLongiValueStr = [NSString stringWithFormat:@"%.8f", location.coordinate.longitude];
            sharedInstance.selectedAddressLatitudeStr = [NSString stringWithFormat:@"%f",latitude];
            sharedInstance.selectedAddressLongitudeStr = [NSString stringWithFormat:@"%f",longitude];
            
            sharedInstance.meetUpLocationLattitude =[NSString stringWithFormat:@"%.8f", location.coordinate.latitude];
            sharedInstance.meetUpLocationLongtitude = [NSString stringWithFormat:@"%.8f", location.coordinate.longitude];
            
            if (!cityStr.length) {
                sharedInstance.selectedAddressStr = locatedAt;
            }
            else{
                if ([zipCodeStr length]) {
                    if (_isFromGPSLocation) {
                        sharedInstance.selectedAddressStr  = [NSString stringWithFormat:@"%@,%@@",str,zipCodeStr];
                    }
                    else{
                        sharedInstance.selectedAddressStr  = [NSString stringWithFormat:@"%@,%@",str,zipCodeStr];
                    }
                }
                else{
                    if (_isFromGPSLocation) {
                        sharedInstance.selectedAddressStr = [NSString stringWithFormat:@"%@, %@,%@",str,zipCodeStr];
                    }
                    else{
                        sharedInstance.selectedAddressStr = [NSString stringWithFormat:@"%@",str,zipCodeStr];
                    }
                }
            }
            NSLog(@"CustomLocation Value%@",sharedInstance.selectedAddressStr);
            if (self.isFromRequestNow) {
                [self presentNextViewCon];
            }
            else{
                [self.delegate locationString:sharedInstance.selectedAddressStr];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
    
}

-(void)getLatLongAddressWithString :(NSString *)address{
    
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    NSString *jsonString = result;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@"Formated String %@",json);
    
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
        
        sharedInstance.selectedAddressLatitudeStr = [NSString stringWithFormat:@"%f",latitude];
        sharedInstance.selectedAddressLongitudeStr = [NSString stringWithFormat:@"%f",longitude];
        sharedInstance.meetUpLocationLattitude =[NSString stringWithFormat:@"%f",latitude];
        sharedInstance.meetUpLocationLongtitude = [NSString stringWithFormat:@"%f",longitude];
        
        if (sharedInstance.selectedAddressLatitudeStr) {
            NSArray *locationArray = [[json objectForKey:@"results"] valueForKey:@"formatted_address"];
            sharedInstance.selectedAddressStr =[locationArray firstObject];
            NSLog(@"Proper Address %@",sharedInstance.selectedAddressStr);
            [self.navigationController popViewControllerAnimated:YES];
            [self.delegate locationString:sharedInstance.selectedAddressStr];
        }
    }
}



@end

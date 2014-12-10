//
//  ViewController.m
//  Turn By Turn
//
//  Created by Romain Rivollier on 01/12/14.
//  Copyright (c) 2014 Transcovo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()


@property (nonatomic, strong)CLLocationManager          *locationManager;
@property (nonatomic, strong)MKPolyline                 *routeOverlay;
@property (nonatomic, strong)MKRoute                    *currentRoute;
@property (weak, nonatomic) IBOutlet UIBarButtonItem    *launchNaviationButton;

- (void)showAlertNoLocationAuthorized;
- (IBAction)launchNavigation:(id)sender;

@end

@implementation ViewController

#pragma View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapview.delegate = self;
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            [self.locationManager requestAlwaysAuthorization];
        }
        else {
            [CLLocationManager locationServicesEnabled];
        }
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        [self showAlertNoLocationAuthorized];
    }
    else {
        self.mapview.showsUserLocation = YES;
    }
    
    MKUserTrackingBarButtonItem *trackButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapview];
    self.navigationItem.rightBarButtonItem = trackButton;
    
    [self.launchNaviationButton setTarget:self];
 
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapview Delegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [UIColor redColor];
    renderer.lineWidth = 4.0;
    
    return  renderer;
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorized || status == kCLAuthorizationStatusAuthorizedAlways)
    {
        self.mapview.showsUserLocation = YES;
    }
    else if (status != kCLAuthorizationStatusNotDetermined)
    {
        [self showAlertNoLocationAuthorized];
    }
}

#pragma mark - AlertView

- (void)showAlertNoLocationAuthorized
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Denied"
                                                        message:@"Please give me access to your location :("
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView show];
}


#pragma mark - Navigation methods


- (IBAction)launchNavigation:(id)sender {
    
    MKDirectionsRequest *directionsRequest = [MKDirectionsRequest new];
    
    //Get the user current position on the map
    MKMapItem *start = [MKMapItem mapItemForCurrentLocation];
    
    CLLocationCoordinate2D destinationCoords = CLLocationCoordinate2DMake(48.875073, 2.298057);
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:destinationCoords addressDictionary:nil];
    MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    
    // Set the source and destination on the request
    [directionsRequest setSource:start];
    [directionsRequest setDestination:destination];
    directionsRequest.departureDate = [NSDate date];
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        // Now handle the result
        if (error) {
            NSLog(@"There was an error getting your directions %@", error);
            return;
        }
        
        // So there wasn't an error - let's plot those routes
        _currentRoute = [response.routes firstObject];
        
        if (_routeOverlay)
        {
            [_mapview removeOverlay:_routeOverlay];
        }
        
        _routeOverlay = _currentRoute.polyline;
        [_mapview addOverlay:_routeOverlay];
    }];
    
}

@end

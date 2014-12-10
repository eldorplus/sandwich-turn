//
//  ViewController.h
//  Turn By Turn
//
//  Created by Romain Rivollier on 01/12/14.
//  Copyright (c) 2014 Transcovo. All rights reserved.
//

@import UIKit;
@import CoreLocation;

#import "MKMapView+Tools.h"

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapview;

@end


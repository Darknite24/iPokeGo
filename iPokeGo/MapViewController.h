//
//  ViewController.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 21/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "UINavigationController+M13ProgressViewBar.h"
#import "PokemonAnnotation.h"
#import "GymAnnotation.h"
#import "PokestopAnnotation.h"
#import "ScanAnnotation.h"
#import "SpawnPointsAnnotation.h"
#import "SVPulsingAnnotationView.h"
#import "global.h"

extern NSString * const MapViewShowFetchStatus;
extern NSString * const MapViewReloadData;

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate, UISearchBarDelegate, UITableViewDelegate>

@property(weak, nonatomic) IBOutlet UIButton *locationButton;
@property(weak, nonatomic) IBOutlet UIButton *radarButton;
@property(weak, nonatomic) IBOutlet MKMapView *mapview;
@property(weak, nonatomic) IBOutlet UISearchBar *searchBar;

-(IBAction)locationAction:(id)sender;
-(IBAction)radarAction:(id)sender;
-(IBAction)maptypeAction:(id)sender;
-(IBAction)searchButtonAction:(id)sender;
- (IBAction)showDebugWindow:(id)sender;

@end

//
//  PokemonAnnotationView.h
//  iPokeGo
//
//  Created by Curtis herbert on 8/1/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

@import CoreLocation;
#import <MapKit/MapKit.h>
#import "global.h"
#import "PokemonAnnotation.h"
#import "TimeLabel.h"
#import "TimerLabel.h"
#import "TagLabel.h"
#import "DistanceLabel.h"

@interface PokemonAnnotationView : MKAnnotationView

@property (weak) TimeLabel* timeLabel;
@property (weak) TimerLabel* timerLabel;
@property (weak) DistanceLabel* distanceLabel;
@property (assign, nonatomic) BOOL enablePulsing;
@property (nonatomic, strong) UIColor *outerColor; // default is white
@property (nonatomic, strong) UIColor *pulseColor; // default is same as annotationColor
@property (nonatomic, readwrite) float pulseScaleFactor; // default is 5.3
@property (nonatomic, readwrite) NSTimeInterval pulseAnimationDuration; // default is 1s
@property (nonatomic, readwrite) NSTimeInterval outerPulseAnimationDuration; // default is 3s
@property (nonatomic, readwrite) NSTimeInterval delayBetweenPulseCycles; // default is 1s

- (instancetype)initWithAnnotation:(PokemonAnnotation *)annotation currentLocation:(CLLocation *)location reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setAnnotation:(id<MKAnnotation>)annotation withLocation:(CLLocation *)location;
- (bool)preventDeselection;

@end

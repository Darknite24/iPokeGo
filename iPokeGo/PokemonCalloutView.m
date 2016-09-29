//
//  PokemonCalloutView.m
//  iPokeGo
//
//  Created by Tony Lewis on 9/29/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PokemonCalloutView.h"
#import "AppDelegate.h"
#import "global.h"

@implementation PokemonCalloutView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
static NSDateFormatter *formatter;
static dispatch_once_t onceToken;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self == [super initWithCoder:aDecoder]) {
        dispatch_once(&onceToken, ^{
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateStyle = NSDateFormatterNoStyle;
            formatter.timeStyle = NSDateFormatterMediumStyle;
        });
    }
    return self;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint viewPoint = [self.superview convertPoint:point toView:self];
    
//    bool isInsideView = [self pointInside:viewPoint withEvent:event];
    
    UIView* view = [super hitTest:viewPoint withEvent:event];
    
    return view;
}

- (bool)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return CGRectContainsPoint(self.bounds, point);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self.layer setCornerRadius:8.0f];
    
    // border
    [self.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.layer setBorderWidth:.5f];
    
    UIColor *bgColor = COLOR_COMMON;
    if([self.annotation.rarity isEqualToString:@"Uncommon"])
        bgColor = COLOR_UNCOMMON;
    else if([self.annotation.rarity isEqualToString:@"Rare"])
        bgColor = COLOR_RARE;
    else if([self.annotation.rarity isEqualToString:@"Very Rare"])
        bgColor = COLOR_VERYRARE;
    else if([self.annotation.rarity isEqualToString:@"Ultra Rare"])
        bgColor = COLOR_ULTRARARE;

    [self.rarityLabel setLabelText:NSLocalizedString(self.annotation.rarity.uppercaseString, @"Pokemon rarity annotation label")];
    [self.rarityLabel setBackgroundColor:bgColor];
    self.pokeNameLabel.text = [[AppDelegate sharedDelegate].localization objectForKey:[NSString stringWithFormat:@"%@", @(self.annotation.pokemon.identifier)]];
    self.disappearsLabel.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Disappears at", @"The hint in a annotation callout that indicates when a Pokémon disappears."),
                           [formatter stringFromDate:self.annotation.pokemon.disappears]];
    NSDictionary *move1 = [[AppDelegate sharedDelegate].moves objectForKey:[NSString stringWithFormat:@"%@", @(self.annotation.pokemon.move1)]];
    NSDictionary *move2 = [[AppDelegate sharedDelegate].moves objectForKey:[NSString stringWithFormat:@"%@", @(self.annotation.pokemon.move2)]];
    
    self.movesLabel.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Moves", @"The moves for this pokemon."),
                            [move1 objectForKey:@"name"],
                            [move2 objectForKey:@"name"]];

    double total = (self.annotation.pokemon.attack + self.annotation.pokemon.defense + self.annotation.pokemon.stamina);
    double totalDivided = total / 45;
    double iv = totalDivided * 100;
    self.ivLabel.text = [NSString localizedStringWithFormat:NSLocalizedString(@"IV", @"The IV calculation for this pokemon."),
                         iv, self.annotation.pokemon.attack, self.annotation.pokemon.defense, self.annotation.pokemon.stamina];
}

- (IBAction)driveButton_TouchUpInside:(id)sender {
    CLLocationCoordinate2D endingCoord = CLLocationCoordinate2DMake(self.annotation.coordinate.latitude, self.annotation.coordinate.longitude);
    
    NSString *drivingMode = [[NSUserDefaults standardUserDefaults] objectForKey:@"driving_mode"];
    MKPlacemark *endLocation = [[MKPlacemark alloc] initWithCoordinate:endingCoord addressDictionary:nil];
    MKMapItem *endingItem = [[MKMapItem alloc] initWithPlacemark:endLocation];
    
    NSMutableDictionary *launchOptions = [[NSMutableDictionary alloc] init];
    [launchOptions setObject:drivingMode forKey:MKLaunchOptionsDirectionsModeKey];
    
    [endingItem openInMapsWithLaunchOptions:launchOptions];
    [self removeFromSuperview];
}
@end

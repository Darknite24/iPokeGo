//
//  PokemonCalloutView.h
//  iPokeGo
//
//  Created by Tony Lewis on 9/29/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TagLabel.h"
#import "PokemonAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

@interface PokemonCalloutView : UIView

@property (nonatomic, strong) PokemonAnnotation* annotation;

@property (weak, nonatomic) IBOutlet TagLabel *rarityLabel;
@property (weak, nonatomic) IBOutlet UILabel *pokemonNameLabel;
@property (weak, nonatomic) IBOutlet TagLabel *type1Label;
@property (weak, nonatomic) IBOutlet TagLabel *type2Label;
@property (weak, nonatomic) IBOutlet UILabel *pokeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *disappearsLabel;
@property (weak, nonatomic) IBOutlet UILabel *ivLabel;
@property (weak, nonatomic) IBOutlet UILabel *movesLabel;
@property (weak, nonatomic) IBOutlet UIButton *driveButton;

- (IBAction)driveButton_TouchUpInside:(id)sender;

@end

NS_ASSUME_NONNULL_END

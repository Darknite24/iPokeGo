//
//  PokemonListTableViewCell.h
//  PokeTracks
//
//  Created by Tony Lewis on 8/30/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "TimerLabel.h"
#import "Pokemon+CoreDataProperties.h"

@interface PokemonListTableViewCell : UITableViewCell

@property (strong, nonatomic) Pokemon *pokemon;
@property (weak, nonatomic) IBOutlet UIImageView *pokemonImageView;
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;
@property (weak, nonatomic) IBOutlet TimerLabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *disappearsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteImageView;


@end

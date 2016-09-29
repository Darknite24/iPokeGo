//
//  PokemonListTableViewCell.m
//  PokeTracks
//
//  Created by Tony Lewis on 8/30/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "PokemonListTableViewCell.h"

@implementation PokemonListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    self.timerLabel.preferredBackgroundColor = [UIColor clearColor];
    self.timerLabel.font = self.disappearsLabel.font;
    NSDate *date = [NSDate date];
    NSDate *disappears = [self.pokemon.disappears dateByAddingTimeInterval:-(2*60)];
    if ([disappears compare:date] == NSOrderedAscending) {
        self.timerLabel.textColor = [UIColor colorWithRed:0.8f green:0.0f blue:0.0f alpha:0.7f];
    } else {
        self.timerLabel.textColor = self.disappearsLabel.textColor;
    }
    if ([self.pokemon isFav]) {
//        self.favoriteImageView.hidden = NO;
        self.backgroundColor = [UIColor colorWithRed:0.0f green:0.7f blue:0.0f alpha:0.4f];
    } else {
//        self.favoriteImageView.hidden = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    [super drawRect:rect];
}

@end

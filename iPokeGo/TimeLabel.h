//
//  TimeLabel.h
//  iPokeGo
//
//  Created by Valeriy Pogoniev on 26/7/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeLabel : UILabel

@property (nonatomic, strong) UIColor *preferredBackgroundColor;

- (void)setDate:(NSDate*)date;

@end

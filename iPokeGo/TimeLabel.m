//
//  TimeLabel.m
//  iPokeGo
//
//  Created by Valeriy Pogoniev on 26/7/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "TimeLabel.h"
#import "NSString+Formatting.h"

@implementation TimeLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.preferredBackgroundColor = nil;
        self.font = [UIFont boldSystemFontOfSize:10.0];
        self.textAlignment = NSTextAlignmentCenter;
        self.textColor = [UIColor colorWithWhite:.1f alpha:1.0f];
    }
    return self;
}

- (void)setDate:(NSDate*)date
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
    });
    
    self.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
}

- (void)drawRect:(CGRect)rect
{
    self.layer.cornerRadius = 3.0f;
    if (!self.preferredBackgroundColor) {
        self.layer.backgroundColor = [UIColor colorWithWhite:.8f alpha:0.5f].CGColor;
    } else {
        self.layer.backgroundColor = self.preferredBackgroundColor.CGColor;
    }
    
    [super drawRect:rect];
}

@end

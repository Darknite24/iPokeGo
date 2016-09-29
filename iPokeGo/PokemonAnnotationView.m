//
//  PokemonAnnotationView.m
//  iPokeGo
//
//  Created by Curtis herbert on 8/1/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "PokemonAnnotationView.h"
#import "global.h"
#import "PokemonCalloutView.h"

#define POKEMON_ANNOTATION_TIMER_WIDTH 30.0f
#define POKEMON_ANNOTATION_TIMER_HEIGHT 15.0f

@interface PokemonAnnotationView() {
    PokemonCalloutView *calloutView;
    bool hitOutside;
}

@property CLLocation *location;
@property (nonatomic, strong) CALayer *colorHaloLayer;
@property (nonatomic, strong) CAAnimationGroup *pulseAnimationGroup;

@end

@implementation PokemonAnnotationView

- (bool)preventDeselection {
    return !hitOutside;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (((PokemonAnnotation*)self.annotation).pokemon.attack > 0) {
        bool calloutViewAdded = (calloutView) ? calloutView.superview != nil : NO;
    
        if (selected || (!selected && hitOutside)) {
            [super setSelected:selected animated:animated];
        }
        
        [self.superview bringSubviewToFront:self];
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PokemonCalloutView"
                                                         owner:nil
                                                       options:nil];
        
        for (id currentObject in objects){
            if ([currentObject isKindOfClass:[PokemonCalloutView class]])
                calloutView = currentObject;
        }
        calloutView.center = CGPointMake(self.bounds.size.width / 2, -(calloutView.bounds.size.height*0.52));
        calloutView.annotation = self.annotation;
        
        if (self.selected && !calloutViewAdded) {
            [self addSubview:calloutView];
        }
        
        if (!self.selected) {
            [calloutView removeFromSuperview];
        }
    }
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if (hitView == nil && self.selected) {
        hitView = [calloutView hitTest:point withEvent:event];
    }
    
    hitOutside = hitView == nil;
    
    return hitView;
}

#pragma mark - Pulsing Code

+ (NSMutableDictionary*)cachedRingImages {
    static NSMutableDictionary *cachedRingLayers = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{ cachedRingLayers = [NSMutableDictionary new]; });
    return cachedRingLayers;
}

- (void)rebuildLayers {
    [_colorHaloLayer removeFromSuperlayer];
    _colorHaloLayer = nil;
    
    _pulseAnimationGroup = nil;
    
    if (self.enablePulsing) {
        [self.layer addSublayer:self.colorHaloLayer];
    }
}

- (void)willMoveToSuperview:(UIView *)superview {
    if(superview)
        [self rebuildLayers];
}

#pragma mark - Setters

- (void)setAnnotationColor:(UIColor *)annotationColor {
    if(CGColorGetNumberOfComponents(annotationColor.CGColor) == 2) {
        float white = CGColorGetComponents(annotationColor.CGColor)[0];
        float alpha = CGColorGetComponents(annotationColor.CGColor)[1];
        annotationColor = [UIColor colorWithRed:white green:white blue:white alpha:alpha];
    }
    
    if(self.superview)
        [self rebuildLayers];
}

- (void)setDelayBetweenPulseCycles:(NSTimeInterval)delayBetweenPulseCycles {
    _delayBetweenPulseCycles = delayBetweenPulseCycles;
    
    if(self.superview)
        [self rebuildLayers];
}

- (void)setPulseAnimationDuration:(NSTimeInterval)pulseAnimationDuration {
    _pulseAnimationDuration = pulseAnimationDuration;
    
    if(self.superview)
        [self rebuildLayers];
}

#pragma mark - Getters

- (UIColor *)pulseColor {
    if(!_pulseColor)
        return [UIColor colorWithRed:1 green:0 blue:0 alpha:1.0];
    return _pulseColor;
}

- (CAAnimationGroup*)pulseAnimationGroup {
    if(!_pulseAnimationGroup) {
        CAMediaTimingFunction *defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        
        _pulseAnimationGroup = [CAAnimationGroup animation];
        _pulseAnimationGroup.duration = self.outerPulseAnimationDuration + self.delayBetweenPulseCycles;
        _pulseAnimationGroup.repeatCount = INFINITY;
        _pulseAnimationGroup.removedOnCompletion = NO;
        _pulseAnimationGroup.timingFunction = defaultCurve;
        
        NSMutableArray *animations = [NSMutableArray new];
        
        CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
        pulseAnimation.fromValue = @0.0;
        pulseAnimation.toValue = @1.0;
        pulseAnimation.duration = self.outerPulseAnimationDuration;
        [animations addObject:pulseAnimation];
        
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        animation.duration = self.outerPulseAnimationDuration;
        animation.values = @[@0.45, @0.45, @0];
        animation.keyTimes = @[@0, @0.2, @1];
        animation.removedOnCompletion = NO;
        [animations addObject:animation];
        
        _pulseAnimationGroup.animations = animations;
    }
    return _pulseAnimationGroup;
}

- (CALayer *)colorHaloLayer {
    if(!_colorHaloLayer) {
        _colorHaloLayer = [CALayer layer];
        CGFloat width = self.bounds.size.width*self.pulseScaleFactor;
        _colorHaloLayer.bounds = CGRectMake(0, 0, width, width);
        _colorHaloLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        _colorHaloLayer.contentsScale = [UIScreen mainScreen].scale;
        _colorHaloLayer.backgroundColor = self.pulseColor.CGColor;
        _colorHaloLayer.cornerRadius = width/2;
        _colorHaloLayer.opacity = 0;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            if(self.delayBetweenPulseCycles != INFINITY) {
                CAAnimationGroup *animationGroup = self.pulseAnimationGroup;
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self->_colorHaloLayer addAnimation:animationGroup forKey:@"pulse"];
                });
            }
        });
    }
    return _colorHaloLayer;
}

- (UIImage*)circleImageWithColor:(UIColor*)color height:(float)height {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(height, height), NO, 0);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    UIBezierPath* fillPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, height, height)];
    [color setFill];
    [fillPath fill];
    
    UIImage *dotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGColorSpaceRelease(colorSpace);
    
    return dotImage;
}

//- (void)timerExpired {
//    self.hidden = YES;
//    DebugLog(@"Hiding expired Pokemon Annotation");
//}

#pragma mark - Annotation Code

- (instancetype)initWithAnnotation:(PokemonAnnotation *)annotation currentLocation:(CLLocation *)location reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        UIButton *button    = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *btnImage   = [UIImage imageNamed:@"drive"];
        button.frame = CGRectMake(0, 0, 30, 30);
        [button setImage:btnImage forState:UIControlStateNormal];
        
        if (annotation.pokemon.attack > 0) {
            self.canShowCallout = NO;
        } else {
            self.canShowCallout = YES;
        }
        self.rightCalloutAccessoryView = button;
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"Pokemon_%@", @(annotation.pokemonID)]];
        self.frame = CGRectMake(0, 0, 45, 45);
        self.location = location;
        
        UIColor *bgColor = COLOR_COMMON;
        if([annotation.rarity isEqualToString:@"Uncommon"])
            bgColor = COLOR_UNCOMMON;
        else if([annotation.rarity isEqualToString:@"Rare"])
            bgColor = COLOR_RARE;
        else if([annotation.rarity isEqualToString:@"Very Rare"])
            bgColor = COLOR_VERYRARE;
        else if([annotation.rarity isEqualToString:@"Ultra Rare"])
            bgColor = COLOR_ULTRARARE;

        if([annotation.rarity length] > 0)
        {
            TagLabel *tagLabelView = [[TagLabel alloc] init];
            [tagLabelView setLabelText:NSLocalizedString(annotation.rarity.uppercaseString, @"Pokemon rarity annotation label")];
            [tagLabelView setBackgroundColor:bgColor];
            self.leftCalloutAccessoryView = tagLabelView;
        }

        self.layer.anchorPoint = CGPointMake(0, 0);
        self.calloutOffset = CGPointMake(0, 4);
        self.pulseScaleFactor = 2.3;
        self.pulseAnimationDuration = 1.5;
        self.outerPulseAnimationDuration = 3;
        self.delayBetweenPulseCycles = 0;
        self.outerColor = [UIColor whiteColor];

        [self updateForAnnotation:annotation withLocation:location];
    }
    return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation withLocation:(CLLocation *)location
{
    self.location = location;
    super.annotation = annotation;
    
    [self updateForAnnotation:annotation withLocation:location];
}

- (void)updateForAnnotation:(PokemonAnnotation *)annotation withLocation:(CLLocation *)location
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"display_time"] && ![defaults boolForKey:@"display_timer"]) {
        if (!self.timeLabel) {
            TimeLabel *timeLabelView = [self timeLabelForAnnotation:annotation withContainerFrame:self.frame];
            [self addSubview:timeLabelView];
            self.timeLabel = timeLabelView;
        } else {
            [self.timeLabel setDate:annotation.expirationDate];
        }
    } else {
        [self.timeLabel removeFromSuperview];
    }
    
    if ([defaults boolForKey:@"display_timer"]) {
        if (!self.timerLabel) {
            TimerLabel *timerLabelView = [self timerLabelForAnnotation:annotation withContainerFrame:self.frame];
            [self addSubview:timerLabelView];
            self.timerLabel = timerLabelView;
        } else {
            [self.timerLabel setDate:annotation.expirationDate];
        }
    } else {
        [self.timerLabel removeFromSuperview];
    }
    
    if ([defaults boolForKey:@"display_distance"]) {
        if (!self.distanceLabel) {
            DistanceLabel *distaneView = [self distanceLabelForAnnotation:annotation withContainerFrame:self.frame andCurrentLocation:location];
            [self addSubview:distaneView];
            self.distanceLabel = distaneView;
        } else {
            CLLocation *pokemonLocation = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
            [self.distanceLabel setDistanceBetweenUser:location andLocation:pokemonLocation];
        }
    } else {
        [self.distanceLabel removeFromSuperview];
    }
}

- (CGRect)rectForImage {
    // Create a CGRect the size of the image we are using in the annotation.
    CGRect imageFrame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    return imageFrame;
}

- (CGRect)rectForTimerLabelWithContainerFrame:(CGRect)frame {
    CGFloat labelWidth = CGRectGetWidth(frame) - 10.0f;
    CGRect timerLabelFrame = CGRectMake(0.0f, 0.0f, labelWidth, POKEMON_ANNOTATION_TIMER_HEIGHT);
    timerLabelFrame.origin.x = (CGRectGetWidth(frame) - labelWidth) / 2;
    timerLabelFrame.origin.y = -(POKEMON_ANNOTATION_TIMER_HEIGHT); // frame.origin.y - (POKEMON_ANNOTATION_TIMER_HEIGHT * 2);
    
    return timerLabelFrame;
}

- (TimeLabel*)timeLabelForAnnotation:(PokemonAnnotation*)annotation withContainerFrame:(CGRect)frame {
    CGRect labelBounds = [self rectForTimerLabelWithContainerFrame:frame];
    TimeLabel *timeLabel = [[TimeLabel alloc] initWithFrame:labelBounds]; //CGRectMake(13, -1, 40, 10)];
    [timeLabel setDate:annotation.expirationDate];
    return timeLabel;
}

- (TimerLabel*)timerLabelForAnnotation:(PokemonAnnotation*)annotation withContainerFrame:(CGRect)frame {
    CGRect labelBounds = [self rectForTimerLabelWithContainerFrame:frame];
    TimerLabel *timerLabel = [[TimerLabel alloc] initWithFrame:labelBounds]; //CGRectMake(13, -1, 40, 10)];
    [timerLabel setDate:annotation.expirationDate];
    return timerLabel;
}
- (DistanceLabel*)distanceLabelForAnnotation:(PokemonAnnotation*)annotation withContainerFrame:(CGRect)frame andCurrentLocation:(CLLocation *)location {
    CLLocation *pokemonLocation = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
    DistanceLabel *distanceLabel = [[DistanceLabel alloc] initWithFrame:CGRectMake(-7, 45, 50, 10)];
    [distanceLabel setDistanceBetweenUser:location andLocation:pokemonLocation];
    return distanceLabel;
}

@end

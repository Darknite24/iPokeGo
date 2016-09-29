//
//  AppDelegate.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 21/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PokemonNotifier.h"

extern NSString * const AppDelegateNotificationTapped;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL masterUser;
@property (nonatomic, readonly, getter=getNotifier) PokemonNotifier *notifier;
@property (nonatomic, readonly, getter=getLocalization) NSDictionary *localization;
@property (nonatomic, readonly, getter=getMoves) NSDictionary *moves;

+ (AppDelegate *)sharedDelegate;


@end


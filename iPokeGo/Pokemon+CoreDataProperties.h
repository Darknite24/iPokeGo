//
//  Pokemon+CoreDataProperties.h
//  iPokeGo
//
//  Created by Curtis herbert on 7/30/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "Pokemon+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Pokemon (CoreDataProperties)

@property (nonatomic) int32_t attack;
@property (nonatomic) int32_t defense;
@property (nullable, nonatomic, copy) NSDate *disappears;
@property (nullable, nonatomic, copy) NSString *encounter;
@property (nonatomic) int32_t identifier;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) int32_t move1;
@property (nonatomic) int32_t move2;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *spawnpoint;
@property (nullable, nonatomic, copy) NSString *rarity;
@property (nonatomic) int32_t stamina;

@end

NS_ASSUME_NONNULL_END

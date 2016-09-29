//
//  PokemonAnnotation.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 22/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "PokemonAnnotation.h"
#import "AppDelegate.h"

@implementation PokemonAnnotation

- (instancetype)initWithPokemon:(Pokemon *)pokemon // localization:(NSDictionary *)localization andMoves:(NSDictionary*)moves
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterNoStyle;
        formatter.timeStyle = NSDateFormatterMediumStyle;
    });
    
    if (self = [super init]) {
        self.pokemon = pokemon;
        self.spawnpointID   = pokemon.spawnpoint;
        self.expirationDate = pokemon.disappears;
        self.rarity         = pokemon.rarity;
        self.coordinate     = pokemon.location;
        self.title          = [[AppDelegate sharedDelegate].localization objectForKey:[NSString stringWithFormat:@"%@", @(pokemon.identifier)]];
        self.subtitle       = [NSString localizedStringWithFormat:NSLocalizedString(@"Disappears at", @"The hint in a annotation callout that indicates when a Pokémon disappears."),
                               [formatter stringFromDate:pokemon.disappears]];
        self.pokemonID      = pokemon.identifier;
    }
    return self;
}

@end

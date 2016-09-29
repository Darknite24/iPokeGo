//
//  PokemonListTableViewController.m
//  PokeTracks
//
//  Created by Tony Lewis on 8/30/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "CoreDataPersistance.h"
#import "PokemonListTableViewController.h"
#import "PokemonListTableViewCell.h"
#import "Pokemon+CoreDataProperties.h"
#import "AppDelegate.h"

static NSString *pokemonListReuseIdentifier = @"PokemonListReuseIdentifier";

@interface PokemonListTableViewController () <NSFetchedResultsControllerDelegate>
@property NSDictionary *localization;
@property NSFetchedResultsController *pokemonFetchResultController;
@property UILabel *noDataLabel;
@end

@implementation PokemonListTableViewController

static NSDateFormatter *formatter;
static dispatch_once_t onceToken;

- (void)buildNoDataView {
    self.noDataLabel             = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
    self.noDataLabel.text             = NSLocalizedString(@"No Pokemon", @"No Pokémon");
    self.noDataLabel.textColor        = [UIColor blackColor];
    self.noDataLabel.textAlignment    = NSTextAlignmentCenter;
    self.tableView.backgroundView     = self.noDataLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterNoStyle;
        formatter.timeStyle = NSDateFormatterMediumStyle;
    });

    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
    [self buildNoDataView];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self loadLocalization];
    [self reloadTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)driveButtonTapped:(id)sender event:(UIControlEvents)event {
    Pokemon *pokemon = [self.pokemonFetchResultController objectAtIndexPath:[NSIndexPath indexPathForRow:((UIButton *)sender).tag inSection:0]];
    
    NSString *drivingMode = [[NSUserDefaults standardUserDefaults] objectForKey:@"driving_mode"];
    MKPlacemark *endLocation = [[MKPlacemark alloc] initWithCoordinate:pokemon.location addressDictionary:nil];
    MKMapItem *endingItem = [[MKMapItem alloc] initWithPlacemark:endLocation];
    
    NSMutableDictionary *launchOptions = [[NSMutableDictionary alloc] init];
    [launchOptions setObject:drivingMode forKey:MKLaunchOptionsDirectionsModeKey];
    
    [endingItem openInMapsWithLaunchOptions:launchOptions];
}

- (void)reloadTable {
    self.pokemonFetchResultController.delegate = nil;
    self.pokemonFetchResultController = [self newPokemonFetchResultsController];
}

-(void)loadLocalization {
    NSError *error;
    
    NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"pokemon" withExtension:@"json"];
    
    self.localization = [[NSDictionary alloc] init];
    
    NSString *stringPath = [filePath absoluteString];
    NSData *localizationData = [NSData dataWithContentsOfURL:[NSURL URLWithString:stringPath]];
    
    self.localization = [NSJSONSerialization JSONObjectWithData:localizationData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numOfSections = 0;
    
    if ([self.pokemonFetchResultController sections].count > 0) {
        tableView.separatorStyle     = UITableViewCellSeparatorStyleNone;
        numOfSections            = 1;
        self.noDataLabel.hidden = YES;
    }
    else {
        self.noDataLabel.hidden = NO;
        tableView.separatorStyle     = UITableViewCellSeparatorStyleNone;
    }
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([[AppDelegate sharedDelegate].window.rootViewController isKindOfClass:[UINavigationController class]] &&
        [[((UINavigationController*)[AppDelegate sharedDelegate].window.rootViewController).viewControllers objectAtIndex:0] isKindOfClass:[MapViewController class]]) {
        MapViewController *mapViewController = [((UINavigationController*)[AppDelegate sharedDelegate].window.rootViewController).viewControllers objectAtIndex:0];
        PokemonListTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        MKCoordinateRegion region;
        region.center = cell.pokemon.location;
        region.span.latitudeDelta   = MAP_SCALE_ANNOT;
        region.span.longitudeDelta  = MAP_SCALE_ANNOT;
        [mapViewController.mapview setRegion:region animated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.pokemonFetchResultController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(PokemonListTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    UIButton *button    = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImage   = [UIImage imageNamed:@"drive"];
    button.frame = CGRectMake(0, 0, 30, 30);
    [button setImage:btnImage forState:UIControlStateNormal];
    button.tag = indexPath.row;
    [button addTarget:self action:@selector(driveButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    cell.accessoryView = button;
    
    
    Pokemon *pokemon = [self.pokemonFetchResultController objectAtIndexPath:indexPath];
    cell.pokemon = pokemon;
    cell.pokemonImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Pokemon_%d", pokemon.identifier]];
    
    NSString *message   = nil;
    if([pokemon isFav]) {
        message = [NSString localizedStringWithFormat:NSLocalizedString(@"[Pokemon], a favorite pokemon, was added to the map!", @"The hint that a favorite Pokémon appeared on the map.") , [self.localization objectForKey:[NSString stringWithFormat:@"%d", pokemon.identifier]]];
    } else {
        message = [NSString localizedStringWithFormat:NSLocalizedString(@"[Pokemon] was added to the map!", @"The hint that a certain Pokémon appeared on the map.") , [self.localization objectForKey:[NSString stringWithFormat:@"%d", pokemon.identifier]]];
    }
    cell.notificationLabel.text = message;
    cell.disappearsLabel.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Disappears at", @"The hint in a annotation callout that indicates when a Pokémon disappears."),
                                 [formatter stringFromDate:pokemon.disappears]];
    [cell.timerLabel setDate:pokemon.disappears];
    if ([pokemon isFav]) {
//        cell.favoriteImageView.hidden = NO;
        cell.backgroundColor = [UIColor colorWithRed:0.0f green:0.7f blue:0.0f alpha:0.4f];
    } else {
//        cell.favoriteImageView.hidden = YES;
        cell.backgroundColor = [UIColor whiteColor];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PokemonListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:pokemonListReuseIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelButton_TouchUpInside:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)newPokemonFetchResultsController
{
        NSArray *favorites = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pokemon_favorite"] valueForKey:@"intValue"];
        if (!favorites) {
            favorites = @[];
        }
        NSArray *common = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pokemon_common"] valueForKey:@"intValue"];
        if (!common) {
            common = @[];
        }
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Pokemon"];
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"disappears" ascending:YES]]];
        request.fetchBatchSize = 50;
        NSMutableArray *predicates = [[NSMutableArray alloc] init];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"display_onlyfav"]) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"identifier IN %@" argumentArray:@[favorites]]];
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"display_common"]) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"NOT (identifier IN %@)" argumentArray:@[common]]];
        }
        [request setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[CoreDataPersistance sharedInstance].uiContext sectionNameKeyPath:nil cacheName:nil];
        frc.delegate = self;
        NSError *error = nil;
        if (![frc performFetch:&error]) {
            NSLog(@"Error performing fetch request for pokemon listing: %@", error);
        }
        
        return frc;
}
/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

@end

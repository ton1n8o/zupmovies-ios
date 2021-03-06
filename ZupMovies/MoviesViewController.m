//
//  MoviesViewController.m
//  ZupMovies
//
//  Created by Antonio Carlos Silva on 3/12/16.
//  Copyright © 2016 Antonio Carlos Silva. All rights reserved.
//

#import "MoviesViewController.h"
#import "AppDelegate.h"

@interface MoviesViewController ()

@end

@implementation MoviesViewController

@synthesize moviesTableView;

#pragma mark - Variables

NSMutableArray *_movies;

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.moviesTableView setAllowsSelectionDuringEditing:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self updateTableView:[self findAllMovies]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"segueAddMovie"]) {
        SearchViewController *view = segue.destinationViewController;
        view.moviesViewController = self;
        
    } else if ([segue.identifier isEqualToString:@"showMovieDetailFromHome"]) {
        
        MovieDetailViewController *view = segue.destinationViewController;
        view.hideSaveButton = YES;
        
        NSIndexPath *indexPath = [self.moviesTableView indexPathForSelectedRow];
        
        UITableViewCell *cell = [self.moviesTableView cellForRowAtIndexPath:indexPath];
        
        UIImageView *imageView = [cell viewWithTag:1];
        view.image = imageView.image;
        view.movie = [_movies objectAtIndex:indexPath.row];
    }
}

#pragma mark - UITableViewDelegate Delegate Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_movies && _movies.count > 0) {
        tableView.backgroundView = nil;
        return 1;
    }
    
    // Display a message when the table is empty
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    messageLabel.text = NSLocalizedString(@"NO_MOVIES_SAVED", @"Empty table view.");
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
    [messageLabel sizeToFit];
    
    tableView.backgroundView = messageLabel;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    return  0;
}

- (UITableViewCell *)tableView:(UITableView *)tblView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"cell";
    
    UITableViewCell *cell = [tblView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: cellID];
    }
    
    Movie *movie = [_movies objectAtIndex:indexPath.row];
    
    ((UILabel*) [cell viewWithTag: 2]).text = movie.title;
    ((UILabel*) [cell viewWithTag: 3]).text = movie.year;
    ((UILabel*) [cell viewWithTag: 4]).text = movie.genre;
    ((UILabel*) [cell viewWithTag: 6]).text = movie.imdbRaiting;
    
    if (movie.imdbRaiting.length == 0) {
        ((UILabel*) [cell viewWithTag: 7]).text = @"";
    }
    
    UIImageView *imgView = (UIImageView*) [cell viewWithTag: 1];
    imgView.image = movie.image;
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _movies.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.moviesTableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Movie *movie = (Movie*) [_movies objectAtIndex:indexPath.row];
        
        NSManagedObject *m = [self  findMovieBy:movie.imdbID];
        if (m) {
            
            [[self managedObjectContext] deleteObject:m];
            
            NSError *error = nil;
            if (![[self managedObjectContext] save:&error]) {
                NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                return;
            }
            
            [_movies removeObjectAtIndex:indexPath.row];
            [self.moviesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }
}

#pragma mark - MovieDelegate

-(void)updateMovies:(BOOL)update
{
    [self updateTableView:[self findAllMovies]];
}

#pragma mark - Helpers

- (void) updateTableView:(NSArray *)movies
{
    _movies = [[NSMutableArray alloc] initWithArray:movies];
    NSLog(@"Movies: %tu", [_movies count]);
    dispatch_async(dispatch_get_main_queue(), ^{
        // code here
        [self.moviesTableView reloadData];
    });
}

- (NSMutableArray*) findAllMovies
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Movie"
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    [request setPredicate:[NSPredicate predicateWithValue:YES]];
    
    // New movies on top
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if ([objects count] == 0) {
        return nil;
    } else {
        NSMutableArray *movies = [[NSMutableArray alloc] init];
        for (id obj in objects) {
            
            Movie *movie = [[Movie alloc] init];
            movie.title = [obj valueForKey:@"title"];
            movie.genre = [obj valueForKey:@"genre"];
            movie.year = [obj valueForKey:@"year"];
            movie.actors = [obj valueForKey:@"actors"];
            movie.imdbID = [obj valueForKey:@"imdbID"];
            movie.imdbRaiting = [obj valueForKey:@"imdbRaiting"];
            movie.image = [UIImage imageWithData:[obj valueForKey:@"picture"]];
            
            [movies addObject:movie];
            
        }
        
        return  movies;
    }
}

- (NSManagedObject*) findMovieBy:(NSString *) imdbId
{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Movie"
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred =
    [NSPredicate predicateWithFormat:@"(imdbID = %@)", imdbId];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if ([objects count] == 0) {
        return nil;
    } else {
        return objects[0];
    }
}

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

@end

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

NSMutableArray *_movies;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.moviesTableView setAllowsSelectionDuringEditing:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self updateTableView:[self findAllMovies]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"segueAddMovie"]) {
        ViewController *view = segue.destinationViewController;
        view.moviesViewController = self;
    }
}

#pragma mark - UITableViewDelegate Delegate Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
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
    
    UIImageView *imgView = (UIImageView*) [cell viewWithTag: 1];
    imgView.image = movie.image;
    
//    [imgView sd_setImageWithURL:
//     [NSURL URLWithString:movie.poster]
//               placeholderImage:[UIImage
//                                 imageNamed:@"zup_movies.png"]];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _movies.count;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
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

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

@end

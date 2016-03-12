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

NSArray *_movies;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self updateTableView:[self findMovies]];
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

#pragma mark - MovieDelegate

-(void)updateMovies:(BOOL)update
{
    [self updateTableView:[self findMovies]];
}

#pragma mark - Helpers

- (void) updateTableView:(NSArray *)movies
{
    _movies = movies;
    NSLog(@"Movies: %tu", [_movies count]);
    dispatch_async(dispatch_get_main_queue(), ^{
        // code here
        [self.moviesTableView reloadData];
    });
}

- (NSMutableArray*) findMovies
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
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
            movie.image = [UIImage imageWithData:[obj valueForKey:@"picture"]];
            
            [movies addObject:movie];
            
        }
        
        return  movies;
    }
}

@end

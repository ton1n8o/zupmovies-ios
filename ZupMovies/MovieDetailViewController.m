//
//  MovieDetailViewController.m
//  ZupMovies
//
//  Created by Antonio Carlos Silva on 3/9/16.
//  Copyright © 2016 Antonio Carlos Silva. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "Movie.h"

@interface MovieDetailViewController ()

@end

@implementation MovieDetailViewController

@synthesize imdbId, movieTitle, navigationItem, hideSaveButton;

Movie *movie;
UIBarButtonItem *btnSaveTmp;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // update view
    self.imageView.image = self.image;
    self.lblMovieTitle.text = self.movieTitle;
    
    [self loadMovieDetails:self.imdbId withCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        movie = [self parseData:data];
        
        if (movie) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // code here
                self.lblGenre.text = movie.genre;
                
            });
            
        }
        
    }];
   
    if (hideSaveButton) {
       self.navigationItem.rightBarButtonItem = nil; 
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save:(id)sender
{
    
    if ([self findMovie:movie.imdbID]) {
        [self showAlertDialogWithMessage:@"Filme já salvo!"
                                   title:nil
                                okAction:[UIAlertAction actionWithTitle:@"OK"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:nil]];
        return;
    }
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSManagedObject *newMovie;
    newMovie = [NSEntityDescription insertNewObjectForEntityForName:@"Movie"
                                             inManagedObjectContext:context];
    
    [newMovie setValue: movie.title forKey: @"title"];
    [newMovie setValue: movie.genre forKey: @"genre"];
    [newMovie setValue: movie.actors forKey: @"actors"];
    [newMovie setValue: movie.year forKey: @"year"];
    [newMovie setValue: movie.imdbID forKey: @"imdbID"];
    [newMovie setValue: UIImageJPEGRepresentation(_image, 1) forKey:@"picture"];
    
    NSError *error;
    if ([context save:&error] == NO) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    } else {
        [self showAlertDialogWithMessage:@"Filme salvo com suceso!"
                                   title:nil
                                okAction:[UIAlertAction actionWithTitle:@"OK"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * action) {
                                                                    [self dismissViewControllerAnimated:YES completion:nil];
                                                                }]];
        
        if([self.delegate conformsToProtocol:@protocol(MovieDelegate)]) {
            [self.delegate updateMovies: YES];
        }
    }
    
}

- (Movie*) findMovie:(NSString *) imdbId
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:@"Movie"
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *pred =
    [NSPredicate predicateWithFormat:@"(imdbID = %@)", movie.imdbID];
    [request setPredicate:pred];
    NSManagedObject *matches = nil;
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if ([objects count] == 0) {
        return nil;
    } else {
        matches = objects[0];
        movie.title = [matches valueForKey:@"title"];
        movie.genre = [matches valueForKey:@"genre"];
        movie.actors = [matches valueForKey:@"actors"];
        return  movie;
    }
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helpers

- (void) showAlertDialogWithMessage:(NSString*)msg title:(NSString*) title okAction:(UIAlertAction*)action
{
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle: title
                                          message: msg
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction: action];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // code here
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

#pragma mark - Search

- (void) loadMovieDetails:(NSString*)movieImdbId withCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler
{
    
    NSString *url = [NSString stringWithFormat:@"%@%@%@", SERVER_PATH, @"?i=", movieImdbId];
    
    NSLog(@"URL: %@", url);
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Send a synchronous request
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:20.0];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:handler] resume];
    
}

- (Movie *) parseData:(NSData *) data
{
    if (data) {
        NSError *jsonParsingError = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        
        if (object) {
            
            NSDictionary *dictData = (NSDictionary*) object;
            
            if (dictData && dictData.count > 0) {
                
                return [Movie parseDictionary:dictData];
            }
            
        }
        
    }
    return nil;
}

@end

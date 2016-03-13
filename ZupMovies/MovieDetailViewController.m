//
//  MovieDetailViewController.m
//  ZupMovies
//
//  Created by Antonio Carlos Silva on 3/9/16.
//  Copyright © 2016 Antonio Carlos Silva. All rights reserved.
//

#import "MovieDetailViewController.h"

@interface MovieDetailViewController ()

@end

@implementation MovieDetailViewController

#pragma mark - Variables

@synthesize hideSaveButton, movie;

UITapGestureRecognizer *tap;
BOOL isFullScreen;
CGRect prevFrame;
UIBarButtonItem *btnSaveTmp;

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // poster fullscreen screen on tap
    isFullScreen = false;
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgToFullScreen)];
    [tap setNumberOfTouchesRequired:1];
    tap.delegate = self;
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView addGestureRecognizer:tap];
    
    NSString *imdbID = self.movie.imdbID;
    
    // update view
    movie = [self findMovie:movie.imdbID];
    
    if (movie) {
        [self showMovieData:movie];
    } else {
        
        [self loadMovieDetails:imdbID withCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self showMovieData:[self parseData:data]];
            
        }];
    }
    
    if (hideSaveButton) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)showMovieData:(Movie*) movieLoaded
{
    if (movieLoaded) {
        
        [self setMovie:movieLoaded];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.imageView.image = self.image;
            
            self.lblMovieTitle.text = movieLoaded.title;
            self.lblGenre.text = movieLoaded.genre;
            self.lblYear.text = movieLoaded.year;
            self.lblDirector.text = movieLoaded.director;
            self.lblScore.text = movieLoaded.imdbRaiting;
            self.textViewPlot.text = movieLoaded.plot;

        });
        
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;
{
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    BOOL shouldReceiveTouch = orientation == UIInterfaceOrientationPortrait;
    
    if (shouldReceiveTouch && gestureRecognizer == tap) {
        shouldReceiveTouch = (touch.view == self.imageView);
    }
    return shouldReceiveTouch;
}

-(void)imgToFullScreen {
    
    if (!isFullScreen) {
        
        [UIView animateWithDuration:0.4 delay:0 options:0 animations:^{
            //save previous frame
            prevFrame = self.imageView.frame;
            [self.imageView setFrame:[[UIScreen mainScreen] bounds]];
        } completion:^(BOOL finished){
            isFullScreen = true;
        }];
        
        return;
    } else {
        
        [UIView animateWithDuration:0.4 delay:0 options:0 animations:^{
            [self.imageView setFrame:prevFrame];
        } completion:^(BOOL finished){
            isFullScreen = false;
        }];
        
        return;
    }
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    [newMovie setValue: movie.director forKey: @"director"];
    [newMovie setValue: movie.imdbRaiting forKey: @"imdbRaiting"];
    [newMovie setValue: movie.plot forKey: @"plot"];
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
        movie.director = [matches valueForKey:@"director"];
        movie.imdbRaiting = [matches valueForKey:@"imdbRaiting"];
        movie.plot = [matches valueForKey:@"plot"];
        movie.year = [matches valueForKey:@"year"];
        return  movie;
    }
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

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

@synthesize imdbId, movieTitle;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // update view
    self.imageView.image = self.image;
    self.lblMovieTitle.text = self.movieTitle;
    
    [self loadMovieDetails:self.imdbId withCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        Movie *movie = [self parseData:data];
        
        
        if (movie) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // code here
                
                self.lblGenre.text = movie.genre;
                
            });
            
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)save:(id)sender
{
    NSLog(@"Save...");
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

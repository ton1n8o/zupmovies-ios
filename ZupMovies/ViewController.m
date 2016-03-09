//
//  ViewController.m
//  ZupMovies
//
//  Created by Antonio Carlos Silva on 3/6/16.
//  Copyright © 2016 Antonio Carlos Silva. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

NSMutableData *_responseData;
NSArray *_data;
NSTimer *searchDelayer;
NSString *searchTerm;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search

- (void) search:(NSString*)searchTerm
{

    [self searchMovieWith:searchTerm withCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // parser do json.
        if (error != nil) {
            
            [self showAlertDialogWithMessage:@"Erro ao carregar dados do filme."
                                       title:@"Erro"
                                    okAction:[UIAlertAction actionWithTitle:@"OK"
                                                                      style:UIAlertActionStyleDefault
                                                                    handler:nil]];
            
            NSLog(@"ERRROR:  %@", error);
            
        } else {
            
            _data = [self parseData: data];
            
//            NSLog(@"000000000000000000");
            dispatch_async(dispatch_get_main_queue(), ^{
                // code here
                [self.tableView reloadData];
            });
            
        }
        
        
    }];
    searchDelayer =  nil;
    
}

#pragma mark - Helpers

- (void) showAlertDialogWithMessage:(NSString*)msg title:(NSString*) title okAction:(UIAlertAction*)action
{
    
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>> ");
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
    
    Movie *movie = [_data objectAtIndex:indexPath.row];

//    UIImageView* imgView = (UIImageView*) [cell viewWithTag: 0];
    ((UILabel*) [cell viewWithTag: 2]).text = movie.title;
    ((UILabel*) [cell viewWithTag: 3]).text = movie.director;
    ((UILabel*) [cell viewWithTag: 4]).text = movie.genre;
    ((UILabel*) [cell viewWithTag: 5]).text = movie.year;

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

#pragma mark - UISearchControllerDelegate Delegate Methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self search:searchBar.text];
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

- (void) searchMovieWith:(NSString*)searchTerm withCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler
{
    
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@", SERVER_PATH, @"?s=", searchTerm, @"&page=1"];
    
    NSLog(@"URL: %@", url);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Send a synchronous request
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:20.0];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:handler] resume];
    
}

- (NSArray *) parseData:(NSData *) data
{
    NSMutableArray* movies = [[NSMutableArray alloc] init];
    if (data) {
        NSError *jsonParsingError = nil;
        
        id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        
        if (object) {
            
            NSDictionary *dictData = (NSDictionary*) object;
            
            if (dictData && dictData.count > 0) {
                
                NSArray *arMovies = [dictData objectForKey:@"Search"];
                
                for (NSDictionary *dictMovie in arMovies) {
                    [movies addObject: [Movie parseDictionary:dictMovie]];
                }
                
            }
            
        }
        
    }
    return movies;
}

@end

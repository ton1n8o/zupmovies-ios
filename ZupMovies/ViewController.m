//
//  ViewController.m
//  ZupMovies
//
//  Created by Antonio Carlos Silva on 3/6/16.
//  Copyright © 2016 Antonio Carlos Silva. All rights reserved.
//

#import <KVNProgress/KVNProgress.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "ViewController.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface ViewController ()

@property (nonatomic) Reachability *hostReachability;

@end

@implementation ViewController

@synthesize modalViewController;

#pragma mark - Variables

NSMutableArray *_data;
NSString *searchTerm;
NSInteger page = 0;
NSString *searchTerm;
BOOL isConnected;
BOOL showAlertNoConnetion;

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.hostReachability = [Reachability reachabilityWithHostName:SERVER_PATH_TEST_CONNECTION];
    [self.hostReachability startNotifier];
    
}

- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
   
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
    isConnected = (netStatus != NotReachable);
    
    [self showAlertNoConnection];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showMovieDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        MovieDetailViewController *view = segue.destinationViewController;
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        UIImageView *imageView = [cell viewWithTag:1];
        view.image = imageView.image;
        view.movie = [_data objectAtIndex:indexPath.row];
        
        // referência ao delegate para atualziar a tela quando criar/excluir um filme
        view.delegate = self.moviesViewController;
    }
}

#pragma mark - Helpers

-(void)showAlertNoConnection
{
    if (!isConnected && !showAlertNoConnetion) {
        showAlertNoConnetion = YES;
        
        [self showAlertDialogWithMessage: NSLocalizedString(@"CONNECT_TO_THE_INTERNET", @"Message please connect to the internet.")
                                   title: NSLocalizedString(@"INFO", @"Alert title Information.")
                                okAction: [UIAlertAction actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     showAlertNoConnetion = NO;
                                                                 }]];
    }
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

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

- (void) updateTableView:(NSMutableArray *)movies
{
    _data = movies;
    NSLog(@"Movies: %tu", [_data count]);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

-(void)showProgress:(BOOL)show
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (show) {
            
            KVNProgressConfiguration *configuration = [[KVNProgressConfiguration alloc] init];
            configuration.fullScreen = NO;
            
            [KVNProgress setConfiguration:configuration];
            
            [KVNProgress show];
        } else {
            [KVNProgress dismiss];
        }
    });
}

-(NSString *)buildUrl:(NSString*)search
{
    page++;
    NSString * url = [NSString stringWithFormat:@"%@%@%@%@%@", SERVER_PATH, @"?s=", search, @"&page=", [@(page) stringValue]];
    NSLog(@"URL: %@", url);
    return [url stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
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
    
    ((UILabel*) [cell viewWithTag: 2]).text = movie.title;
    ((UILabel*) [cell viewWithTag: 3]).text = movie.type;
    ((UILabel*) [cell viewWithTag: 4]).text = movie.year;
    
    UIImageView *imgView = (UIImageView*) [cell viewWithTag: 1];
    
    [imgView sd_setImageWithURL:
     [NSURL URLWithString:movie.poster]
               placeholderImage:[UIImage
                                 imageNamed:@"zup_movies.png"]];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    if (maximumOffset - currentOffset <= -40) {
        [self loadNextPage];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // hide keyboard on scroll
    [self.view endEditing:YES];
}

#pragma mark - UISearchControllerDelegate Delegate Methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    if (!isConnected) {
        [self showAlertNoConnection];
        return;
    }
    
    [self search:searchBar.text];
    
    // remove focus
    [searchBar resignFirstResponder];
}

#pragma mark - Search

- (void) requestWithTerm:(NSString*)url withCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Send a synchronous request
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:TIME_OUT];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:handler] resume];
    
}

- (NSMutableArray *) parseData:(NSData *) data
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

- (void) search:(NSString*)search
{
    
    [self showProgress:YES];
    
    page = 0; // first page
    searchTerm = search; // new search term used.
    
    [self requestWithTerm:[self buildUrl:search] withCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        [self showProgress:NO];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // parser do json.
        if (error != nil) {
            
            NSLog(@"Can't load movie data! %@ %@", error, [error localizedDescription]);
            
            NSString *msg = NSLocalizedString(@"MESSAGE_ERROR_LOADING_MOVIES", @"Error while loading movie data.");
            if (error.code == NSURLErrorTimedOut) {
                msg = NSLocalizedString(@"MESSAGE_ERROR_SEVER_TIMED_OUT", @"Could not connect to server.");
            }
            
            [self showAlertDialogWithMessage:msg
                                       title:NSLocalizedString(@"ERROR", @"Error title.")
                                    okAction:[UIAlertAction actionWithTitle:@"OK"
                                                                      style:UIAlertActionStyleDefault
                                                                    handler:nil]];
        } else {
            NSMutableArray *movies = [self parseData: data];
            if (movies == nil || movies.count == 0) {
                [self showAlertDialogWithMessage: NSLocalizedString(@"MESSAGE_NO_MOVIES_FOULD_FOR_SEARCH", @"No movie found.")
                                           title: nil
                                        okAction: [UIAlertAction actionWithTitle:@"OK"
                                                                          style:UIAlertActionStyleDefault
                                                                        handler:nil]];
            }
            [self updateTableView:movies];
        }
        
    }];
    
}

- (void) loadNextPage
{
    
    if (!isConnected) {
        [self showAlertNoConnection];
        return;
    }
    
    [self showProgress:YES];
    
    NSString *url = [self buildUrl:searchTerm];
    
    [self requestWithTerm:url withCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // parser do json.
        if (error != nil) {
            
            NSLog(@"Can't load next page! %@ %@, url:%@", error, [error localizedDescription], url);
            
            NSString *msg = @"Erro ao pesquisar filmes.";
            if (error.code == NSURLErrorTimedOut) {
                msg = NSLocalizedString(@"MESSAGE_ERROR_SEVER_TIMED_OUT", @"Could not connect to server.");
            }
            
            [self showAlertDialogWithMessage:msg
                                       title:NSLocalizedString(@"ERROR", @"Error title.")
                                    okAction:[UIAlertAction actionWithTitle:@"OK"
                                                                      style:UIAlertActionStyleDefault
                                                                    handler:nil]];
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSMutableArray *movies = [self parseData: data];
                
                if (movies && movies.count > 0) {
                    
                    [self.tableView beginUpdates];
                    
                    NSInteger startingRow =  _data.count;
                    NSInteger scollToIndex = startingRow; //index to scroll
                    
                    [_data addObjectsFromArray:movies];
                    NSInteger endingRow = _data.count; // last row
                    
                    NSMutableArray *indexPaths = [NSMutableArray array];
                    
                    for (; startingRow < endingRow; startingRow++) {
                        [indexPaths addObject:[NSIndexPath indexPathForRow:startingRow inSection: 0]];
                    }
                    
                    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation: UITableViewRowAnimationFade];
                    
                    [self.tableView endUpdates];
                    
                    [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: scollToIndex-1 inSection:0]
                                          atScrollPosition: UITableViewScrollPositionTop animated:YES];
                    
                } else {
                    // no more movies
                    [self showAlertDialogWithMessage:NSLocalizedString(@"MESSAGE_NO_MORE_MOVIES", @"No more movies.")
                                               title:NSLocalizedString(@"INFO", @"Alert title Information.")
                                            okAction:[UIAlertAction actionWithTitle:@"OK"
                                                                              style:UIAlertActionStyleDefault
                                                                            handler:nil]];
                }
                
            });
        }
        
        [self showProgress:NO];
        
    }];
    
}

@end

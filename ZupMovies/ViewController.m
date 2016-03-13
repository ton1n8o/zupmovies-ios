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

@end

@implementation ViewController

@synthesize modalViewController;

//NSMutableData *_responseData;
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

- (void) updateTableView:(NSArray *)movies
{
    _data = movies;
    NSLog(@"Movies: %tu", [_data count]);
    dispatch_async(dispatch_get_main_queue(), ^{
        // code here
        [self.tableView reloadData];
    });
}

-(void)showProgress:(BOOL)show
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (show) {
            [KVNProgress show];
        } else {
            [KVNProgress dismiss];
        }
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
    
    ((UILabel*) [cell viewWithTag: 2]).text = movie.title;
    ((UILabel*) [cell viewWithTag: 3]).text = movie.director;
    ((UILabel*) [cell viewWithTag: 4]).text = movie.genre;
    ((UILabel*) [cell viewWithTag: 5]).text = movie.year;
    
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

#pragma mark - UISearchControllerDelegate Delegate Methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self search:searchBar.text];
    
    // remove focus
    [searchBar resignFirstResponder];
}

#pragma mark - Search

- (void) requestWithTerm:(NSString*)searchTerm withCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error)) handler
{
    
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@", SERVER_PATH, @"?s=", searchTerm, @"&page=1"];
    
    NSLog(@"URL: %@", url);
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Send a synchronous request
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:TIME_OUT];
    
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

- (void) search:(NSString*)searchTerm
{
    
    [self showProgress:YES];
    
    [self requestWithTerm:searchTerm withCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        [self showProgress:NO];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // parser do json.
        if (error != nil) {
            
            NSLog(@"Can't load movie data! %@ %@", error, [error localizedDescription]);
            
            NSString *msg = @"Erro ao carregar dados do filme.";
            if (error.code == NSURLErrorTimedOut) {
                msg = @"Erro ao carregar dados do filme, server não está respondendo.";
            }
            
            [self showAlertDialogWithMessage:msg
                                       title:@"Erro"
                                    okAction:[UIAlertAction actionWithTitle:@"OK"
                                                                      style:UIAlertActionStyleDefault
                                                                    handler:nil]];
        } else {
            [self updateTableView:[self parseData: data]];
        }
        
    }];
    searchDelayer =  nil;
    
}

@end

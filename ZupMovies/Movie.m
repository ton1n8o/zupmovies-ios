//
//  Movie.m
//  ZupMovies
//
//  Created by Antonio Carlos Silva on 3/6/16.
//  Copyright © 2016 Antonio Carlos Silva. All rights reserved.
//

#import "Movie.h"

@implementation Movie

@synthesize title, actors, genre, imdbRaiting, year;

- (id) init
{
    self = [super init];
    if (self) {
        self.title = nil;
        self.actors = nil;
        self.imdbRaiting = nil;
        self.year = nil;
    }
    return self;
}

- (id) initWithTitle:(NSString*)_title actors:(NSString*)_actors imdbScore:(NSString*)_imdbRaiting year:(NSString*)_year
{
    self = [super init];
    if (self) {
        self.title = _title;
        self.actors =_actors;
        self.imdbRaiting = _imdbRaiting;
        self.year = _year;
    }
    return self;
}

+ (Movie*) parseDictionary:(NSDictionary *) dict
{
    Movie *m = [Movie init];
    [m setTitle: dict[@"Title"]];
    [m setTitle: dict[@"Actors"]];
    [m setTitle: dict[@"Genre"]];
    [m setTitle: dict[@"imdbRating"]];
    
    return m;
}

@end

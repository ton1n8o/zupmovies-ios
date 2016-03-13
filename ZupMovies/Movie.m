//
//  Movie.m
//  ZupMovies
//
//  Created by Antonio Carlos Silva on 3/6/16.
//  Copyright © 2016 Antonio Carlos Silva. All rights reserved.
//

#import "Movie.h"

@implementation Movie

@synthesize title, actors, genre,
imdbRaiting, year, plot, director, poster, type, imdbID, image;

- (id) init
{
    self = [super init];
    if (self) {
        self.title = nil;
        self.actors = nil;
        self.year = nil;
        self.plot = nil;
        self.genre = nil;
        self.imdbRaiting = nil;
        self.director = nil;
        self.poster = nil;
        self.type = nil;
        self.imdbID = nil;
        self.image = nil;
    }
    return self;
}

- (id) initWithTitle:(NSString*) _title
              actors:(NSString*) _actors
                year:(NSString*) _year
                year:(NSString*) _plot
                year:(NSString*) _genre
           imdbScore:(NSString*) _imdbRaiting
                year:(NSString*) _director
              poster:(NSString*) _poster
                type:(NSString*) _type
              imdbID:(NSString*) _imdbID
{
    self = [super init];
    if (self) {
        self.title = _title;
        self.actors = _actors;
        self.year = _year;
        self.plot = _plot;
        self.genre = _genre;
        self.imdbRaiting = _imdbRaiting;
        self.director = _director;
        self.poster = _poster;
        self.type = _type;
        self.imdbID = _imdbID;
    }
    return self;
}

+ (Movie*) parseDictionary:(NSDictionary *) dict
{
    Movie *m = [[Movie alloc] init];
    
    NSString *NA = @"N/A";
    NSString *value = @"";
    
    [m setTitle: dict[@"Title"]];
    [m setActors: dict[@"Actors"]];
    
    value = dict[@"Year"];
    [m setYear:[value isEqualToString:NA] ? @"" : value];

    value = dict[@"Plot"];
    [m setPlot: [value isEqualToString:NA] ? @"" : value];
    
    value = dict[@"Genre"];
    [m setGenre: [value isEqualToString:NA] ? @"" : value];
    
    value = dict[@"imdbRating"];
    [m setImdbRaiting: [value isEqualToString:NA] ? @"" : value];
    
    value = dict[@"Director"];
    [m setDirector: [value isEqualToString:NA] ? @"" : value];
    
    value = dict[@"Type"];
    [m setType: [value isEqualToString:NA] ? @"" : value];
    
    [m setImdbID:dict[@"imdbID"]];
    [m setPoster: dict[@"Poster"]];
    
    return m;
}

@end

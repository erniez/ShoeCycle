//
//  StravaActivity.h
//  ShoeCycle
//
//  Created by El Guapo on 5/9/15.
//
//

#import <Foundation/Foundation.h>

@interface StravaActivity : NSObject

- (instancetype)initWithName:(NSString *)name distance:(NSNumber *)distance startDate:(NSDate *)startDate;

@property (nonatomic) NSString *name;
@property (nonatomic, readonly) NSString *type; // always "run"
@property (nonatomic) NSNumber *distance; // in meters
@property (nonatomic, readonly) NSNumber *elapsed_time; // always 0;
@property (nonatomic) NSDate *startDate;
@property (nonatomic, readonly) NSString *start_date_local;

@end

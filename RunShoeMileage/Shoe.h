//
//  Shoe.h
//  RunShoeMileage
//
//  Created by Ernie on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class History;

@interface Shoe : NSManagedObject

@property (nonatomic, retain) NSString * brand;
@property (nonatomic, retain) NSDate * expirationDate;
@property (nonatomic, retain) NSString * imageKey;
@property (nonatomic, retain) NSNumber * maxDistance;
@property (nonatomic, retain) NSNumber * orderingValue;
@property (nonatomic, retain) NSNumber * startDistance;
@property (nonatomic, retain) UIImage * thumbnail;
@property (nonatomic, retain) NSData * thumbnailData;
@property (nonatomic, retain) NSNumber * totalDistance;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSSet *history;
@end

@interface Shoe (CoreDataGeneratedAccessors)

- (void)addHistoryObject:(History *)value;
- (void)removeHistoryObject:(History *)value;
- (void)addHistory:(NSSet *)values;
- (void)removeHistory:(NSSet *)values;

- (void)setThumbnailDataFromImage:(UIImage *)image width:(int)w height:(int)h;
+ (CGSize)thumbnailSizeFromWidth:(int)w height:(int)h;

@end

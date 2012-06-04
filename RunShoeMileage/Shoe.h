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

@property (nonatomic, strong) NSString * brand;
@property (nonatomic, strong) NSDate * expirationDate;
@property (nonatomic, strong) NSString * imageKey;
@property (nonatomic, strong) NSNumber * maxDistance;
@property (nonatomic, strong) NSNumber * orderingValue;
@property (nonatomic, strong) NSNumber * startDistance;
@property (nonatomic, strong) UIImage * thumbnail;
@property (nonatomic, strong) NSData * thumbnailData;
@property (nonatomic, strong) NSNumber * totalDistance;
@property (nonatomic, strong) NSDate * startDate;
@property (nonatomic, strong) NSSet *history;
@end

@interface Shoe (CoreDataGeneratedAccessors)

- (void)addHistoryObject:(History *)value;
- (void)removeHistoryObject:(History *)value;
- (void)addHistory:(NSSet *)values;
- (void)removeHistory:(NSSet *)values;

- (void)setThumbnailDataFromImage:(UIImage *)image width:(int)w height:(int)h;
+ (CGSize)thumbnailSizeFromWidth:(int)w height:(int)h;

@end

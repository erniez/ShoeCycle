//
//  StravaAPIManager.h
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/8/15.
//
//

#import <Foundation/Foundation.h>
@class StravaActivity;

@interface StravaAPIManager : NSObject

- (void)sendActivityToStrava:(StravaActivity *)activity completion:(void(^)(NSError *error))completion;
- (void)fetchAthlete;

@end

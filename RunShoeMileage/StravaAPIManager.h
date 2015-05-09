//
//  StravaAPIManager.h
//  ShoeCycle
//
//  Created by Bob Bitchin on 5/8/15.
//
//

#import <Foundation/Foundation.h>

@interface StravaAPIManager : NSObject

- (void)sendActivityToStrava;
- (void)fetchAthlete;

@end

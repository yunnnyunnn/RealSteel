//
//  AppDelegate.h
//  RealSteel
//
//  Created by Tim Chen on 11/12/19.
//  Copyright NCCU 2011年. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameSession.h"

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end

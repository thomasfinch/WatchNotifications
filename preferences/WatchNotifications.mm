#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>

@interface WatchNotificationsListController: PSListController {
}
@end

@implementation WatchNotificationsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"WatchNotifications" target:self] retain];
	}
	return _specifiers;
}

- (void)sendTestNotification {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.thomasfinch.watchnotifications-testnotification"), nil, nil, true);
}

- (void)GithubButtonTapped {
    NSURL *githubURL = [NSURL URLWithString:@"https://github.com/thomasfinch/Priority-Hub"];
    [[UIApplication sharedApplication] openURL:githubURL];
}

- (void)TFTwitterButtonTapped {
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *tweetbot = [NSURL URLWithString:@"tweetbot:///user_profile/tomf64"];
    if ([app canOpenURL:tweetbot])
        [app openURL:tweetbot];
    else {
        NSURL *twitterapp = [NSURL URLWithString:@"twitter:///user?screen_name=tomf64"];
        if ([app canOpenURL:twitterapp])
            [app openURL:twitterapp];
        else {
            NSURL *twitterweb = [NSURL URLWithString:@"http://twitter.com/tomf64"];
            [app openURL:twitterweb];
        }
    }
}

@end

// vim:ft=objc

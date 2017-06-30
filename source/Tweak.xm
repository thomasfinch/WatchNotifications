#import <UIKit/UIKit.h>
#import "substrate.h"
#import <objc/runtime.h>
#import "Headers.h"
#import "colorbadges_api.h"
#import "HBPreferences.h"
#import "WNContainerView.h"

const CGFloat CELL_SIDE_PADDING = 5.0;

NSUserDefaults *defaults;
BBServer *bbServer;

void showTestNotification() {
	[[%c(SBLockScreenManager) sharedInstance] lockUIFromSource:1 withOptions:nil];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.7 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		BBBulletin *bulletin = [[%c(BBBulletin) alloc] init];
		bulletin.title = @"WatchNotifications";
		bulletin.sectionID = @"com.apple.MobileSMS";
		bulletin.message = @"This is a test notification. How are you doing?";
		bulletin.bulletinID = @"WatchNotificationsTest";
		bulletin.clearable = YES;
		bulletin.showsMessagePreview = YES;
		bulletin.defaultAction = [%c(BBAction) action];
		bulletin.date = [NSDate date];

		if (bbServer)
			[bbServer publishBulletin:bulletin destinations:4 alwaysToLockScreen:YES];
	});
}

const CGFloat iconSize() {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		if ([defaults boolForKey:@"smallIcon"] || [defaults boolForKey:@"ios10style"])
			return 20;
		else
			return 32;
	else
		if ([defaults boolForKey:@"smallIcon"] || [defaults boolForKey:@"ios10style"])
			return 20;
		else
			return 30;
}

NSString* identifierForListItem(SBAwayListItem *listItem) {
	if ([listItem isKindOfClass:%c(SBSnoozedAlarmListItem)] || [listItem isKindOfClass:%c(SBSnoozedAlarmBulletinListItem)])
		return @"com.apple.mobiletimer";
	else if ([listItem isKindOfClass:%c(SBAwayBulletinListItem)])
		return [[(SBAwayBulletinListItem*)listItem activeBulletin] sectionID];
	else if ([listItem isKindOfClass:%c(SBAwayCardListItem)])
		return [[(SBAwayCardListItem*)listItem cardItem] identifier];
	else if ([listItem isKindOfClass:%c(SBAwaySystemAlertItem)])
		return @"systemAlert";
	else
		return @"noIdentifier";
}

UIImage* iconForListItem(SBAwayListItem *listItem) {
	if ([listItem isKindOfClass:%c(SBAwayBulletinListItem)] || [listItem isKindOfClass:%c(SBSnoozedAlarmBulletinListItem)] || [listItem isKindOfClass:%c(SBSnoozedAlarmListItem)]) {
		NSString *bundleID;
		if ([listItem isKindOfClass:%c(SBAwayBulletinListItem)])
			bundleID = [(BBBulletin*)[(SBAwayBulletinListItem*)listItem activeBulletin] sectionID];
		else
			bundleID = @"com.apple.mobiletimer";
		int iconImageNumber = (iconSize() > 29) ? 1 : 0;
		SBApplication *app = nil;

		if ([[%c(SBApplicationController) sharedInstance] respondsToSelector:@selector(applicationWithBundleIdentifier:)])
			app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleID];
		else if ([[%c(SBApplicationController) sharedInstance] respondsToSelector:@selector(applicationWithDisplayIdentifier:)])
			app = [[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:bundleID];

		return [[[%c(SBApplicationIcon) alloc] initWithApplication:app] generateIconImage:iconImageNumber]; //0 = 29x29, 1 = 40x40, 2 = 60x60
	}
	else if ([listItem isKindOfClass:%c(SBAwayCardListItem)])
		return [[UIImage alloc] initWithData:[((SBAwayCardListItem*)listItem).cardItem iconData] scale:[[UIScreen mainScreen] scale]];
	else
		return nil;
}

// UIImage* iconForListItem(SBAwayListItem* listItem) {
// 	UIImage *icon = nil;

// 	NSLog(@"GETTING ICON FOR LIST ITEM: %@", listItem);
// 	NSLog(@"IDENTIFIER: %@", identifierForListItem(listItem));

// 	if ([listItem isKindOfClass:%c(SBSnoozedAlarmListItem)] || [listItem isKindOfClass:%c(SBSnoozedAlarmBulletinListItem)] || [listItem isKindOfClass:%c(SBAwayBulletinListItem)])
// 		icon = [UIImage _applicationIconImageForBundleIdentifier:identifierForListItem(listItem) format:2 scale:[UIScreen mainScreen].scale];
// 	else if ([listItem respondsToSelector:@selector(iconImage)])
// 		icon = [listItem iconImage];
// 	else
// 		icon = [[UIImage alloc] init]; //Handle the case where somehow an icon still hasn't been found yet

// 	NSLog(@"ICON: %@", icon);

// 	return icon;
// }

%ctor {
	defaults = [[NSUserDefaults alloc] initWithSuiteName:@"me.thomasfinch.watchnotifications"];
	[defaults registerDefaults:@{
        @"enabled": @YES,
        @"shadows": @YES,
        @"lines": @YES,
        @"actionButton": @YES,
        @"smallIcon": @NO,
        @"circularIcon": @NO,
        @"ios10style": @NO
    }];

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)showTestNotification, CFSTR("me.thomasfinch.watchnotifications-testnotification"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

    dlopen("/Library/MobileSubstrate/DynamicLibraries/ColorBanners.dylib", RTLD_NOW);
}

%hook SBLockScreenNotificationListController

	- (void)updateForRemovalOfItems {
		%orig;
		[self _sortItemList:MSHookIvar<NSMutableArray*>(self, "_listItems")];
	}

	- (void)updateForRemovalOfItemAtIndex:(unsigned long long)arg1 removedItem:(id)arg2 {
		%orig;
		[self _sortItemList:MSHookIvar<NSMutableArray*>(self, "_listItems")];
	}

	- (void)_sortItemList:(NSMutableArray*)itemList {
		//Copy all list items from the current list items and put them into an NSDictionary of NSArrays (key is appID, value is NSArray of list items)
		NSMutableDictionary *listItemsDict = [[NSMutableDictionary alloc] init];
		for (SBAwayListItem* listItem in itemList) {
			NSString *identifier = identifierForListItem(listItem);

			if (![listItemsDict objectForKey:identifier]) {
				NSMutableArray *listItemsArr = [[NSMutableArray alloc] init];
				[listItemsDict setObject:listItemsArr forKey:identifier];
			}

			[(NSMutableArray*)[listItemsDict objectForKey:identifier] addObject:listItem];
		}

		//Sort each array of list items by date (SBAwayListItem timestamp property)
		for (NSMutableArray *listItemsArr in [listItemsDict allValues]) {
			NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
			listItemsArr = (NSMutableArray*)[listItemsArr sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		}

		//Put all list items back into listItems in order of their most recent notification
	}

%end

%hook SBLockScreenNotificationListView

	- (id)initWithFrame:(CGRect)frame {
		if (![defaults boolForKey:@"enabled"]) {
			return %orig;
		}

		self = %orig;

		//Remove cell separators
		UIView *containerView = MSHookIvar<UIView*>(self, "_containerView");
		UITableView *notificationsTableView = MSHookIvar<UITableView*>(self, "_tableView");
		UIView *topSeparator = ((UIView*)[containerView subviews][1]), *bottomSeparator = ((UIView*)[containerView subviews][2]);
		topSeparator.hidden = YES;
		bottomSeparator.hidden = YES;
		notificationsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

		return self;
	}

	- (void)_setContentForTableCell:(SBNotificationCell*)cell withItem:(SBAwayListItem*)listItem atIndexPath:(NSIndexPath*)indexPath {
		%orig;

		if ([defaults boolForKey:@"enabled"]) {
			UIImage *listItemImage = iconForListItem(listItem);
			if (listItemImage) {
				cell.icon = listItemImage;
				cell.iconView.image = listItemImage;
			}

			//Copic compatibility should go here
		}
	}

	- (double)tableView:(id)arg1 heightForRowAtIndexPath:(NSIndexPath*)arg2 {

		if (![defaults boolForKey:@"enabled"])
			return %orig;

		if (arg2.row == 0) {
			return %orig * 1.1;
		}
		else {
			return %orig * 1.3;
		}
	}

%end

%hook SBLockScreenNotificationCell

	- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 {
		if (![defaults boolForKey:@"enabled"]) {
			return %orig;
		}

		self = %orig;

		WNContainerView *containerView = [[WNContainerView alloc] init];
		[self.realContentView addSubview:containerView];
		objc_setAssociatedObject(self, "containerView", containerView, OBJC_ASSOCIATION_ASSIGN);

		return self;
	}

	- (void)layoutSubviews {
		%orig;

		if (![defaults boolForKey:@"enabled"]) {
			return;
		}

		WNContainerView *containerView = objc_getAssociatedObject(self, "containerView");
		if (!containerView) {
			return;
		}

		containerView.frame = CGRectInset(self.bounds, 2 * CELL_SIDE_PADDING, 0);

		containerView.iconView = self.iconView;
		containerView.appNameLabel = self.primaryLabel; //Need to change this to account for Messages notifications
		// containerView.messageTitleLabel = self.primaryLabel //Temporary
		containerView.timeLabel = self.relevanceDateLabel;
		containerView.contentLabel = self.secondaryLabel;
		if (self.subtitleLabel) {
			containerView.subtitleLabel = self.subtitleLabel;
		}
		if (self.attachmentView) {
			containerView.attachmentView = self.attachmentView;
		}

		[containerView updateViews];

		// //DathBanners support
		// if (self.contentView.backgroundColor != nil && self.contentView.backgroundColor != [UIColor clearColor]) {
		// 	objc_setAssociatedObject(self, "colorizedColor", self.contentView.backgroundColor, OBJC_ASSOCIATION_COPY);
		// 	self.contentView.backgroundColor = [UIColor clearColor];
		// }

		//FlagPaint support
		// if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/FlagPaint7.dylib"]) {
		// 	HBPreferences *preferences = [[%c(HBPreferences) alloc] initWithIdentifier:@"ws.hbang.flagpaint"];
		// 	if (preferences && [preferences boolForKey:@"TintLockScreen"]) {
		// 		objc_setAssociatedObject(self, "colorizedColor", ((UIView*)[self.realContentView subviews][0]).backgroundColor, OBJC_ASSOCIATION_COPY);
		// 		((UIView*)[self.realContentView subviews][0]).hidden = YES;
		// 	}
		// 	[preferences release];
		// }

		//Slide to view label
		MSHookIvar<UILabel*>(self, "_unlockTextLabel").hidden = YES;
	}

	//ColorBanners support
	- (void)colorizeBackground:(int)color {
		if ([defaults boolForKey:@"enabled"]) {
			CBRPrefsManager *prefsManager = [%c(CBRPrefsManager) sharedInstance];
			UIColor *uiColor = [UIColor colorWithRed:GETRED(color)/255.0 green:GETGREEN(color)/255.0 blue:GETBLUE(color)/255.0 alpha:prefsManager.lsAlpha];
			objc_setAssociatedObject(self, "colorizedColor", uiColor, OBJC_ASSOCIATION_COPY);
		}
		else
			%orig;
	}

	- (void)dealloc {
		if ([defaults boolForKey:@"enabled"]) {
			[objc_getAssociatedObject(self, "containerView") release];
		}

		%orig;
	}

%end

//Fixes layout bug with snoozed alarms
%hook SBLockScreenSnoozedAlarmCell

	%new
	- (void)layoutSnoozeLabel {
		//Snoozed alarm "time remaining" label
		UIView *titleView = objc_getAssociatedObject(self, "titleView");
		UILabel *snoozeLabel = MSHookIvar<UILabel*>(self, "_countdownLabel");

		snoozeLabel.textAlignment = NSTextAlignmentRight;
		snoozeLabel.frame = CGRectInset(CGRectMake(0, 0, titleView.bounds.size.width, titleView.bounds.size.height), 5, 0);
		[titleView addSubview:snoozeLabel];
	}

	- (void)layoutSubviews {
		%orig;
		[self layoutSnoozeLabel];
	}

	- (void)dateLabelDidChange:(id)arg1 {
		%orig;
		[self layoutSnoozeLabel];
	}

%end

//Removes lines above and below the clear button
%hook SBTableViewCellDismissActionButton

	- (void)layoutSubviews {
		if ([defaults boolForKey:@"enabled"] && [defaults boolForKey:@"lines"]) {
			self.drawsBottomSeparator = NO;
		    self.drawsTopSeparator = NO;
		}
	    %orig;
	}

%end

//Removes the "reply" button background color
%hook SBTableViewCellActionButton

	- (void)layoutSubviews {
		%orig;
		if ([defaults boolForKey:@"enabled"] && [defaults boolForKey:@"actionButton"]) {
			MSHookIvar<UIView*>(self, "_backgroundView").hidden = YES;
			self.backgroundColor = [UIColor clearColor];
		}
	}

%end

//Used for sending the test notification
%hook BBServer

	- (id)init {
		bbServer = %orig;
		return bbServer;
	}

%end


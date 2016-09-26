#include <UIKit/UIKit.h>

@interface SBLockScreenNotificationListController : NSObject
- (void)_sortItemList:(NSMutableArray*)itemList;
@end

@interface SBNotificationCell : UITableViewCell
@property(readonly, nonatomic) UIView *attachmentView; // @synthesize attachmentView=_attachmentView;
@property(retain, nonatomic) UIButton *actionButton; // @synthesize actionButton=_actionButton;
@property(readonly, nonatomic) UIImageView *iconView; // @synthesize iconView=_iconImageView;
@property(readonly, nonatomic) UILabel *secondaryLabel; // @synthesize secondaryLabel=_secondaryLabel;
@property(readonly, nonatomic) UILabel *subtitleLabel; // @synthesize subtitleLabel=_subtitleLabel;
@property(readonly, nonatomic) UILabel *primaryLabel; // @synthesize primaryLabel=_primaryLabel;
@property(readonly, nonatomic) UIView *realContentView; // @synthesize realContentView=_realContentView;
@property(retain, nonatomic) UILabel *eventDateLabel;
@property(retain, nonatomic) UILabel *relevanceDateLabel;
@property(readonly, nonatomic) CGRect contentBounds;
@property(nonatomic) double secondaryTextHeight;
@property(copy, nonatomic) NSString *subtitleText;
@property(retain, nonatomic) UIImage *icon;
+ (double)paddingBetweenTitleAndRelevanceDate;
@end

@interface SBLockScreenNotificationCell : SBNotificationCell
@property(nonatomic) double contentScrollViewWidth;
@property(readonly, nonatomic) UIScrollView *contentScrollView;
- (void)colorize:(UIColor*)color;
- (CGFloat)subtitleMultiplier;
- (CGFloat)containerViewHeight;
- (CGFloat)titleViewHeight;
@end

@interface SBTableViewCellDismissActionButton
@property(assign, nonatomic) BOOL drawsBottomSeparator;
@property(assign, nonatomic) BOOL drawsTopSeparator;
@end

@interface SBTableViewCellActionButton : UIView {
	UIView* _backgroundView;
}
@end

@interface SBLockScreenManager
+(id)sharedInstance;
- (void)_lockUI;
- (void)lockUIFromSource:(int)arg1 withOptions:(id)arg2;
- (void)_setUILocked:(_Bool)arg1;
@end

@interface SBLockScreenBulletinCell : SBLockScreenNotificationCell
- (CGFloat)subtitleMultiplier;
- (CGFloat)containerViewHeight;
- (CGFloat)titleViewHeight;
@end

@interface BBAction
+ (BBAction*)action;
@end

@interface BBBulletin
@property(copy, nonatomic) NSString *sectionID; // @dynamic sectionID;
@property(copy, nonatomic) NSString *title; // @dynamic title;
@property(copy, nonatomic) NSString *message; // @dynamic title;
@property(copy, nonatomic) BBAction *defaultAction; // @dynamic defaultAction;
@property(retain, nonatomic) NSDate *date;
@property(copy, nonatomic) NSString *bulletinID;
@property(retain, nonatomic) NSDate *publicationDate;
@property(retain, nonatomic) NSDate *lastInterruptDate;
@property(nonatomic) BOOL showsMessagePreview;
@property(nonatomic) BOOL clearable;
@end

@interface SBSCardItem : NSObject
@property(copy, nonatomic) NSData *iconData;
- (NSString*)identifier;
@end

@interface BBServer : NSObject
- (void)publishBulletin:(BBBulletin*)bulletin destinations:(int)dests alwaysToLockScreen:(BOOL)lock;
@end

@interface SBAwayListItem : NSObject
@end

@interface SBAwaySystemAlertItem : SBAwayListItem
-(UIImage*)iconImage;
@end

@interface SBAwayBulletinListItem : SBAwayListItem
-(BBBulletin*)activeBulletin;
-(id)iconImage;
@end

@interface SBAwayCardListItem : SBAwayListItem
@property(copy, nonatomic) SBSCardItem* cardItem;
@property(retain, nonatomic) UIImage *cardThumbnail;
-(UIImage*)iconImage;
@end

@interface UIImage (Private)
+ (id)_applicationIconImageForBundleIdentifier:(id)arg1 format:(int)arg2 scale:(float)arg3;
+ (id)_applicationIconImageForBundleIdentifier:(id)arg1 format:(int)arg2;
@end

@interface SBApplication : NSObject
@end

@interface SBApplicationController: NSObject
+ (SBApplicationController*)sharedInstance;
- (SBApplication*)applicationWithBundleIdentifier:(NSString*)id;
- (SBApplication*)applicationWithDisplayIdentifier:(NSString*)id;
@end

@interface SBApplicationIcon : NSObject
- (SBApplicationIcon*)initWithApplication:(SBApplication*)app;
- (UIImage*)generateIconImage:(int)image;
@end


@interface CBRColorCache : NSObject
+ (CBRColorCache*)sharedInstance;
- (int)colorForIdentifier:(NSString *)identifier image:(UIImage *)image;
@end

@interface CBRPrefsManager : NSObject {

}

@property(nonatomic, assign, getter=areBannersEnabled) BOOL bannersEnabled;
@property(nonatomic, assign, getter=isLSEnabled) BOOL lsEnabled;
@property(nonatomic, assign, getter=isNCEnabled) BOOL ncEnabled;

@property(nonatomic, assign, getter=shouldUseBannerGradient) BOOL useBannerGradient;
@property(nonatomic, assign, getter=shouldUseLSGradient) BOOL useLSGradient;
@property(nonatomic, assign, getter=shouldUseNCGradient) BOOL useNCGradient;

@property(nonatomic, assign, getter=shouldBannersUseConstantColor) BOOL bannersUseConstantColor;
@property(nonatomic, assign, getter=shouldLSUseConstantColor) BOOL lsUseConstantColor;
@property(nonatomic, assign, getter=shouldNCUseConstantColor) BOOL ncUseConstantColor;

@property(nonatomic, assign) int bannerBackgroundColor;
@property(nonatomic, assign) int lsBackgroundColor;
@property(nonatomic, assign) int ncBackgroundColor;

@property(nonatomic, assign) CGFloat bannerAlpha;
@property(nonatomic, assign) CGFloat lsAlpha;
@property(nonatomic, assign) CGFloat ncAlpha;

@property(nonatomic, assign, getter=shouldRemoveLSBlur) BOOL removeLSBlur;
@property(nonatomic, assign, getter=shouldShowSeparators) BOOL showSeparators;
@property(nonatomic, assign, getter=shouldDisableDimming) BOOL disableDimming;
@property(nonatomic, assign) BOOL prefersWhiteText;

@property(nonatomic, assign) BOOL wantsDeepBannerAnalyzing;
@property(nonatomic, assign) BOOL wantsLiveAnalysis;

@property(nonatomic, assign, getter=shouldRoundCorners) BOOL roundCorners;
@property(nonatomic, assign, getter=shouldRemoveBannersBlur) BOOL removeBannersBlur;
@property(nonatomic, assign, getter=shouldHideQRRect) BOOL hideQRRect;
@property(nonatomic, assign, getter=shouldHideGrabber) BOOL hideGrabber;

+ (instancetype)sharedInstance;

- (void)reload;

@end

@interface SBLockScreenSnoozedAlarmCell : SBLockScreenBulletinCell {
    UILabel *_countdownLabel;
}
- (void)layoutSnoozeLabel;
@end


@interface SBSnoozedAlarmListItem : SBAwayListItem
@property(readonly, retain, nonatomic) UIImage *iconImage;
@end

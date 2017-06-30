#import "Headers.h"

extern NSUserDefaults *defaults;
extern const CGFloat iconSize();

@interface WNContainerView : UIView {
	UIView *notificationContainerView;
	UIView *titleView;
	UIView *contentView;
}

@property (nonatomic, copy) UIColor *backgroundColor;
@property (nonatomic, assign) UIImageView *iconView;
@property (nonatomic, assign) UILabel *appNameLabel;
@property (nonatomic, assign) UILabel *contentLabel;
@property (nonatomic, assign) UILabel *timeLabel;

//Below are only for messages
@property (nonatomic, assign) UILabel *messageTitleLabel;
@property (nonatomic, assign) UILabel *subtitleLabel;
@property (nonatomic, assign) UIView *attachmentView;

- (id)init;
- (void)updateViews;

@end
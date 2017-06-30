#import "WNContainerView.h"

const CGFloat TEXT_PADDING = 10;
const CGFloat MESSAGE_TITLE_HEIGHT = 20;

#define TITLE_VIEW_HEIGHT ([defaults boolForKey:@"ios10style"] ? 30 : 25)

@implementation WNContainerView

- (id)init {
	if (self = [super initWithFrame:CGRectZero]) {
		notificationContainerView = [[UIView alloc] init];
		titleView = [[UIView alloc] init];
		contentView = [[UIView alloc] init];
		[self addSubview:notificationContainerView];
		[notificationContainerView addSubview:titleView];
		[notificationContainerView addSubview:contentView];

		//Title and content view background colors
		if ([defaults boolForKey:@"ios10style"]) {
			titleView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
			contentView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
		}
		else {
			titleView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.7];
			contentView.backgroundColor = [UIColor colorWithWhite:0.45 alpha:0.4];
		}
	}
	return self;
}

- (void)setBackgroundColor:(UIColor*)bgColor {
	_backgroundColor = bgColor;
	contentView.backgroundColor = bgColor;
}

- (CGSize)iconPadding {
	if ([defaults boolForKey:@"ios10style"] || [defaults boolForKey:@"smallIcon"])
		return CGSizeMake(8, 6);
	else
		return CGSizeMake(7, 5);
}

- (BOOL)readyToUpdateViews {
	//Frame
	if (CGRectEqualToRect(self.frame, CGRectZero))
		return false;

	//Title label, relative time label, content label
	if (!self.timeLabel || !self.contentLabel)
		return false;

	//Icon view
	if (!self.iconView || !self.appNameLabel)
		return false;

	return true;
}

- (void)updateViews {
	if (![self readyToUpdateViews]) {
		return;
	}

	//Notification container view frame
	CGFloat containerViewOffset = [self iconPadding].height * 3;
	notificationContainerView.frame = CGRectMake(0, containerViewOffset, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - containerViewOffset);

	//Title and content view frames
	CGRect titleViewFrame = CGRectZero, contentViewFrame = CGRectZero;
	CGRectDivide(notificationContainerView.bounds, &titleViewFrame, &contentViewFrame, TITLE_VIEW_HEIGHT, CGRectMinYEdge);
	titleView.frame = titleViewFrame;
	contentView.frame = contentViewFrame;

	//Round corners
	CAShapeLayer *clippingLayer = [CAShapeLayer layer];
	UIRectCorner cornersToRound = UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight;
	CGFloat radius = [defaults boolForKey:@"ios10style"] ? 10 : 5;
	clippingLayer.path = [UIBezierPath bezierPathWithRoundedRect:notificationContainerView.bounds byRoundingCorners:cornersToRound cornerRadii:CGSizeMake(radius, radius)].CGPath;
	notificationContainerView.layer.mask = clippingLayer;

	//Layout content view
	[self layoutContentView];

	//Layout app name label
	CGFloat offset = iconSize() + [self iconPadding].width * 2;
	self.appNameLabel.frame = CGRectMake(offset, 0, CGRectGetWidth(titleView.bounds) - offset, CGRectGetHeight(titleView.bounds));
	if ([defaults boolForKey:@"ios10style"]) {
		self.appNameLabel.textColor = [UIColor blackColor];
		self.appNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
		self.appNameLabel.text = [self.appNameLabel.text uppercaseString];
	}
	[titleView addSubview:self.appNameLabel];

	//Notification time label
	self.timeLabel.frame = CGRectInset(titleView.bounds, TEXT_PADDING, 0);
	self.timeLabel.textAlignment = NSTextAlignmentRight;
	if ([defaults boolForKey:@"ios10style"]) {
		self.timeLabel.textColor = [UIColor blackColor];
		self.timeLabel.layer.compositingFilter = NULL;
		self.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
	}
	else
		self.timeLabel.textColor = [UIColor whiteColor];

	[titleView addSubview:self.timeLabel];

	//Layout app icon
	[self layoutAppIcon];
}

- (void)layoutAppIcon {
	//Set size & position
	const CGSize padding = [self iconPadding];
	const CGFloat size = iconSize();
	if ([defaults boolForKey:@"ios10style"] || [defaults boolForKey:@"smallIcon"])
		self.iconView.frame = CGRectMake(padding.width, notificationContainerView.frame.origin.y + TITLE_VIEW_HEIGHT - padding.height - size, size, size);
	else
		self.iconView.frame = CGRectMake(padding.width, padding.height, size, size);
	[self addSubview:self.iconView];

	//Make circular if setting is on
	if ([defaults boolForKey:@"circularIcon"]) {
		self.iconView.layer.cornerRadius = CGRectGetWidth(self.iconView.frame) / 2;
		self.iconView.layer.masksToBounds = YES;
	}

	//Drop shadows (app icon only for now)
	if ([defaults boolForKey:@"shadows"]) {
		if (![defaults boolForKey:@"circularIcon"]) {
			self.iconView.layer.masksToBounds = NO;
			self.iconView.layer.shadowColor = [UIColor blackColor].CGColor;
			self.iconView.layer.shadowOffset = CGSizeMake(0, 1.5);
			self.iconView.layer.shadowOpacity = 0.5;
			self.iconView.layer.shadowRadius = 1.0;
		}
	}
}

- (void)layoutContentView {
	const CGFloat maxTextWidth = (self.attachmentView) ? (CGRectGetWidth(contentView.bounds) - CGRectGetWidth(self.attachmentView.bounds)) : CGRectGetWidth(contentView.bounds);
	const CGFloat subtitleMultiplier = (self.subtitleLabel) ? 2.0 : 1.0;
	const CGFloat titleContainerHeight = (self.messageTitleLabel) ? (MESSAGE_TITLE_HEIGHT * subtitleMultiplier) : 0;

	//Attachment View
	self.attachmentView.frame = CGRectMake(CGRectGetWidth(contentView.bounds) - CGRectGetWidth(self.attachmentView.bounds), 0, CGRectGetWidth(self.attachmentView.bounds), CGRectGetHeight(contentView.bounds));
	[contentView addSubview:self.attachmentView];

	//Message title & subtitle
	if (self.messageTitleLabel) {
		UIView *titleContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maxTextWidth, titleContainerHeight)];
		titleContainerView.frame = CGRectInset(titleContainerView.frame, TEXT_PADDING, 0);

		//Add title label and subtitle label to container
		CGRect titleLabelFrame = titleContainerView.bounds, subtitleFrame;
		if (self.subtitleLabel) {
			CGRectDivide(titleContainerView.bounds, &titleLabelFrame, &subtitleFrame, CGRectGetHeight(titleContainerView.bounds) / 2, CGRectMinYEdge);
			self.subtitleLabel.frame = subtitleFrame;
			[titleContainerView addSubview:self.subtitleLabel];
		}
		self.messageTitleLabel.frame = titleLabelFrame;
		[titleContainerView addSubview:self.messageTitleLabel];

		[contentView addSubview:titleContainerView];
	}

	//Notification content label
	self.contentLabel.frame = CGRectInset(contentView.bounds, TEXT_PADDING, TEXT_PADDING);
	self.contentLabel.numberOfLines = 0;
	[self.contentLabel sizeToFit];
	[contentView addSubview:self.contentLabel];

	if ([defaults boolForKey:@"ios10style"]) {
		self.messageTitleLabel.textColor = [UIColor blackColor];
		self.subtitleLabel.textColor = [UIColor blackColor];
		self.contentLabel.textColor = [UIColor blackColor];
	}
}

@end
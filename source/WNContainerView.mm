#import "WNContainerView.h"

const CGFloat ROUNDED_CORNER_RADIUS = 5;
const CGFloat TEXT_PADDING = 10;
const CGFloat TITLE_VIEW_HEIGHT = 25;
const CGFloat TIME_LABEL_HEIGHT = 20;
const CGFloat MESSAGE_TITLE_HEIGHT = 20;

@implementation WNContainerView

- (id)initWithCellType:(CellType)type {
	if (self = [super initWithFrame:CGRectZero]) {
		cellType = type;
		notificationContainerView = [[UIView alloc] init];
		titleView = [[UIView alloc] init];
		contentView = [[UIView alloc] init];
		[self addSubview:notificationContainerView];
		[notificationContainerView addSubview:titleView];
		[notificationContainerView addSubview:contentView];

		//Title and content view background colors
		titleView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.7];
		contentView.backgroundColor = [UIColor colorWithWhite:0.45 alpha:0.4];
	}
	return self;
}

- (void)setBackgroundColor:(UIColor*)bgColor {
	_backgroundColor = bgColor;
	contentView.backgroundColor = bgColor;
}

- (CGSize)iconPadding {
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
	if ((cellType == kLoneCell || cellType == kTopCell) && (!self.iconView || !self.appNameLabel))
		return false;

	return true;
}

- (void)updateViews {
	if (![self readyToUpdateViews]) {
		return;
	}

	//Notification container view frame
	CGRect notificationContainerViewFrame = self.bounds;
	if (cellType == kLoneCell || cellType == kTopCell) {
		CGFloat offset = [self iconPadding].height * 3;
		notificationContainerViewFrame = CGRectMake(0, offset, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - offset);
	}
	notificationContainerView.frame = notificationContainerViewFrame;

	//Title and content view frames
	CGRect titleViewFrame = CGRectZero, contentViewFrame = CGRectZero;
	const CGFloat titleViewHeight = (cellType == kLoneCell || cellType == kTopCell) ? TITLE_VIEW_HEIGHT : 0;
	CGRectDivide(notificationContainerView.bounds, &titleViewFrame, &contentViewFrame, titleViewHeight, CGRectMinYEdge);
	titleView.frame = titleViewFrame;
	contentView.frame = contentViewFrame;

	//Round corners
	CAShapeLayer *clippingLayer = [CAShapeLayer layer];
	UIRectCorner cornersToRound = 0;
	if (cellType == kLoneCell || cellType == kTopCell) {
		cornersToRound = UIRectCornerTopLeft | UIRectCornerTopRight;
	}
	if (cellType == kLoneCell  || cellType == kBottomCell) {
		cornersToRound = cornersToRound | UIRectCornerBottomLeft | UIRectCornerBottomRight;
	}
	clippingLayer.path = [UIBezierPath bezierPathWithRoundedRect:notificationContainerView.bounds byRoundingCorners:cornersToRound cornerRadii:CGSizeMake(ROUNDED_CORNER_RADIUS, ROUNDED_CORNER_RADIUS)].CGPath;
	notificationContainerView.layer.mask = clippingLayer;

	//Layout content view
	[self layoutContentView];

	if (cellType == kLoneCell || cellType == kTopCell) {
		//Layout app name label
		CGFloat offset = iconSize() + [self iconPadding].width * 2;
		self.appNameLabel.frame = CGRectMake(offset, 0, CGRectGetWidth(titleView.bounds) - offset, CGRectGetHeight(titleView.bounds));
		[titleView addSubview:self.appNameLabel];

		//Layout app icon
		[self layoutAppIcon];
	}
	else {
		self.iconView.hidden = YES;
		self.appNameLabel.hidden = YES;
	}
}

- (void)layoutAppIcon {
	//Set size & position
	const CGSize padding = [self iconPadding];
	const CGFloat size = iconSize();
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
	self.contentLabel.frame = CGRectMake(0, titleContainerHeight, maxTextWidth, CGRectGetHeight(contentView.bounds) - titleContainerHeight - TIME_LABEL_HEIGHT);
	self.contentLabel.frame = CGRectInset(self.contentLabel.frame, TEXT_PADDING, 0);
	self.contentLabel.numberOfLines = 0;
	[self.contentLabel sizeToFit];
	// self.contentLabel.backgroundColor = [UIColor redColor];
	[contentView addSubview:self.contentLabel];

	//Notification time label
	self.timeLabel.frame = CGRectMake(0, CGRectGetHeight(contentView.bounds) - TIME_LABEL_HEIGHT, maxTextWidth, TIME_LABEL_HEIGHT);
	self.timeLabel.frame = CGRectInset(self.timeLabel.frame, TEXT_PADDING, 0);
	// self.timeLabel.backgroundColor = [UIColor greenColor];
	[contentView addSubview:self.timeLabel];
}

@end
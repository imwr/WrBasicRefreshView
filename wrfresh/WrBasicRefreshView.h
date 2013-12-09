//
//  WrBasicRefreshView.h
//
//  Created by cdwangrui on 13-12-6.
//
//
typedef enum {
	RefreshPulling = 0,
	RefreshNormal,
	RefreshLoading,
} WrBasicRefreshState;

#import <UIKit/UIKit.h>

@protocol WrBasicRefreshViewDelegate;
@interface WrBasicRefreshView : UIView
{
    UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	UIImageView *_statusImage;
    BOOL _demarcationLine;
    BOOL _isMoving;
    CGPoint _startTouch;
    NSInteger _timeout;
    UIActivityIndicatorView *_loadingview;
}
@property(nonatomic,assign) UIView  *parentView;
@property(nonatomic,assign) UIView  *refreshView;
@property(nonatomic,assign) WrBasicRefreshState state;
@property(nonatomic,assign) id delegate;

-(UIView *) initRefresh:(UIView *)view timeout:(NSInteger) timeout;
-(void) wrBasicRefreshLoadedData;

@end

@protocol WrBasicRefreshViewDelegate
- (void)wrBasicRefreshUpdatingData:(WrBasicRefreshView*)view;
@end
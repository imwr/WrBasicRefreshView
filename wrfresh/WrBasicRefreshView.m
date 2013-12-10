//
//  WrBasicRefreshView.m
//
//  Created by cdwangrui on 13-12-6.
//
//

#define SEP_LINE 65.0 //下拉开始刷新的高度

#import "WrBasicRefreshView.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation WrBasicRefreshView

@synthesize parentView;
@synthesize refreshView;
@synthesize delegate;
@synthesize state;

-(UIView *) initRefresh:(UIView *)view timeout:(NSInteger) timeout{
    self = [super initWithFrame:CGRectMake(0, 0-view.bounds.size.height, view.frame.size.width, view.bounds.size.height)];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    _timeout = timeout;
    
    CGRect frame = view.frame;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont systemFontOfSize:12.0f];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    _lastUpdatedLabel=label;
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont systemFontOfSize:12.0f];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    _statusLabel=label;
    
    UIImageView *imageview = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"blackArrow.png"]];
    [imageview setFrame:CGRectMake(50.0f, frame.size.height - 55.0f, 25.0f, 45.0f)];
    [self addSubview:imageview];
    _statusImage = imageview;
    
    UIActivityIndicatorView *loadingview = [[UIActivityIndicatorView alloc ] initWithFrame:CGRectMake(50.0f, frame.size.height - 55.0f, 25.0f, 45.0f)];
    loadingview.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self addSubview:loadingview];
    _loadingview = loadingview;
    
    [view.superview insertSubview:self belowSubview:view];
    UIPanGestureRecognizer *recognizer=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(paningGestureWork:)];
    [recognizer delaysTouchesBegan];
    parentView = view;
    [parentView addGestureRecognizer:recognizer];
    [self refreshSubViews:RefreshNormal changeImage:YES];
    
    return self;
}

- (void)paningGestureWork:(UIPanGestureRecognizer *)recoginzer
{
    CGPoint touchPoint = [recoginzer locationInView:[[UIApplication sharedApplication]keyWindow]];
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        if(state==RefreshLoading){
            return;
        }
        _isMoving = YES;
        _startTouch = touchPoint;
        NSString *updateDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"wr-refresh-lastupdatetime"];
        if(updateDate){
            _lastUpdatedLabel.text = [NSString stringWithFormat:@"上次更新: %@", updateDate];
        }
    }else if (recoginzer.state == UIGestureRecognizerStateEnded||recoginzer.state == UIGestureRecognizerStateCancelled){
        float y  = touchPoint.y - _startTouch.y;
        if(y>65){
            [self refreshSubViews:RefreshLoading changeImage:YES];
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frame = parentView.frame;
                frame.origin.y = SEP_LINE;
                parentView.frame = frame;
            } completion:^(BOOL finished) {
                _isMoving = NO;
            }];
        }else{
            [self refreshSubViews:RefreshNormal changeImage:NO];
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frame = parentView.frame;
                frame.origin.y = 0;
                parentView.frame = frame;
            } completion:^(BOOL finished) {
                _isMoving = NO;
                [self refreshUpdatedDate];
            }];
        }
        return;
    }
    if (_isMoving) {
        float y  = touchPoint.y - _startTouch.y;
        if(y<0) return;
        CGRect frame = parentView.frame;
        frame.origin.y = y;
        parentView.frame = frame;
        if(_demarcationLine&&y>SEP_LINE){
            _demarcationLine = NO;
            [self refreshSubViews:RefreshPulling changeImage:YES];
        }else if(!_demarcationLine&&y<SEP_LINE){
            _demarcationLine = YES ;
            [self refreshSubViews:RefreshNormal changeImage:YES];
        }
    }
}

-(void) refreshSubViews:(WrBasicRefreshState) wrBasicRefreshState changeImage:(BOOL)changeImage{
    switch (wrBasicRefreshState) {
		case RefreshPulling:
			_statusLabel.text = @"释放立即刷新...";
            if(changeImage){
                _statusImage.transform = CGAffineTransformRotate(_statusImage.transform, M_PI);
            }
			break;
		case RefreshNormal:
            _statusLabel.text = @"下拉刷新...";
            if(changeImage){
                _statusImage.transform = CGAffineTransformRotate(_statusImage.transform, M_PI);
            }
            break;
		case RefreshLoading:
			_statusLabel.text = @"更新中...";
            [_loadingview startAnimating];
            _statusImage.hidden = YES;
            [self wrBasicRefreshUpdatingData:self];
			break;
		default:
			break;
	}
    state = wrBasicRefreshState;
}

- (void) refreshUpdatedDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM.dd hh:mm"];
    NSString *updateDate = [formatter stringFromDate:[NSDate date]];
    _lastUpdatedLabel.text = [NSString stringWithFormat:@"上次更新: %@", updateDate];
    [[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:@"wr-refresh-lastupdatetime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)wrBasicRefreshLoadedData {
    if(state==RefreshLoading){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"msgcome" ofType:@"wav"];
        if(path){
            NSURL *url = [NSURL fileURLWithPath:path];
            SystemSoundID soundId;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundId);
            AudioServicesPlaySystemSound(soundId);
        }
        if(state==RefreshNormal||_isMoving) return;
        _isMoving = YES;
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = parentView.frame;
            frame.origin.y = 0;
            parentView.frame = frame;
        } completion:^(BOOL finished) {
            [_loadingview stopAnimating];
            _statusImage.hidden = NO;
            _isMoving = NO;
            [self refreshUpdatedDate];
            [self refreshSubViews:RefreshNormal changeImage:NO];
        }];
    }
}

- (void)wrBasicRefreshUpdatingData:(WrBasicRefreshView*)wrView{
    if ([delegate respondsToSelector:@selector(wrBasicRefreshUpdatingData:)]) {
		[delegate wrBasicRefreshUpdatingData:self];
        if(_timeout > 0){
            [self performSelector:@selector(isLoadedData) withObject:nil afterDelay:_timeout];
        }
    }else{
        [self performSelector:@selector(wrBasicRefreshLoadedData) withObject:nil afterDelay:3.0f];
    }
}

-(void) isLoadedData {
    if(state!=RefreshNormal){
        [self wrBasicRefreshLoadedData];
    }
}

@end

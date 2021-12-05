#import <UIKit/UIView+Private.h>
#import "../YouTubeHeader/YTWatchViewController.h"
#import "../YouTubeHeader/YTIPlayerResponse.h"
#import "../YouTubeHeader/YTISlimMetadataButtonSupportedRenderers.h"
#import "../YouTubeHeader/YTSlimVideoDetailsActionView.h"
#import "../YouTubeHeader/YTSlimVideoScrollableDetailsActionsView.h"
#import "../YouTubeHeader/YTIFormattedString.h"

float getAverageRating(YTSlimVideoDetailsActionView *self) {
    UIViewController *ancestor = [self _viewControllerForAncestor];
    if (![ancestor respondsToSelector:@selector(parentViewController)]) return 0;
    YTWatchViewController *watch = (YTWatchViewController *)(ancestor.parentViewController);
    if (![watch respondsToSelector:@selector(playerViewController)]) return 0;
    YTIPlayerResponse *response = [[[watch.playerViewController.activeVideo.singleVideo playbackData] playerResponse] playerData];
    return response.videoDetails.averageRating;
}

NSInteger getLike(YTSlimVideoDetailsActionView *self) {
    YTSlimVideoScrollableDetailsActionsView *delegate = self.visibilityDelegate;
    YTSlimVideoDetailsActionView *likeActionView = [delegate valueForKey:@"_likeActionView"];
    YTISlimMetadataButtonSupportedRenderers *likeRenderer = [likeActionView valueForKey:@"_supportedRenderer"];
    NSString *likeText = likeRenderer.slimMetadataToggleButtonRenderer.button.toggleButtonRenderer.defaultText.accessibility.accessibilityData.label;
    NSScanner *scanner = [NSScanner scannerWithString:likeText];
    NSString *likeNumber;
    if ([scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&likeNumber]) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        return [[formatter numberFromString:likeNumber] integerValue];
    }
    return 0;
}

NSString *getShortNumber(NSInteger num, double divider, char c) {
    double x = num / divider;
    NSString *format = (NSInteger)x == x ? @"%.0f%c" : @"%.1f%c";
    return [NSString stringWithFormat:format, num / divider, c];
}

NSString *getNormalizedDislike(NSInteger dislike) {
    if (dislike < 1000) return @(dislike).stringValue;
    if (dislike < 1000000) return getShortNumber(dislike, 1000, 'K');
    if (dislike < 1000000000) return getShortNumber(dislike, 1000000, 'M');
    return getShortNumber(dislike, 1000000000, 'B');
}

void setDislike(YTSlimVideoDetailsActionView *self) {
    float averageRating = getAverageRating(self);
    NSString *result;
    NSInteger like = -1, dislike = -1;
    if (averageRating) {
        like = getLike(self);
        if (like) {
            dislike = round(((5 / averageRating) - 1) * like);
            result = getNormalizedDislike(dislike);
        }
    }
    if (result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.label setFormattedString:[%c(YTIFormattedString) formattedStringWithString:result]];
            [self.label sizeToFit];
        });
    }
}

%hook YTSlimVideoDetailsActionView

+ (YTSlimVideoDetailsActionView *)actionViewWithSlimMetadataButtonSupportedRenderer:(YTISlimMetadataButtonSupportedRenderers *)renderer withElementsContextBlock:(id)block {
    if ([renderer rendererOneOfCase] == 153515154) {
        // Enforce 124608045 case
        return [[%c(YTSlimVideoDetailsActionView) alloc] initWithSlimMetadataButtonSupportedRenderer:renderer];
    }
    return %orig;
}

- (id)initWithSlimMetadataButtonSupportedRenderer:(id)arg1 {
    self = %orig;
    if (self) {
        YTISlimMetadataButtonSupportedRenderers *renderer = [self valueForKey:@"_supportedRenderer"];
        if ([renderer slimButton_isDislikeButton]) {
            // YTISlimMetadataToggleButtonRenderer *meta = renderer.slimMetadataToggleButtonRenderer;
            // NSString *myString = meta.target.videoId;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                setDislike(self);
            });
            [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(updateDislike) userInfo:nil repeats:YES];
        }
    }
    return self;
}

%new
- (void)updateDislike {
    setDislike(self);
}

%end
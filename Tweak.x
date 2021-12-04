#import "../YouTubeHeader/YTISlimMetadataButtonSupportedRenderers.h"
#import "../YouTubeHeader/YTSlimVideoDetailsActionView.h"
#import "../YouTubeHeader/YTIFormattedString.h"

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
            YTISlimMetadataToggleButtonRenderer *meta = renderer.slimMetadataToggleButtonRenderer;
            NSString *myString = meta.target.videoId;
            [self.label setFormattedString:[%c(YTIFormattedString) formattedStringWithString:myString]];
        }
    }
    return self;
}

%end
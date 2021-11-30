#import "../YouTubeHeader/YTISlimMetadataButtonSupportedRenderers.h"
#import "../YouTubeHeader/YTSlimVideoDetailsActionView.h"
#import "../YouTubeHeader/YTIFormattedString.h"

%hook YTSlimVideoDetailsActionView

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
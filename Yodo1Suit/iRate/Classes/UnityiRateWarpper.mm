#import "iRate.h"

#ifdef __cplusplus
extern "C" {
#endif
    /**
     *  打开AppStore评价页面
     */
    void UnityOpenReviewPage()
    {
        [[iRate sharedInstance]openRatingsPageInAppStore];
    }
    
#ifdef __cplusplus
}
#endif

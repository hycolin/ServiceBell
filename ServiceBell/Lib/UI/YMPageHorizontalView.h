#import <UIKit/UIKit.h>
#import "YMTableHorizontalView.h"

@class YMPageHorizontalView;

//自动滚动方向
typedef enum 
{
    YMPageHorizpntalDerectionLeft =0,
    YMPageHorizpntalDerectionRight=1
} YMPageHorizpntalDerection;


@interface YMPageViewCell:YMTableHorizontalViewCell 

@end

//数据集合
@protocol YMPageHorizontalViewDataSource<NSObject>

@required
//表单有几个Page
- (NSInteger)pageHorizontalView:(YMPageHorizontalView *)pageView numberOfColumnInSection:(NSInteger)section;
//具体的列
- (YMPageViewCell *)pageHorizontalView:(YMPageHorizontalView *)tableView cellForPageAtIndexPath:(NSIndexPath *)indexPath;
@end


@protocol YMPageHorizontalViewDelegate<NSObject>
- (void) pageHorizontalView : (YMPageHorizontalView*)pageView didPageEnterScreenAtIndex:(NSIndexPath*)path;
- (void) pageHorizontalView : (YMPageHorizontalView*)pageView didPageDeEnterScreenAtIndex:(NSIndexPath*)path;

@end


//横向滚动page
@interface YMPageHorizontalView : UIView

{
@private
    YMTableHorizontalView* _tableView;
    NSTimer* _timer;
    
}
@property (nonatomic, assign)id<YMPageHorizontalViewDataSource>datasource;
@property (nonatomic, assign)id<YMPageHorizontalViewDelegate>delegate;
@property (nonatomic, assign) NSTimeInterval   autoscrolltime;
@property (nonatomic, assign) BOOL  autoscroll;//自动
@property (nonatomic, assign) YMPageHorizpntalDerection autoderection;
@property (nonatomic, assign) BOOL  recyclescroll; //循环
@property (nonatomic, retain) NSIndexPath *currentpage;
- (void)reloadData;

- (void)clear;
-(NSIndexPath*)indexPathForSelectedPage;
//获取cell(bomb:cell仅仅能返回正在显示区域中的indexpath)
-(YMTableHorizontalViewCell *)cellForPageAtIndexPath:(NSIndexPath *)indexPath;
//获得流转池里cell
-(YMTableHorizontalViewCell* )dequeueReusablePageWithIdentifier:(NSString *)identifier; 
//-(void)reloadRowsAtIndexPath:(NSIndexPath*) indexPath;
//选中某列，区别于selectedIndex在于本消息会跳转到移动到相关行
- (void)selectPageAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
@end

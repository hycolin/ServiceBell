
#import <UIKit/UIKit.h>

//选中列位置
typedef enum {
    YMTableHorizontalViewScrollPositionNone,        
    YMTableHorizontalViewScrollPositionLeft,    
    YMTableHorizontalViewScrollPositionMiddle,   
    YMTableHorizontalViewScrollPositionRight
} YMTableHorizontalViewScrollPosition;    

@class YMTableHorizontalView;
//单元格
@interface YMTableHorizontalViewCell : UIView 
{ 
   //nothing
}
//@property (retain,nonatomic)UIImage* image
@property (nonatomic,retain)NSIndexPath *index;
@property (nonatomic,copy)  NSString* identifier;
-(id)initWithReuseIdentifier:(NSString *)identifier;
@end


//数据集合
@protocol YMTableHorizontalViewDataSource<NSObject>
@required
//表单有几个Column
- (NSInteger)tableView:(YMTableHorizontalView *)tableView numberOfColumnInSection:(NSInteger)section;
//具体的列
- (YMTableHorizontalViewCell *)tableView:(YMTableHorizontalView *)tableView cellForColumnAtIndexPath:(NSIndexPath *)indexPath;
@optional

//- (NSString *)tableView:(YMTableHorizontalView *)tableView titleForHeaderInSection:(NSInteger)section;   
//- (NSString *)tableView:(YMTableHorizontalView *)tableView titleForFooterInSection:(NSInteger)section;
@end



//委托
@protocol YMTableHorizontalViewDelegate<UIScrollViewDelegate>
//获取列宽度，适用于非恒定宽度列
@optional
- (CGFloat)tableView:(YMTableHorizontalView *)tableView widthForColumnAtIndexPath:(NSIndexPath *)indexPath;
//即将选中列
- (NSIndexPath *)tableView:(YMTableHorizontalView *)tableView willSelectColumnAtIndexPath:(NSIndexPath *)indexPath;
//选中列
- (void)tableView:(YMTableHorizontalView *)tableView didSelectColumnAtIndexPath:(NSIndexPath *)indexPath;
//取消列
- (void)tableView:(YMTableHorizontalView *)tableView didDeSelectColumnAtIndexPath:(NSIndexPath *)indexPath;
//列切换时发出的消息
//滚动到底部时发出的消息
- (void)scrollViewDidScrollToEnd:(YMTableHorizontalView *)scrollView; 
@end

//类
@interface YMTableHorizontalView : UIScrollView<UIScrollViewDelegate>
{
    //@private NSArray* _
@private 
    NSMutableArray* _showViewArray;
    NSMutableArray* _unShowViewArray;
    id<YMTableHorizontalViewDelegate> _newdelegate;
//@private BOOL _autoColumnWidth;
}
@property (assign,nonatomic) CGFloat columnWidth;
@property (assign,nonatomic)id<YMTableHorizontalViewDataSource>datasource;
@property (assign,nonatomic)id<YMTableHorizontalViewDelegate>delegate;
@property (retain,nonatomic) NSIndexPath* selectedIndex;
//装载
-(void)reloadData; 

//清空
- (void)clear;

-(NSIndexPath*)indexPathForSelectedColumn;
//获取cell(bomb:cell仅仅能返回正在显示区域中的indexpath)
-(YMTableHorizontalViewCell *)cellForColumnAtIndexPath:(NSIndexPath *)indexPath;
//获得流转池里cell
-(YMTableHorizontalViewCell* )dequeueReusableCellWithIdentifier:(NSString *)identifier; 
//-(void)reloadRowsAtIndexPath:(NSIndexPath*) indexPath;
//选中某列，区别于selectedIndex在于本消息会跳转到移动到相关行
- (void)selectColumnAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(YMTableHorizontalViewScrollPosition)scrollPosition;
@end

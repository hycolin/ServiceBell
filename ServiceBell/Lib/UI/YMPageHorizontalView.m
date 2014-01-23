#import "YMPageHorizontalView.h"

#define EXTENTION_CELL_NUM 1
#define DEFAULT_TIME 2.000000
@implementation YMPageViewCell
@end

@interface YMPageHorizontalView(private)<YMTableHorizontalViewDataSource,YMTableHorizontalViewDelegate>
- (void)scrollViewDidCheckJump;//检查跳跃
- (void)createAutoTimer;//创建定时器
- (void)autoScrollTimerUp;//定时器到时
@end


@implementation YMPageHorizontalView
@synthesize datasource;
@synthesize delegate;
@synthesize autoscroll = _autoscroll;//自动
@synthesize recyclescroll = _recyclescroll; //循环
@synthesize autoscrolltime;
@synthesize autoderection;
@synthesize currentpage = _currentpage;

- (void)initComponent
{
    [_tableView release];
    _tableView = [[YMTableHorizontalView alloc]initWithFrame:self.bounds];
    _tableView.datasource = self;
    _tableView.delegate = self;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.alwaysBounceHorizontal = YES;
    _tableView.autoresizingMask =   UIViewAutoresizingFlexibleLeftMargin|
                                    UIViewAutoresizingFlexibleWidth|
                                    UIViewAutoresizingFlexibleRightMargin|
                                    UIViewAutoresizingFlexibleTopMargin|
                                    UIViewAutoresizingFlexibleHeight|
                                    UIViewAutoresizingFlexibleBottomMargin;
    _tableView.clipsToBounds = NO;
    [_tableView removeFromSuperview];
    self.autoscrolltime = DEFAULT_TIME;
    _tableView.pagingEnabled = YES;
    self.autoderection = YMPageHorizpntalDerectionRight;
    [self addSubview:_tableView];
}
- (void)setAutoscroll:(BOOL)autoscroll
{
    _autoscroll = autoscroll;
    if(autoscroll == YES)
    {
        self.recyclescroll = autoscroll;
    }else
    {
        if(_timer != nil)
        {
            [_timer invalidate];
            [_timer release];
            _timer = nil;
        }
    }
}
- (void)setRecyclescroll:(BOOL)recyclescroll
{
    _recyclescroll = recyclescroll;
    if(_recyclescroll == NO)
    {
        _autoscroll = NO;
    }
}
- (void)scrollViewDidCheckJump
{
    int width = 0;
    if(_tableView.contentOffset.x < _tableView.columnWidth*EXTENTION_CELL_NUM)//左端跳转
    {
        width = _tableView.columnWidth* EXTENTION_CELL_NUM - _tableView.contentOffset.x ;//偏移
        //我蹦
        [_tableView setContentOffset:CGPointMake( _tableView.contentSize.width - _tableView.columnWidth*(EXTENTION_CELL_NUM)-width,0)];
        //NSLog(@"%@",@"1");
    }else if (_tableView.contentOffset.x >= _tableView.contentSize.width - _tableView.columnWidth*(EXTENTION_CELL_NUM) )
    {
        width = _tableView.contentOffset.x -([self.datasource pageHorizontalView:(YMPageHorizontalView *)self numberOfColumnInSection:(NSInteger)0])*_tableView.columnWidth;
        //再蹦
        [_tableView setContentOffset:CGPointMake(width,0)];
        //NSLog(@"%@",@"2");
    }
    if(self.autoscroll)
    {
        [self createAutoTimer];
    }
}

- (void)scrollViewDidCheckPageIndex
{
    int index = _tableView.contentOffset.x/_tableView.columnWidth;
    if(self.currentpage != nil && self.currentpage.row == index)
    {
        return;
    }
    if(self.delegate != nil && self.currentpage!= nil && [self.delegate respondsToSelector:@selector(pageHorizontalView:didPageDeEnterScreenAtIndex:)] == YES)
    {
        [self.delegate pageHorizontalView:self didPageDeEnterScreenAtIndex:self.currentpage];
    }
    self.currentpage = [NSIndexPath indexPathForRow:index inSection:0];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(pageHorizontalView:didPageEnterScreenAtIndex:)] == YES) 
    {
        [self.delegate pageHorizontalView:self didPageEnterScreenAtIndex:self.currentpage];
    }
   
}
- (void)setCurrentpage:(NSIndexPath *)currentpage
{
    if(currentpage != self.currentpage)
    {
        [_currentpage release];
        _currentpage = [currentpage retain];
        _tableView.selectedIndex = currentpage;
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(self.recyclescroll)
    {
        [self scrollViewDidCheckJump];
    }
    [self scrollViewDidCheckPageIndex];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if(self.recyclescroll)
    {
        [self scrollViewDidCheckJump];
    }
    [self scrollViewDidCheckPageIndex];

}
- (void)autoScrollTimerUp
{
    CGPoint point = _tableView.contentOffset;
    if(self.autoderection == YMPageHorizpntalDerectionLeft)
    {
        point.x -= _tableView.columnWidth;
    }else
    {
        point.x += _tableView.columnWidth;
    }
    [_tableView setContentOffset:point animated:YES];
}
- (void)createAutoTimer
{
    if(_timer != nil)
    {
        [_timer invalidate];
        [_timer release];
        _timer = nil;
    }
    _timer =  [[NSTimer scheduledTimerWithTimeInterval:self.autoscrolltime target:self selector:@selector(autoScrollTimerUp) userInfo:nil repeats:NO]retain];
}

- (void)reloadData
{
    [_tableView reloadData];
    if(self.recyclescroll)
    {
        [_tableView setContentOffset: CGPointMake(_tableView.columnWidth*EXTENTION_CELL_NUM, 0) animated:NO];
    }
    if(self.autoscroll)
    {
        [self createAutoTimer];
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _tableView.frame =CGRectMake(0, 0, frame.size.width, frame.size.height);
    _tableView.columnWidth = frame.size.width;

}
- (id)init {
    self = [super init];
    if (self) {
         [self initComponent];
    }
    return self;
}


- (void)awakeFromNib
{
   [self initComponent];
}
- (void)dealloc 
{
    _tableView.delegate = nil;
    _tableView.datasource = nil;
    [_tableView release];
    self.currentpage = nil;
    if (_timer != nil) {
        [_timer invalidate];
        [_timer release];
    }
    [super dealloc];
}

- (void)clear
{
    [_tableView clear];
}

#pragma mark datasource
- (NSInteger) tableView:(YMTableHorizontalView *)tableView numberOfColumnInSection:(NSInteger)section
{
    if(self.datasource)
    {
        int count = [self.datasource pageHorizontalView:self numberOfColumnInSection:section];
        return self.recyclescroll?count+EXTENTION_CELL_NUM*2:count;//左右2边
    }
    return 0;
}

- (YMTableHorizontalViewCell *)tableView:(YMTableHorizontalView *)tableView cellForColumnAtIndexPath:(NSIndexPath *)indexPath                 
{
    if(self.recyclescroll)
    {
        NSIndexPath* path = nil;
        int count =[self.datasource pageHorizontalView:self numberOfColumnInSection:indexPath.section];
        if(indexPath.row <EXTENTION_CELL_NUM)//前越
        {
            int row = indexPath.row - EXTENTION_CELL_NUM;
            while (row< 0) {
                row += count;
            }
            path = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
        }else if(indexPath.row >= count + EXTENTION_CELL_NUM)//超越
        {
            int row = indexPath.row - EXTENTION_CELL_NUM;
            row %= count;
            path = [NSIndexPath indexPathForRow:row inSection:indexPath.section];

        }else
        {
            path = [NSIndexPath indexPathForRow:indexPath.row-EXTENTION_CELL_NUM inSection:indexPath.section];

        }
        return [self.datasource pageHorizontalView:self cellForPageAtIndexPath:path];
        
    }else
    {
        return [self.datasource pageHorizontalView:self cellForPageAtIndexPath:indexPath];
    }
}

#pragma mark YMTableHorizontalDelegate
- (CGFloat)tableView:(YMTableHorizontalView *)tableView widthForColumnAtIndexPath:(NSIndexPath *)indexPath
{
    ////return CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    return CGRectGetWidth(self.bounds);
}

-(NSIndexPath*)indexPathForSelectedPage
{
    return [_tableView indexPathForSelectedColumn];
}
//获取cell(bomb:cell仅仅能返回正在显示区域中的indexpath)
-(YMTableHorizontalViewCell *)cellForPageAtIndexPath:(NSIndexPath *)indexPath
{
    return [_tableView cellForColumnAtIndexPath:indexPath];
}
//获得流转池里cell
-(YMTableHorizontalViewCell* )dequeueReusablePageWithIdentifier:(NSString *)identifier
{
    return [_tableView dequeueReusableCellWithIdentifier:identifier];
}
//-(void)reloadRowsAtIndexPath:(NSIndexPath*) indexPath;
//选中某列，区别于selectedIndex在于本消息会跳转到移动到相关行
- (void)selectPageAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    self.currentpage = indexPath;
     [_tableView selectColumnAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(YMTableHorizontalViewScrollPosition)YMTableHorizontalViewScrollPositionLeft];
}

@end

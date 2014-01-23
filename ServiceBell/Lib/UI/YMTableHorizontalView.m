
#import "YMTableHorizontalView.h"
#define COLUMNWIDTH 100//每个cell的默认宽度
#define EXTENSION COLUMNWIDTH
#define EXTENSION_TAIL (COLUMNWIDTH/2)
@implementation YMTableHorizontalViewCell
@synthesize index;
@synthesize identifier = _identifier;


- (void)setIdentifier:(NSString *)identifier
{
    if(_identifier != identifier)
    {
        [_identifier release];
        _identifier = [identifier copy];
        
    }
}

//初始化
-(id)initWithReuseIdentifier:(NSString *)identi;
{
    if(self = [super init])
    {
        self.identifier = identi;
        self.clipsToBounds = YES;
    }
    return self;
}
//销毁
-(void)dealloc
{
    self.index = nil;
    self.identifier = nil;
   
    [super dealloc];
}

@end

@interface YMTableHorizontalView (Private)
//计算代码
- (void)caculate;
//空cell时
- (BOOL)caculateNon;
//计算头部越界
- (BOOL)caculateHead;
//尾部越界
- (BOOL)caculateTail;
//头部添加新column
- (BOOL)columnAddHead;
//尾部添加新column
- (BOOL)columnAddTail;
//计算是否是自动宽度
- (BOOL)isAutoColumnWidth;
//获取列宽度
- (int)columnWidth:(NSIndexPath *)path;
//初始化
- (void)initComponent;
@end

//实现
@implementation YMTableHorizontalView
//返回
@synthesize datasource;
@synthesize columnWidth;
@synthesize delegate = _newdelegate;
@synthesize selectedIndex = _selectedIndex;

- (void)awakeFromNib {
    [self initComponent];
}

- (void)initComponent
{
    [super setDelegate:self];
    if(self.columnWidth ==0)
    {
        self.columnWidth = COLUMNWIDTH;
    }
    [_showViewArray release];
    _showViewArray = nil;
    [_unShowViewArray release];
    _unShowViewArray = nil;
    _showViewArray =[NSMutableArray new];//页面上
    _unShowViewArray = [NSMutableArray new];//非页面上
    self.clipsToBounds = YES;
}

//初始化
-(id)init
{
    
    if(self = [super init])
    {
        //[self initComponent];//非页面上
        
    }
    return self;
}
- (id)initWithFrame:(CGRect) frame
{
    if(self = [super initWithFrame:frame])
    {
        [self initComponent];//非页面上
    }
    return self;
}
//回跳转
- (void)selectColumnAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(YMTableHorizontalViewScrollPosition)scrollPosition;
{
    self.selectedIndex = indexPath;
   if(indexPath.row >= [self.datasource tableView:self numberOfColumnInSection:indexPath.section])   
   {
       return;//goodbye;
   }else
       
   {
       int sum = 0 ;
       int lastWidth  = 0;
       for (int i=0;i<indexPath.row;i++)
       {
           NSIndexPath* index= [NSIndexPath indexPathForRow:i inSection:0];
           lastWidth = [self columnWidth:index];
           sum += lastWidth;
       }
       if(scrollPosition == YMTableHorizontalViewScrollPositionMiddle)
       {
           sum -= (self.frame.size.width - lastWidth)/2+lastWidth;
       }else if (scrollPosition == YMTableHorizontalViewScrollPositionRight)
       {
           sum -= self.frame.size.width - lastWidth;
       }
     
       //矫正右出界
       sum= (sum+ self.frame.size.width) >self.contentSize.width?(self.contentSize.width- self.frame.size.width):sum;  
         sum= sum <0?0:sum;//矫正左出界
       [self setContentOffset:CGPointMake(sum,0 ) animated:animated];
       
       
   }
    
    
}
- (void)clear
{
    for (YMTableHorizontalViewCell *cell  in _unShowViewArray) 
    {
        [cell removeFromSuperview];
    }
    for (YMTableHorizontalViewCell *cell  in _showViewArray) 
    {
        [cell removeFromSuperview];
    }
    [_unShowViewArray removeAllObjects];
    [_showViewArray removeAllObjects];
    
    self.selectedIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    self.contentSize = CGSizeMake(0, 0);
}
//
-(void)reloadData
{
    if(datasource)
    {//仅支持单个section
        [self clear];
        self.scrollEnabled = NO;
        self.contentOffset = CGPointMake(0, 0);
        int count = [self.datasource tableView:(YMTableHorizontalView *)self numberOfColumnInSection:(NSInteger)0];
        if([self isAutoColumnWidth])
        {
            self.contentSize = CGSizeMake(self.columnWidth*count,self.frame.size.height);
        }else
        {
            int widthSum = 0;
            NSAutoreleasePool *pool = [NSAutoreleasePool new];
            for (int i =0; i<count; i++) 
            {
                NSIndexPath* path = [NSIndexPath indexPathForRow:i inSection:0];
                widthSum+= [self.delegate tableView:self widthForColumnAtIndexPath:path];
            }
            [pool release];
            self.contentSize = CGSizeMake(widthSum,self.frame.size.height);
        }
        
        
        [self caculate];
        self.scrollEnabled =YES;
    }
}
//滚动
-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self caculate];
    //didscroll
    if(self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidScroll:)])
    {
        [self.delegate scrollViewDidScroll:(UIScrollView *)scrollView];
       
    }

}
//设置delegate
-(BOOL)caculateHead//计算头部越界
{
    int offsetX = self.contentOffset.x-EXTENSION;   

    YMTableHorizontalViewCell *temp  = [_showViewArray objectAtIndex:0];
    if((temp.frame.origin.x+temp.frame.size.width)<offsetX)
    {
        if(temp.identifier != nil)
        {
            [_unShowViewArray insertObject:temp atIndex:0];
        }   
        [_showViewArray removeObject:temp];
        [temp removeFromSuperview];
        //移出
        return YES;
    }
    return NO;
}
-(BOOL)caculateTail//尾部
{
    if(_showViewArray.count>0)
    {
        YMTableHorizontalViewCell *temp = nil;
        int offsetX = self.contentOffset.x + EXTENSION;  
        int frameWidth = self.frame.size.width;
        temp = [_showViewArray objectAtIndex:_showViewArray.count-1];
        
        if((temp.frame.origin.x)>(offsetX+frameWidth))
        {
            if(temp.identifier != nil)
            {
                [_unShowViewArray addObject:temp];
            }
            [_showViewArray removeObject:temp];
            [temp removeFromSuperview];
            //移出
            return YES;
        }
    }
    return  NO;

}
-(BOOL)columnAddHead//头部添加新column
{
    if (_showViewArray.count>0)
    {
        YMTableHorizontalViewCell *temp = nil;
        int offsetX = self.contentOffset.x;  
        temp = [_showViewArray objectAtIndex:0];
        if(temp.frame.origin.x>(offsetX - EXTENSION_TAIL))
        {
                       
            if (temp.index.row > 0) 
            {//需要添加
                //
                
                NSIndexPath *path = [NSIndexPath indexPathForRow:temp.index.row-1 inSection:temp.index.section];
                
                //增加头部一个
//                for (YMTableHorizontalViewCell *cell in _showViewArray) 
//                {
//                    if(cell.index.row == path.row)
//                    {
//                        return YES;
//                    }
//                }

                YMTableHorizontalViewCell* cell = [datasource tableView:self cellForColumnAtIndexPath:(NSIndexPath *)path];
                
                [_showViewArray insertObject:cell atIndex:0];
                [_unShowViewArray removeObject:cell];
                cell.index = path;
                int width = [self columnWidth:path];
                cell.frame = CGRectMake(temp.frame.origin.x-width
                                        , 0, width, self.frame.size.height);
                [self insertSubview:cell atIndex:0];
                return YES;
            }
            
        }
    }
    return  NO;

}
//尾部添加
-(BOOL)columnAddTail//尾部
{
    //尾部越界处理
    if (_showViewArray.count>0) {
        YMTableHorizontalViewCell *temp = nil;
        int offsetX = self.contentOffset.x;  
        int frameWidth = self.frame.size.width;
        temp = [_showViewArray objectAtIndex:_showViewArray.count-1];
        if((temp.frame.origin.x+temp.frame.size.width)<(offsetX+frameWidth+EXTENSION_TAIL))
        {
            //增加尾巴一个
            if(temp.index.row< ([self.datasource tableView:(YMTableHorizontalView *)self numberOfColumnInSection:0]-1))
            {
                NSIndexPath *path = [NSIndexPath indexPathForRow:temp.index.row+1 inSection:temp.index.section];
//                for (YMTableHorizontalViewCell *cell in _showViewArray) 
//                {
//                    if(cell.index.row == path.row)
//                    {
//                        return YES;
//                    }
//                }

                YMTableHorizontalViewCell * cell = [datasource tableView:self cellForColumnAtIndexPath:(NSIndexPath *)path];
                
                [_showViewArray addObject:cell];
                [_unShowViewArray removeObject:cell];
                cell.index = path;
                cell.frame = CGRectMake(temp.frame.origin.x+temp.frame.size.width,0,[self columnWidth:path],self.frame.size.height);  
                [self addSubview:cell];
                return YES;
            }
        }
    }
    return NO;

}
//计算空数据
-(BOOL)caculateNon
{
    int offsetX = self.contentOffset.x;
    //需要改进成计算出实际应该插入第几个
    //得到总行数
    int count = [self.datasource tableView:self numberOfColumnInSection:0];
    int sumWidh = 0;
    int width = 0;
    NSIndexPath *path = nil;
    for(int i =0;i<count;i++)
    {
        path = [NSIndexPath indexPathForRow:i inSection:0];
        width = [self columnWidth:path];
        sumWidh += width;
        if(sumWidh == 0)
        {
            return NO;//结束
        }
        if(sumWidh > offsetX)//计算到合理的位置
        {
            break;
        }
    }
    CGRect frame = CGRectMake(sumWidh - width, 0, width, self.frame.size.height);
    //计算首column宽度
    if(frame.origin.x+frame.size.width > offsetX &&( offsetX + self.frame.size.width>0) )
    {
        YMTableHorizontalViewCell* cell = [datasource tableView:self cellForColumnAtIndexPath:(NSIndexPath *)path];
        if (cell == nil) {
            return NO;
        }
        cell.index = path;
        cell.frame = frame;
        [_showViewArray addObject:cell];
        [_unShowViewArray removeObject:cell];
        [self addSubview:cell];
        return YES;
    }            
    return NO;
}
//计算
-(void)caculate
{
    if(datasource)
    {
//        NSLog(@"xx%d",_showViewArray.count);
//        NSLog(@"yy%d",_unShowViewArray.count);
        //NSLog(@"yy%d",_showViewArray.count);
        BOOL iDeal = NO;
        while (true) {
            iDeal = NO;
            if (_showViewArray.count>0) 
            {
                iDeal = [self caculateHead];
                iDeal = iDeal == YES?YES:[self caculateTail];
                iDeal = iDeal == YES?YES:[self columnAddTail];
                iDeal = iDeal == YES?YES:[self columnAddHead];
            }else{
                iDeal = [self caculateNon];
            }
            //未有处理
            if(!iDeal)
            {
                break;
            }
        }
    }
    
       
}
-(BOOL)isAutoColumnWidth
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(tableView:widthForColumnAtIndexPath:)] == YES)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
//点击事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if(touch != nil)
    {
        CGPoint point = [touch locationInView:self];
        int realX = point.x;//+self.contentOffset.x;
        for(int i = 0 ;i<[_showViewArray count];i++)
        {
            YMTableHorizontalViewCell *cell = [_showViewArray objectAtIndex:i];
            if((cell.frame.origin.x+cell.frame.size.width) >=realX)
            {
                if(self.selectedIndex != nil && [self.delegate respondsToSelector:@selector(tableView: didDeSelectColumnAtIndexPath:)] == YES)
                { 
                   [self.delegate tableView:self didDeSelectColumnAtIndexPath:self.selectedIndex];
                    
                }
                
                self.selectedIndex = cell.index;
                if([self.delegate respondsToSelector:@selector(tableView: didSelectColumnAtIndexPath:)] ==YES)
                    
                {
                    [self.delegate tableView:self didSelectColumnAtIndexPath:cell.index];
                }
                break;
            }
        }
    }
}
- (void)setSelectedIndex:(NSIndexPath *)selectedIndex
{
    if (selectedIndex == nil) {
        [_selectedIndex release];
        _selectedIndex = nil;
    }else{
        if(selectedIndex.row >= [self.datasource tableView:self numberOfColumnInSection:selectedIndex.section])
        {
            return;//越界
        }
        if(selectedIndex != _selectedIndex)
        {
//            if(selectedIndex != nil)
//            {
//                //实现切换cell接口的还是要切换一下的
//                if([self.delegate respondsToSelector:@selector(tableView:didDeSelectColumnAtIndexPath:)]  == YES)
//                {
//                   [self.delegate tableView:(YMTableHorizontalView *)self didDeSelectColumnAtIndexPath:(NSIndexPath *)self.selectedIndex];
//                }
//            }
            [_selectedIndex release];
            _selectedIndex = [selectedIndex retain];
            
//            if([self.delegate respondsToSelector:@selector(tableView:didSelectColumnAtIndexPath:)]  == YES)
//            {
//                [self.delegate tableView:(YMTableHorizontalView *)self didSelectColumnAtIndexPath:(NSIndexPath *)self.selectedIndex];
//            }
        }
    }
    
}
//获取对象宽度
-(int)columnWidth:(NSIndexPath *)path
{
    if(![self isAutoColumnWidth])// 不自动
    {
        return  [self.delegate tableView:self widthForColumnAtIndexPath:path];
    }
    return self.columnWidth;
}
//获取对象
-(YMTableHorizontalViewCell* )dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    for(int i = 0 ;i<_unShowViewArray.count;i++)
    {
        YMTableHorizontalViewCell *cell = [_unShowViewArray objectAtIndex:i];
        if([cell.identifier caseInsensitiveCompare:identifier] == NSOrderedSame)
        {
            //[_unShowViewArray removeObject:cell];
            return cell;
        }
    }
    return nil;
}
//获取指定索引的cell
-(YMTableHorizontalViewCell *)cellForColumnAtIndexPath:(NSIndexPath *)indexPath
{
    for (YMTableHorizontalViewCell* cell in _showViewArray) {
        if(cell.index!=nil && cell.index.row == indexPath.row && cell.index.section == indexPath.section)
        {
            return  cell;
        }
    }
    return nil;
}
-(void)reloadRowsAtIndexPath:(NSIndexPath*) indexPath
{
    for (YMTableHorizontalViewCell*cell in _showViewArray) {
        if(cell.index != nil)
        {
            if(cell.index.row == indexPath.row && cell.index.section == indexPath.section)
            {
                
            }
        }
    }
}
#pragma mark scrollView default deleagte scroll默认自带的委托

- (void)scrollViewDidZoom:(UIScrollView *)scrollView // any zoom scale changes
{
    if([self.delegate respondsToSelector:@selector(scrollViewDidZoom:)])
    {
        [self.delegate scrollViewDidZoom:self];
    }
}
// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    if([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
    {
        [self.delegate scrollViewWillBeginDragging:self];
    }
}
// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if([self.delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)])
    {
        [self.delegate scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(CGPoint *)targetContentOffset];
    }
}
- (void)scrollViewDidScrollToEnd
{
    if(self.contentOffset.x + self.frame.size.width >= self.contentSize.width)
    {
        if([self.delegate respondsToSelector:@selector(scrollViewDidScrollToEnd:)])
        {
            [self.delegate scrollViewDidScrollToEnd:self];
        }
    }
}
// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    if([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
    {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    if(decelerate == NO)
    {
        [self scrollViewDidScrollToEnd];
    }
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView  // called on finger up as we are moving
{
    if([self.delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)])
    {
        [self.delegate scrollViewWillBeginDecelerating:scrollView];
    }
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;      // called when scroll view grinds to a halt
{
    if([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
    {
        [self.delegate scrollViewDidEndDecelerating:scrollView];/////////////////
    }
     [self scrollViewDidScrollToEnd];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView; // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
{
    if([self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)])
    {
        [self.delegate scrollViewDidEndScrollingAnimation:scrollView];
    }
    [self scrollViewDidScrollToEnd];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;     // return a view that will be scaled. if delegate returns nil, nothing happens
{
    if([self.delegate respondsToSelector:@selector(viewForZoomingInScrollView:scrollView:)])
    {
       return  [self.delegate viewForZoomingInScrollView:scrollView];
    }
    return nil;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_2); // called before the scroll view begins zooming its content
{
    if([self.delegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)])
    {
        [self.delegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale; // scale between minimum and maximum. called after any 'bounce' animations
{
    if([self.delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)])
    {
        [self.delegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView;   // return a yes if you want to scroll to the top. if not defined, assumes YES
{
    if([self.delegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)])
    {
       return  [self.delegate scrollViewShouldScrollToTop:scrollView];
    }
    return YES;
}
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView; 
{
    if([self.delegate respondsToSelector:@selector(scrollViewDidScrollToTop:)])
    {
        [self.delegate scrollViewDidScrollToTop:scrollView];
    }
}
- (NSIndexPath* )indexPathForSelectedColumn
{
    return self.selectedIndex;
}
//销毁
-(void)dealloc
{
    //self.delegate = nil;
    super.delegate = nil;
    self.selectedIndex = nil;
    [_showViewArray release];
    [_unShowViewArray release];
    [super dealloc];
}
@end

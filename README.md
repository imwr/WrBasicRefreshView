WrBasicRefreshView
==================
Do you know EGOTableViewPullRefresh?Yes,It's a great pull down to refresh control.However,It just seems to be effective for UITableView and UIScrollView,so I write this WrBasicRefreshView control which can pull any kinds of UIView down to refresh.

WrBasicRefreshView is very simple,and you can use it just like this:

1. add "wrrefresh" fold to your project;
2. init "WrBasicRefreshView" by calling initRefresh method,for example:
   //=============**start**============
   WrBasicRefreshView *wrView = [[WrBasicRefreshView alloc] initRefresh:self.view timeout:0];
   wrView.delegate = self;
   [self.view addSubview:wrView];
   //=============**end**============
   "self.view" is the view except for UITableView and UIScrollView that you want to pull down to refresh.
3. implement method:
   - (void)wrBasicRefreshUpdatingData:(WrBasicRefreshView*)wrView;
4. After data was loaded,just call "wrBasicRefreshLoadedData" method to recovery view(you also can set a timeout when init    to do this automatically). 

I'm a beginner,and WrBasicRefreshView have not been fully tested.Hope help to you.

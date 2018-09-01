//
//  ChoosePoiViewController.m
//  ArtRoomStudent
//
//  Created by 黄金台 on 2018/8/10.
//  Copyright © 2018年 黄金台. All rights reserved.
//

#import "ChoosePoiViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "POITableViewCell.h"

@interface ChoosePoiViewController () <UISearchControllerDelegate,UISearchResultsUpdating,MAMapViewDelegate,AMapLocationManagerDelegate,AMapSearchDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UISearchController *searchController;
@property (nonatomic, assign)CLLocationCoordinate2D currentLocationCoordinate;
@property (nonatomic, strong)NSString *addressString;
@property (nonatomic, strong)MAMapView * mapView;
@property (nonatomic, strong)AMapLocationManager *locationManager;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic,strong)AMapSearchAPI *mapSearch;
@property (nonatomic,strong)NSArray *dataArray;
@property (nonatomic ,strong)AMapPOIAroundSearchRequest *request;
@property (nonatomic ,assign)NSInteger currentPage;
@property (nonatomic ,assign)BOOL isSelectedAddress;
@property (nonatomic ,strong)NSIndexPath *selectedIndexPath;
@property (nonatomic ,strong)NSString *city;//定位的当前城市，用于搜索功能
@property (nonatomic, strong) UIButton *localButton;
@property (nonatomic ,strong)UITableView *searchTableView;//用于搜索的tableView
@property (nonatomic ,strong)NSArray *tipsArray;//搜索提示的数组

@property (nonatomic ,strong)AMapPOI *currentPOI;//点击选择的当前的位置插入到数组中


@end

@implementation ChoosePoiViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.title = @"定位";
    
    self.currentPage = 1;
    
    [self setUpSearchController];
    
    [self initMapView];
    
    [self.view addSubview:self.tableView];
    
    [self configLocationManager];
    
    [self locateAction];
    
    [self setupNav];
    
    self.mapSearch = [[AMapSearchAPI alloc] init];
    self.mapSearch.delegate = self;
    
    self.request = [[AMapPOIAroundSearchRequest alloc] init];
    self.request.types  = @"商务住宅|餐饮服务|生活服务";
    /* 按照距离排序. */
    self.request.sortrule = 0;
    self.request.offset = 50;
    self.request.requireExtension = YES;
    self.selectedIndexPath=[NSIndexPath indexPathForRow:-1 inSection:-1];
}
// 设置搜索框
- (void)setUpSearchController
{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    UISearchBar *bar = self.searchController.searchBar;
    bar.frame = CGRectMake(0, 0, KWidth, 44);
    bar.barStyle = UIBarStyleDefault;
    bar.translucent = YES;
    bar.showsBookmarkButton = NO;
    bar.barTintColor = [UIColor groupTableViewBackgroundColor];
    bar.tintColor = [UIColor blackColor];
    UIImageView *view = [[[bar.subviews objectAtIndex:0] subviews] firstObject];
    view.layer.borderColor = [UIColor darkGrayColor].CGColor;
    view.layer.borderWidth = 0.7;
    UITextField *searchField = [bar valueForKey:@"searchField"];
    searchField.placeholder = @"搜索地点";
    UIButton *cancleBtn = [bar valueForKey:@"cancelButton"];
    [cancleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if (searchField) {
        [searchField setBackgroundColor:[UIColor whiteColor]];
        searchField.layer.cornerRadius = 3.0f;
        searchField.layer.borderColor = RGBACOLOR(100, 100, 100, 0.7).CGColor;
        searchField.layer.borderWidth = 0.7;
    }
    
    [self.view addSubview:bar];
}

- (void)initMapView
{
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 44, KWidth, self.view.height * 0.7)];
    self.mapView.delegate = self;
    self.mapView.mapType = MAMapTypeStandard;
    self.mapView.showsUserLocation = YES;
    self.mapView.showsCompass = YES;
    self.mapView.showsScale = YES;
    [self.view addSubview:self.mapView];
    
    UIButton *localButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [localButton addTarget:self action:@selector(localButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [localButton setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    [self.mapView addSubview:localButton];
    self.localButton = localButton;
}

- (void)setupNav
{
    UIBarButtonItem *rightBBI = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(sendLocation)];
    [rightBBI setTitleTextAttributes:@{NSFontAttributeName: JTFont(18.0f),
                                       NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightBBI;
}

- (UITableView *)tableView{
    if (_tableView == nil) {
        NSLog(@"%@", self.mapView);
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.height * 0.7, KWidth, self.view.height * 0.3) style:UITableViewStylePlain];
        _tableView.rowHeight = 60.0f;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            self.currentPage ++ ;
            self.request.page = self.currentPage;
            self.request.location = [AMapGeoPoint locationWithLatitude:self.currentLocationCoordinate.latitude longitude:self.currentLocationCoordinate.longitude];
            [self.mapSearch AMapPOIAroundSearch:self.request];
        }];
    }
    return _tableView;
}

- (UITableView *)searchTableView{
    if (_searchTableView == nil) {
        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, KWidth, KHeight - 64) style:UITableViewStylePlain];
        _searchTableView.delegate = self;
        _searchTableView.dataSource = self;
        _searchTableView.tableFooterView = [UIView new];
    }
    return _searchTableView;
}

// 定位SDK

- (void)configLocationManager {
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [self.locationManager setLocationTimeout:6];
    [self.locationManager setReGeocodeTimeout:3];
}

- (void)locateAction
{
    [SVProgressHUD showWithStatus:@"正在定位..."];
    //带逆地理的单次定位
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"定位错误"];
            NSLog(@"locError:{%ld - %@};",(long)error.code,error.localizedDescription);
            if (error.code == AMapLocationErrorLocateFailed) {
                return ;
            }
        }
        //定位信息
        NSLog(@"location:%@", location);
        if (regeocode)
        {
            [SVProgressHUD dismiss];
            self.currentLocationCoordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            self.addressString = regeocode.formattedAddress;
            self.city = regeocode.city;
            [self showMapPoint];
            [self setCenterPoint];
            self.request.location = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
            [self.mapSearch AMapPOIAroundSearch:self.request];
        }
    }];
}


- (void)showMapPoint{
    [_mapView setZoomLevel:15.1 animated:YES];
    [_mapView setCenterCoordinate:self.currentLocationCoordinate animated:YES];
}

- (void)setCenterPoint{
    MAPointAnnotation * centerAnnotation = [[MAPointAnnotation alloc] init];//初始化注解对象
    centerAnnotation.coordinate = self.currentLocationCoordinate;//定位经纬度
    centerAnnotation.title = @"";
    centerAnnotation.subtitle = @"";
    [self.mapView addAnnotation:centerAnnotation];//添加注解
}

#pragma mark - MAMapView Delegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorRed;
        return annotationView;
    }
    return nil;
}


- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    CLLocationCoordinate2D centerCoordinate = mapView.region.center;
    self.currentLocationCoordinate = centerCoordinate;
    
    MAPointAnnotation * centerAnnotation = [[MAPointAnnotation alloc] init];
    centerAnnotation.coordinate = centerCoordinate;
    centerAnnotation.title = @"";
    centerAnnotation.subtitle = @"";
    [self.mapView addAnnotation:centerAnnotation];
    //主动选择地图上的地点
    if (!self.isSelectedAddress) {
        [self.tableView setContentOffset:CGPointMake(0,0) animated:NO];
        self.selectedIndexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        self.request.location = [AMapGeoPoint locationWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
        self.currentPage = 1;
        self.request.page = self.currentPage;
        [self.mapSearch AMapPOIAroundSearch:self.request];
    }
    self.isSelectedAddress = NO;
    
}


#pragma mark -AMapSearchDelegate
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    NSMutableArray *remoteArray = response.pois.mutableCopy;
    if (self.currentPOI) {
        [remoteArray insertObject:self.currentPOI atIndex:0];
    }
    if (self.currentPage == 1) {
        self.dataArray = remoteArray.copy;
    }else{
        NSMutableArray * moreArray = self.dataArray.mutableCopy;
        [moreArray addObjectsFromArray:remoteArray];
        self.dataArray = moreArray.copy;
    }
    
    if (response.pois.count< 50) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else{
        [self.tableView.mj_footer endRefreshing];
    }
    [self.tableView reloadData];
    
    
}

- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response{
    
    self.tipsArray = response.tips;
    [self.searchTableView reloadData];
    
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        return self.dataArray.count;
    }else{
        return self.tipsArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"POITableViewCell";
    POITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellID owner:nil options:nil] firstObject];
    }
    if (tableView == self.tableView) {
        AMapPOI *POIModel = self.dataArray[indexPath.row];
        cell.nameLabel.text = POIModel.name;
        cell.addressLabel.text = [NSString stringWithFormat:@"%@%@%@%@",POIModel.province,POIModel.city,POIModel.district,POIModel.address];
        if (indexPath.row==self.selectedIndexPath.row){
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType=UITableViewCellAccessoryNone;
        }
    }else{
        AMapTip *tipModel = self.tipsArray[indexPath.row];
        cell.nameLabel.text = tipModel.name;
        cell.addressLabel.text = [NSString stringWithFormat:@"%@%@",tipModel.district,tipModel.address];
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableView == tableView) {
        return 60;
    }
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableView == tableView) {
        self.selectedIndexPath=indexPath;
        [tableView reloadData];
        AMapPOI *POIModel = self.dataArray[indexPath.row];
        CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(POIModel.location.latitude, POIModel.location.longitude);
        [_mapView setCenterCoordinate:locationCoordinate animated:YES];
        self.isSelectedAddress = YES;
    }else{
        self.searchController.active = NO;
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        AMapTip *tipModel = self.tipsArray[indexPath.row];
        CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(tipModel.location.latitude, tipModel.location.longitude);
        [_mapView setCenterCoordinate:locationCoordinate animated:YES];
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        AMapPOI *POIModel = [AMapPOI new];
        POIModel.address = [NSString stringWithFormat:@"%@%@",tipModel.district,tipModel.address];
        POIModel.location = tipModel.location;
        POIModel.name = tipModel.name;
        self.currentPOI = POIModel;
        [self.tableView reloadData];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == self.searchTableView) {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.tableView.frame = CGRectMake(0, CGRectGetHeight(self.mapView.frame) + 1, KWidth, CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.mapView.frame) - 1);
    self.localButton.frame = CGRectMake(KWidth - 50, CGRectGetHeight(self.mapView.frame) - 44 - 50, 40, 40);
}


#pragma mark - UISearchControllerDelegate && UISearchResultsUpdating

//谓词搜索过滤
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (searchController.searchBar.text.length == 0) {
        return;
    }
    [self.view addSubview:self.searchTableView];
    AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
    tips.keywords = searchController.searchBar.text;
    tips.city = self.city;
    [self.mapSearch AMapInputTipsSearch:tips];
    
}

#pragma mark - UISearchControllerDelegate代理
- (void)willPresentSearchController:(UISearchController *)searchController{
    self.searchController.searchBar.frame = CGRectMake(0, 0, self.searchController.searchBar.frame.size.width, 44.0);
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.mapView.frame = CGRectMake(0, 64, KWidth, 300);
    
}
- (void)willDismissSearchController:(UISearchController *)searchController{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent ];
}


- (void)didDismissSearchController:(UISearchController *)searchController{
    self.searchController.searchBar.frame = CGRectMake(0, 64, self.searchController.searchBar.frame.size.width, 44.0);
    self.mapView.frame = CGRectMake(0, 64 + 44, KWidth, 300);
    
    [self.searchTableView removeFromSuperview];
}

#pragma mark - buttonAction
- (void)sendLocation
{
    AMapPOI *POIModel = self.dataArray[self.selectedIndexPath.row];
    
    NSDictionary *addressDict = @{@"lat":@(POIModel.location.latitude),
                                  @"lon":@(POIModel.location.longitude),
                                  @"position":[NSString stringWithFormat:@"%@%@%@%@",POIModel.province,POIModel.city,POIModel.district,POIModel.address],
                                  @"adCode":POIModel.adcode
                                  };
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:addressDict options:NSJSONWritingPrettyPrinted error:&error];
    if (!error) {
        NSString *addressStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        if (self.poiResultCallback) {
            self.poiResultCallback(addressStr);
        }
    }
    
#if 0
    NSString *address = [NSString stringWithFormat:@"lat:%f,lon:%f,position:%@%@%@%@,adCode:%@",
                         POIModel.location.latitude,
                         POIModel.location.longitude,
                         POIModel.province,
                         POIModel.city,
                         POIModel.district,
                         POIModel.address,
                         POIModel.adcode];
    if (self.poiResultCallback) {
        self.poiResultCallback(address);
    }
#endif
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)localButtonAction
{
    [self locateAction];
}


@end

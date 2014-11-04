//
//  TableViewController.m
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/10/29.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import "TableViewController.h"
#import "ChatData.h"
#import "Constants.h"
#import "ParseChat.h"
#import "PostParameter.h"
#import "ChatboxPopOverController.h"
#import <QuartzCore/QuartzCore.h>

@interface TableViewController ()



@property (strong,nonatomic) NSMutableArray *chats;

//Session
@property (strong,nonatomic) NSURLSession *thisSession;
@property (strong,nonatomic) NSURL *thisUrl;
@property (strong,nonatomic) NSData *data;
@property (strong,nonatomic) NSData *credential;
@property (strong,nonatomic) NSString *target;
@property (strong,nonatomic) NSURLSessionDataTask *dataTask;
@property (nonatomic) BOOL isCompleted;
@property (strong,nonatomic) NSMutableData *tempData;
@property (strong,nonatomic) ParseChat *parse;
@property (strong,nonatomic) PostParameter* param;
@property (strong,nonatomic) NSString *sToken;
@property (nonatomic) BOOL isSessionTimeout;
@property (nonatomic,strong) NSDate *toDate;

@property (nonatomic,strong) ChatboxPopOverController *chatboxVC;

@property (nonatomic,strong) UIView *customView;

@property (strong,nonatomic) NSMutableString *chatContent;

@end
@implementation TableViewController

@synthesize pullTableView = _pullTableView;

#pragma mark timer
//Resource Leak
//- (void)timerFireMethod:(NSTimer*)theTimer
//{
//    
//
//    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:self.toDate];
//    //NSLog(@"%f",seconds);
//
//    //NSLog(@"%@",self.toDate.debugDescription);
//    
//    while (seconds >= 0.0) {
//        self.isSessionTimeout = YES;
//        [theTimer invalidate];
//        theTimer = nil;
//    }
//}


-(NSString *)sToken{
    if (!_sToken || self.isSessionTimeout) {
        
        NSURL *url1 = [NSURL URLWithString:@"http://www.xbox-skyer.com/login.php"];
        NSMutableURLRequest *requestLogin = [[NSMutableURLRequest alloc]initWithURL:url1 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
        [requestLogin setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
        NSString *str1 = @"do=login&vb_login_username=sheldonlc&vb_login_password=yb830922&cookieuser=1";//设置参数
        NSData *data1 = [str1 dataUsingEncoding:NSUTF8StringEncoding];
        [requestLogin setHTTPBody:data1];
        NSData *received1 = [NSURLConnection sendSynchronousRequest:requestLogin returningResponse:nil error:nil];
        NSString *strResult1 = [[NSString alloc]initWithData:received1 encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@",strResult1);

        
        _sToken = [self.parse parseHTMLDataForAccess:received1];
        
        self.isSessionTimeout = NO;
        
        //Resource leak
        //self.toDate = [[NSDate alloc] initWithTimeInterval:10 sinceDate:[NSDate date]];
        
        //[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
        

    }
    return _sToken;
    
}
-(PostParameter *)param{
    if(!_param){
        _param = [[PostParameter alloc]init];
    }
    return _param;
}

#pragma mark - Session
-(NSURLSession *)thisSession
{
    if(!_thisSession ){
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _thisSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        //[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    }
    return _thisSession;
}



- (NSArray *)parseData
{
    NSArray *result = nil;
    if ([self.target isEqualToString:HTML_REQUEST_TARGET_CURRENT]) {
        result = [self.parse parseXMLDataForCurrentChat:self.data];
        
    }else if([self.target isEqualToString:HTML_REQUEST_TARGET_HISTORY]){
        result = [self.parse parseHTMLDataForHistory:self.data];
    }
    
    return result;

}
#pragma mark - Generate the data
- (ParseChat *)parse
{
    if(!_parse){
        _parse = [[ParseChat alloc]init];
    }
    return _parse;
}
-(NSMutableArray *)chats{
    if(!_chats){
        _chats = [[NSMutableArray alloc]initWithCapacity:50];
    }
    return _chats;
}



#pragma mark - View Init
     
-(void) setURLwith: (NSString *) target forPage :(NSString *) page
{
    NSMutableString *url = nil;
    if ([target isEqualToString:HTML_REQUEST_TARGET_HISTORY]) {
        url = [[NSMutableString alloc] initWithString:@"http://www.xbox-skyer.com/chat.php?do=view_archives&page="];
        [url appendString:page];
        [url appendString:@"&styleid=47"];
    }else if([target isEqualToString:HTML_REQUEST_TARGET_CURRENT]){
        url = [[NSMutableString alloc] initWithString:@"http://www.xbox-skyer.com/mgc_cb_evo_ajax.php"];
    }else if([target isEqualToString:HTML_REQUEST_TYPE_LOGIN]){
        url = [[NSMutableString alloc] initWithString:@"http://www.xbox-skyer.com/login.php"];
    }

    
    self.thisUrl = [[NSURL alloc] initWithString:url];
    self.target = target;
}


-(void) setURLwith: (NSString *) target {
    [self setURLwith:target forPage:@"1"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.pullTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.pullTableView.backgroundColor = [UIColor colorWithRed:0.859f green:0.886f blue:0.929f alpha:1.0f];


    //init the setup for pop over controller
    

    self.chatboxVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatboxPopOverController"];
    
    [self setChatboxView];
    
    self.chatboxVC.chatbox.delegate = self;
    self.chatContent = [[NSMutableString alloc] init];
    //Add the customView to the current view
    
    
    self.pullTableView.pullArrowImage = [UIImage imageNamed:@"blackArrow"];
    self.pullTableView.pullBackgroundColor = [UIColor whiteColor];
    self.pullTableView.pullTextColor = [UIColor grayColor];

    __weak TableViewController *weakSelf = self;
    self.pullTableView.pullDelegate = weakSelf;

}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    if(!self.pullTableView.pullTableIsRefreshing) {
        self.pullTableView.pullTableIsRefreshing = YES;
        [self performSelector:@selector(loadMoreDataToTable) withObject:nil afterDelay:0.0f];
    }
}

- (void)viewDidUnload
{
    [self setPullTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    [self performSelector:@selector(refreshTable) withObject:nil afterDelay:1.0f];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [self performSelector:@selector(loadMoreDataToTable) withObject:nil afterDelay:1.0f];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) refreshTable
{
    /*
     
     Code to actually refresh goes here.
     
     */
    
    self.pullTableView.pullLastRefreshDate = [NSDate date];
    self.pullTableView.pullTableIsRefreshing = NO;

}

- (void) loadMoreDataToTable
{
    /*
     
     Code to actually load more data goes here.
     
     */
    
    
    [self startRequestDataFrom:HTML_REQUEST_TARGET_CURRENT forType:HTML_REQUEST_TYPE_REFRESH];
    if (!self.chats || [self.chats count] ==0) {
        self.isSessionTimeout = YES;
        [self startRequestDataFrom:HTML_REQUEST_TARGET_CURRENT forType:HTML_REQUEST_TYPE_REFRESH];
        
    }

    
    self.pullTableView.pullTableIsLoadingMore = NO;
}


#define HEIGHT_PATCH_4_0_INCH 60
#define HEIGHT_PATCH_9_7_INCH 420
#define HEIGHT_PATCH_7_9_INCH 330
#define HEIGHT_PATCH_3_5_INCH 0
#define HEIGHT_PATCH_4_7_INCH 180
#define HEIGHT_PATCH_5_5_INCH 220



- (void) keyboardWasShown:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    NSLog(@"keyBoard:%f", keyboardSize.height);  //216
    CGRect newTextViewFrame = self.view.bounds;
    CGFloat keyboardTop =  keyboardSize.height;
    CGRect keyboardRect = [value CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];

    if (newTextViewFrame.size.height == 1024) {
        //Ipad
        newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y+HEIGHT_PATCH_9_7_INCH;
    }else if (newTextViewFrame.size.height == 480) {
        //Iphone 4/4s
        newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y+HEIGHT_PATCH_3_5_INCH;
    }else if (newTextViewFrame.size.height == 568) {
        //Iphone 5/5s, ipod touch
        newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y+HEIGHT_PATCH_4_0_INCH;
    }else if (newTextViewFrame.size.height == 667) {
        //Iphone 5/5s, ipod touch
        newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y+HEIGHT_PATCH_4_7_INCH;
    }else if (newTextViewFrame.size.height == 736) {
        //Iphone 5/5s, ipod touch
        newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y+HEIGHT_PATCH_5_5_INCH;
    }
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.customView.frame = newTextViewFrame;
    [UIView commitAnimations];

}
- (void) keyboardWasHidden:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    NSLog(@"keyboardWasHidden keyBoard:%f", keyboardSize.height);
    NSValue *animationDurationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.customView.frame = self.view.bounds;
    
    [UIView commitAnimations];

    
}

- (void) setChatboxView{
    self.customView = self.chatboxVC.view; //<- change to where you want it to show.
    
    //Set the customView properties
    self.customView.alpha = 0.0;
    self.customView.layer.cornerRadius = 5;
    self.customView.layer.borderWidth = 1.5f;
    self.customView.layer.masksToBounds = YES;
    
    self.customView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    CGRect viewFrame = self.view.frame;
    CGRect viewBound= self.view.bounds;
    
    
    CGFloat height =  CGRectGetHeight(viewFrame);
    [self.customView setFrame:CGRectMake(0, CGRectGetHeight(viewFrame)-50-44, CGRectGetWidth(viewFrame), 50)];

}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        #warning send message here
        NSLog(@"%@",self.chatContent);
        [self sendMessage];
        self.chatContent = [[NSMutableString alloc] init];

        return NO;
    }
    [self.chatContent appendString:text];
    return YES;
}


- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    NSDictionary *userInfo = [notification userInfo];
    
     //Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
     //Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = 216;
    NSLog(@"%f",keyboardTop);
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.customView.frame = newTextViewFrame;
    [UIView commitAnimations];
}

- (IBAction)showChat:(id)sender {
    //Display the customView with animation

    [self.customView removeFromSuperview];
    [self setChatboxView];
    [self.view.superview addSubview:self.customView];
    [self.view.superview bringSubviewToFront: self.customView];

    [UIView animateWithDuration:0.6 animations:^{
        [self.customView setAlpha:1.0];
    } completion:^(BOOL finished) {}];
    

}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.customView.frame = self.view.bounds;
    
    [UIView commitAnimations];
}






/*
-(void)viewWillAppear:(BOOL)animated { [super viewWillAppear:animated];
    
    //Initialize the toolbar
     self.toolbar = [[UIToolbar alloc] init];
    self.toolbar.barStyle = UIBarStyleDefault;
    
    //Set the toolbar to fit the width of the app.
    [self.toolbar sizeToFit];
    
    //Caclulate the height of the toolbar
    CGFloat toolbarHeight = [self.toolbar frame].size.height;
    
    //Get the bounds of the parent view
    CGRect rootViewBounds = self.parentViewController.view.bounds;
    
    //Get the height of the parent view.
    CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
    
    //Get the width of the parent view,
    CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
    
    //Create a rectangle for the toolbar
    CGRect rectArea = CGRectMake(0, rootViewHeight - toolbarHeight, rootViewWidth, toolbarHeight);
    
    //Reposition and resize the receiver
    [self.toolbar setFrame:rectArea];
    
    //Create a button
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStyleBordered target:self action:@selector(info_clicked:)];
    
    [self.toolbar setItems:[NSArray arrayWithObjects:infoButton,nil]];
    
    //Add the toolbar as a subview to the navigation controller.
    [self.navigationController.view addSubview:self.toolbar];
    
    [[self tableView] reloadData];
    
}

- (void) info_clicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.toolbar removeFromSuperview];
    
}
*/
- (void) appearAtBottom{
    CGFloat contentHeight = self.pullTableView.contentSize.height;
    CGFloat frameHeight = self.pullTableView.frame.size.height;
    
    if (contentHeight > frameHeight)
    {
        CGPoint offset = CGPointMake(0, contentHeight - frameHeight+44);
        [self.pullTableView setContentOffset:offset animated:NO];
    }
    
    
}





- (void)reloadView{
    
    [self.pullTableView reloadData];
    [self appearAtBottom];


}

- (void) startRequestDataFrom: (NSString *) target forType: (NSString *) type{
    [self startRequestDataFrom:target forPage:@"" forType:type];
}

- (void) startRequestDataFrom: (NSString *) target forPage : (NSString *) page forType: (NSString *) type{
    [self setURLwith:target];
    
    __weak TableViewController *weakSelf = self;
    self.dataTask = [self.thisSession dataTaskWithRequest:[self requestWithURL:self.thisUrl forType:type] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //NSLog(@"%lld", response.expectedContentLength);
        weakSelf.tempData = [[NSMutableData alloc]init];
        
        [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
            
            [weakSelf.tempData appendBytes:bytes length:byteRange.length];
        }];
        weakSelf.data = weakSelf.tempData;
        if ([target isEqualToString:HTML_REQUEST_TARGET_HISTORY]) {
            [weakSelf insertCells:[weakSelf parseData]];
        }else if([target isEqualToString:HTML_REQUEST_TARGET_CURRENT]){
            [weakSelf appendCells:[weakSelf parseData]];
        }
        //[self.chats addObjectsFromArray:];
        [weakSelf reloadView];
        
    }];
    [self.dataTask resume];
}


- (void) appendCells:(NSArray *) result{
    if(!self.chats || [self.chats count]==0){
        //Append directly when initialize
        [self.chats addObjectsFromArray:[self parseData]];
    }else{
        //Compare the chatid, append the newly added chats
        ChatData *latestChat = [self.chats lastObject];
        
        ChatData *newLastChat = [result lastObject];
        if(![newLastChat newerThan:latestChat]){
            return;//no updates
        }
        for (ChatData *chat in result) {
            if([chat newerThan:latestChat]){
                [self.chats addObject:chat];
            }
        }
    }
}

- (void) insertCells:(NSArray *) result{
    if(!self.chats || [self.chats count]==0){
        //Append directly when initialize
        [self.chats addObjectsFromArray:[self parseData]];
    }else{
        //Compare the chatid, append the newly added chats
        ChatData *oldestCurrentChat = [self.chats firstObject];
        
        ChatData *newestHistoryChat = [result lastObject];
        
        if([newestHistoryChat olderThan:oldestCurrentChat]){
            return;// no history found;
        }
        //Reverse enmueator
        NSEnumerator *enumerator = [result objectEnumerator];
        ChatData *chat;
        while ((chat = [enumerator nextObject]) != nil) {
            if([chat olderThan:oldestCurrentChat]){
                [self.chats insertObject: chat atIndex:0];
                oldestCurrentChat = [self.chats firstObject];
            }
        }
    }

}

- (void) sendMessage{
    [self setURLwith:HTML_REQUEST_TARGET_CURRENT];
    __weak TableViewController *weakSelf = self;

    self.dataTask = [self.thisSession dataTaskWithRequest:[self requestWithURL:self.thisUrl forType:HTML_REQUEST_TYPE_CHAT] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //NSLog(@"%lld", response.expectedContentLength);
        weakSelf.tempData = [[NSMutableData alloc]init];
        
        [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
         
        [weakSelf.tempData appendBytes:bytes length:byteRange.length];  }];
        weakSelf.data = weakSelf.tempData;
        if ([weakSelf.tempData length] != 112) {
            weakSelf.isSessionTimeout = YES;
        }
        
    }];
    [self.dataTask resume];

    
    if(self.isSessionTimeout){
        self.dataTask = [self.thisSession dataTaskWithRequest:[self requestWithURL:self.thisUrl forType:HTML_REQUEST_TYPE_CHAT] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            //NSLog(@"%lld", response.expectedContentLength);
            weakSelf.tempData = [[NSMutableData alloc]init];
            
            [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
                
            [weakSelf.tempData appendBytes:bytes length:byteRange.length];  }];
            weakSelf.data = weakSelf.tempData;
            if ([weakSelf.tempData length] != 112) {
                weakSelf.isSessionTimeout = YES;
            }
            
        }];
        [self.dataTask resume];

    }

    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:0.6f];

}
- (void)delayMethod {
    [self startRequestDataFrom:HTML_REQUEST_TARGET_CURRENT forType:HTML_REQUEST_TYPE_REFRESH];
}

- (NSMutableURLRequest *) requestWithURL:(NSURL *)URL forType:(NSString *) type
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.thisUrl];
    if([type isEqualToString:HTML_REQUEST_TYPE_REFRESH]){
        if([self.target isEqualToString:HTML_REQUEST_TARGET_CURRENT]){
            //To get curreny chat, use post
            [request setHTTPMethod:@"POST"];
            
            NSString *str = [self.param generateRefreshWithToken: self.sToken];//Set parameter
            NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
        }
    }else if([type isEqualToString:HTML_REQUEST_TYPE_LOGIN]){
        
        [request setHTTPMethod:@"POST"];
        #warning need to use the login textbox for user/password
        NSString *str = [self.param generateLoginWithUser:@"SheldonLC" withPassword:@"yb830922"];//Set parameter
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        
    }else if([type isEqualToString:HTML_REQUEST_TYPE_CHAT]){
        [request setHTTPMethod:@"POST"];
        #warning need to use textboxinput for chat
        NSString *str = [self.param generateChatWithToken:self.sToken withChat:self.chatContent];//Set parameter
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];

    }
    return request;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(CGSize)frameForText:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode  {
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = lineBreakMode;
    
    NSDictionary * attributes = @{NSFontAttributeName:font,
                                  NSParagraphStyleAttributeName:paragraphStyle
                                  };
    
    
    CGRect textRect = [text boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
    
    //Contains both width & height ... Needed: The height
    return textRect.size;
}



#pragma mark Table view methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.chats count];
}


- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
    if (action == @selector(copy:)) {
        
        [UIPasteboard generalPasteboard].string = [self.chats  objectAtIndex:indexPath.row];
        
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"chat";
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        cell.backgroundColor = [UIColor colorWithRed:0.859f green:0.886f blue:0.929f alpha:1.0f];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    ChatData *chat = [self.chats objectAtIndex:indexPath.row];

    cell.textLabel.text = chat.content;    //[cell.contentView addSubview:chatView];
    return cell;
}

- (NSString *) generateCell:(ChatData *) chat
{
    return [NSString stringWithFormat:@"%@ %@ : %@",chat.dateString,chat.speaker,chat.content];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

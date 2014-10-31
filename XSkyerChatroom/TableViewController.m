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

@interface TableViewController ()



@property (strong,nonatomic) NSMutableArray *chats;
@property (strong,nonatomic) ParseChat *parseChat;

//Session
@property (strong,nonatomic) NSURLSession *thisSession;
@property (strong,nonatomic) NSURL *thisUrl;
@property (strong,nonatomic) NSData *data;
@property (strong,nonatomic) NSString *target;
@property (strong,nonatomic) NSURLSessionDataTask *dataTask;
@property (nonatomic) BOOL isCompleted;
@property (strong,nonatomic) NSMutableData *tempData;
@property (strong,nonatomic) ParseChat *parse;
@end

@implementation TableViewController

#pragma mark - Session
-(NSURLSession *)thisSession
{
    if(!_thisSession){
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _thisSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _thisSession;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSLog(@"### handler 1");
    
    completionHandler(NSURLSessionResponseAllow);
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    self.tempData = [[NSMutableData alloc]init];

    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        
        [self.tempData appendBytes:bytes length:byteRange.length];
    }];
    self.data = self.tempData;
}
//
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    //NSLog(@"********************** error is : %@ **********",[error debugDescription]);
    
    [self.chats addObjectsFromArray:[self parseData]];

    [self.tableView reloadData];
    [self.dataTask cancel];
    [self.thisSession invalidateAndCancel];
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
    }
    
    self.thisUrl = [[NSURL alloc] initWithString:url];
    self.target = target;
}


-(void) setURLwith: (NSString *) target {
    [self setURLwith:target forPage:@"1"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setURLwith:HTML_REQUEST_TARGET_CURRENT];
    
    self.dataTask = [self.thisSession dataTaskWithRequest:[self requestWithURL:self.thisUrl] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //NSLog(@"%lld", response.expectedContentLength);
        self.tempData = [[NSMutableData alloc]init];
        
        [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
            
            [self.tempData appendBytes:bytes length:byteRange.length];
        }];
        self.data = self.tempData;
        
        [self.chats addObjectsFromArray:[self parseData]];
        
        [self.tableView reloadData];

    }];
    
    [self.dataTask resume];
}

- (NSMutableURLRequest *) requestWithURL:(NSURL *)URL
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.thisUrl];
    if([self.target isEqualToString:HTML_REQUEST_TARGET_CURRENT]){
        //To get curreny chat, use post
        [request setHTTPMethod:@"POST"];
        NSString *str = @"do=ajax_refresh_chat&chatids=50";//Set parameter
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.chats count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chat" forIndexPath:indexPath];
    
    // Configure the cell...
    ChatData *chat = [self.chats objectAtIndex:indexPath.row];
    cell.textLabel.text = [self generateCell:chat];
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

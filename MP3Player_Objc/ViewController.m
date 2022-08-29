//
//  ViewController.m
//  MP3Player_Objc
//
//  Created by MCNC on 2022/08/16.
//

#import "ViewController.h"
#import "MusicPlayerViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)clickOpenMP3Player:(id)sender {
    //Set Music List Array
    NSArray* musicArr = @[@{@"name" : @"music1"}, @{@"name" : @"music2"}, @{@"name" : @"music3"}, @{@"name" : @"music4"}, @{@"name" : @"music5"}];
    
    //Create Music Player Controller
    MusicPlayerViewController* player = [[MusicPlayerViewController alloc] init];
    player.modalPresentationStyle = UIModalPresentationFullScreen;
    player.musicInfoList = musicArr;
    
    [self presentViewController:player animated:YES completion:nil];
    
}

@end

//
//  MusicPlayerViewController.h
//  MP3Player_Objc
//
//  Created by MCNC on 2022/08/16.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MusicPlayerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate>

//Music List
@property (nonatomic, copy) NSArray* musicInfoList;

//UI Outlet
@property (weak, nonatomic) IBOutlet UILabel *currentMusicName;
@property (weak, nonatomic) IBOutlet UITableView *musicListView;
@property (weak, nonatomic) IBOutlet UISlider *musicSlider;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *repeatBtn;
@property (weak, nonatomic) IBOutlet UIImageView *beforeBtn;
@property (weak, nonatomic) IBOutlet UIImageView *nextBtn;
@property (weak, nonatomic) IBOutlet UIImageView *playBtn;

- (IBAction)tapChangeSliderValue:(id)sender;
@end

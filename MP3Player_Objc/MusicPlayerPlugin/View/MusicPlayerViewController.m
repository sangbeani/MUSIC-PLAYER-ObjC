//
//  MusicPlayerViewController.m
//  MP3Player_Objc
//
//  Created by MCNC on 2022/08/16.
//

#import "MusicPlayerViewController.h"
#import "MusicPlayerTableCell.h"

@interface MusicPlayerViewController ()
{
    AVAudioPlayer *player;
    NSInteger repeat;
    NSURL* musicURL;
    NSMutableArray* cellArr;
    int musicIndex;
}

@end

@implementation MusicPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self remoteCommandCenterSetting];
    [self configure];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    MusicPlayerTableCell* currentCell = [cellArr objectAtIndex:musicIndex];
    currentCell.musicName.font = [UIFont boldSystemFontOfSize:currentCell.musicName.font.pointSize];
}

- (void)setup {
    //View
    CAGradientLayer* gradient = [[CAGradientLayer alloc] init];
    gradient.colors = @[(id)[self colorWithHexString:@"737373"].CGColor, (id)[self colorWithHexString:@"2f2f2f"].CGColor];
    gradient.frame = self.view.frame;
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    /*Repeat Button
     0 > 기본 재생
     1 > 전체 반복
     2 > 한곡 반복
     */
    repeat = 0;
    cellArr = [NSMutableArray new];
    
    //Current Music
    musicIndex = 0;
    NSString* currentMusicName = [[self.musicInfoList firstObject] objectForKey:@"name"];
    self.currentMusicName.text = currentMusicName;
    musicURL = [NSBundle.mainBundle URLForResource:currentMusicName withExtension:@"mp3"];
    
    //Update Music Time
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    
    //Music List
    [self.musicListView registerNib:[UINib nibWithNibName:@"MusicPlayerTableCell" bundle:nil] forCellReuseIdentifier:@"MusicPlayerTableCell"];
    self.musicListView.separatorColor = UIColor.clearColor;
    self.musicListView.delegate = self;
    self.musicListView.dataSource = self;
    
    //Click Event
    UITapGestureRecognizer* playPauseTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPlayPauseButton)];
    [self.playBtn addGestureRecognizer:playPauseTap];
    self.playBtn.userInteractionEnabled = YES;
    
    UITapGestureRecognizer* nextTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapNextButton)];
    [self.nextBtn addGestureRecognizer:nextTap];
    self.nextBtn.userInteractionEnabled = YES;
    
    UITapGestureRecognizer* beforeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBeforeButton)];
    [self.beforeBtn addGestureRecognizer:beforeTap];
    self.beforeBtn.userInteractionEnabled = YES;
    
    UITapGestureRecognizer* repeatTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapRepeatButton)];
    [self.repeatBtn addGestureRecognizer:repeatTap];
    self.repeatBtn.userInteractionEnabled = YES;
    
}

//MARK: - Music Player
- (void)configure {
    [self pauseMusic];
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
    player.delegate = self;
    player.volume = 0.5f;
    self.musicSlider.maximumValue = player.duration;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    self.durationTimeLabel.text = [self musicTimeFormatted:player.duration];
    
    [self playMusic];
}

- (void)didTapPlayPauseButton {
    if(player == nil) {
        return;
    }
    
    if(player.isPlaying == true) {
        [self pauseMusic];
    } else {
        [self playMusic];
    }
}

- (void)didTapNextButton {
    self.currentTimeLabel.text = @"00:00";
    [self nextMusic];
}

- (void)didTapBeforeButton {
    self.currentTimeLabel.text = @"00:00";
    [self beforeMusic];
}

- (void)didTapRepeatButton {
    switch(repeat) {
        case 0:
        case 3: {
            self.repeatBtn.image = [UIImage imageNamed:@"no_repeat"];
            repeat = 1;
        }
        break;
            
        case 1: {
            self.repeatBtn.image = [UIImage imageNamed:@"total_repeat"];
            repeat = 2;
        }
        break;
            
        case 2: {
            self.repeatBtn.image = [UIImage imageNamed:@"current_repeat"];
            repeat = 3;
        }
        break;
            
        default: return;
    }
}

- (void)playMusic {
    [self remoteCommandInfoCenterSetting];
    
    if(player == nil) {
        return;
    }
    
    self.playBtn.image = [UIImage imageNamed:@"pause_btn"];
    [player play];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)pauseMusic {
    if(player == nil) {
        return;
    }
    
    self.playBtn.image = [UIImage imageNamed:@"play_btn"];
    [self stopMusic];
}

- (void)nextMusic {
    if (musicIndex == self.musicInfoList.count-1) {
        musicIndex = 0;
    } else {
        musicIndex += 1;
    }
    
    [self setCurrentMusicAndPlay];
}

- (void)beforeMusic {
    musicIndex -= 1;
    [self setCurrentMusicAndPlay];
}

- (void)stopMusic {
    [player stop];
}

- (void)updateTime {
    if(player.isPlaying) {
        self.musicSlider.value = player.currentTime;
        NSString *time = [self musicTimeFormatted:self.musicSlider.value];
        self.currentTimeLabel.text = time;
    }
}

- (IBAction)tapChangeSliderValue:(id)sender {
    [self stopMusic];
    [player setCurrentTime:self.musicSlider.value];
    self.currentTimeLabel.text = [self musicTimeFormatted:self.musicSlider.value];
    [player prepareToPlay];
    [player play];
}

- (void)setCurrentMusicAndPlay{
    for(MusicPlayerTableCell* cell in cellArr) {
        cell.musicName.font = [UIFont systemFontOfSize:cell.musicName.font.pointSize];
    }
    
    if(musicIndex >= (int)self.musicInfoList.count - 1) {
        musicIndex = (int)self.musicInfoList.count - 1;
    } else if(musicIndex <= 0) {
        musicIndex = 0;
    }
    
    MusicPlayerTableCell* currentCell = [cellArr objectAtIndex:musicIndex];
    currentCell.musicName.font = [UIFont boldSystemFontOfSize:currentCell.musicName.font.pointSize];
    
    NSString* currentMusicName = [[self.musicInfoList objectAtIndex:musicIndex] objectForKey:@"name"];
    self.currentMusicName.text = currentMusicName;
    musicURL = [NSBundle.mainBundle URLForResource:currentMusicName withExtension:@"mp3"];
    
    [self configure];
}

- (void)remoteCommandCenterSetting{
    [UIApplication.sharedApplication beginReceivingRemoteControlEvents];
    
    MPRemoteCommandCenter* center = MPRemoteCommandCenter.sharedCommandCenter;
    
    //제어 센터 재생
    [center.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self playMusic];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    //제어 센터 멈춤
    [center.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self pauseMusic];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    //제어 센터 다음
    [center.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self nextMusic];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    //제어 센터 이전
    [center.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self beforeMusic];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
}

- (void)remoteCommandInfoCenterSetting{
    MPNowPlayingInfoCenter* center = MPNowPlayingInfoCenter.defaultCenter;
    NSMutableDictionary* nowPlayingInfo = [[NSMutableDictionary alloc] init];
    [nowPlayingInfo setObject:[[self.musicInfoList objectAtIndex:musicIndex] objectForKey:@"name"] forKey:MPMediaItemPropertyTitle];
    
    UIImage* coverImage = [UIImage imageNamed:@"play_bg"];
    MPMediaItemArtwork* musicImage = [[MPMediaItemArtwork alloc] initWithBoundsSize:coverImage.size requestHandler:^UIImage * _Nonnull(CGSize size) {
        return coverImage;
    }];
    [nowPlayingInfo setObject:musicImage forKey:MPMediaItemPropertyArtwork];
    [nowPlayingInfo setObject:@(player.duration) forKey:MPMediaItemPropertyPlaybackDuration];
    [nowPlayingInfo setObject:@(player.rate) forKey:MPNowPlayingInfoPropertyPlaybackRate];
    
    center.nowPlayingInfo = nowPlayingInfo;
}

//MARK: - ETC
-(NSString *)musicTimeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""]; // remove the #
    NSScanner *scanner = [NSScanner scannerWithString:noHashString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]]; // remove + and $

    unsigned hex;
    if (![scanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;

    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}

//MARK: - AVAudioPlayer Delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        switch(repeat) {
            case 0:
            case 1: {
                if (musicIndex == self.musicInfoList.count-1) {
                    [self stopMusic];
                } else {
                    [self nextMusic];
                }
            }
            break;
                
            case 2: {
                [self nextMusic];
            }
            break;
                
            case 3: {
                [self setCurrentMusicAndPlay];
            }
            break;
                
            default: return;
        }
    }
}

//MARK: - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.musicInfoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    NSDictionary* dic = [self.musicInfoList objectAtIndex:indexPath.row];
    
    MusicPlayerTableCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MusicPlayerTableCell" forIndexPath:indexPath];
    cell.musicName.text = [dic objectForKey:@"name"];
    
    //Save Cell
    [cellArr addObject:cell];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    musicIndex = (int)indexPath.item;
    
    //Set Bold Text
    for(MusicPlayerTableCell* cell in cellArr) {
        cell.musicName.font = [UIFont systemFontOfSize:cell.musicName.font.pointSize];
    }
    MusicPlayerTableCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.musicName.font = [UIFont boldSystemFontOfSize:cell.musicName.font.pointSize];
    
    //Set Selected Music And Play
    [self setCurrentMusicAndPlay];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = UIColor.clearColor;
}

@end

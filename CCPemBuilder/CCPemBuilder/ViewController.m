//
//  ViewController.m
//  CCPemBuilder
//
//  Created by Carven Chen on 2017/8/8.
//  Copyright © 2017年 com.carven. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak) IBOutlet NSButton *addBtn;

@property (nonatomic, strong) NSString *fullPath;

@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, strong) NSString *fileName;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    [self.addBtn setImage:[NSImage imageNamed:@"main_add_icon"]];
    
}



- (IBAction)addBtnClicked:(NSButton *)sender {
    
    __weak typeof(self) weakSelf = self;
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel beginWithCompletionHandler:^(NSInteger result) {
        
        if (result == 1) {
            
            NSURL *elemnet = [[panel URLs] firstObject];
            NSString *fullPath = [elemnet relativePath];
            
            weakSelf.fullPath = fullPath;
            weakSelf.filePath = [fullPath stringByDeletingLastPathComponent];
            
            NSString *fileName_ = fullPath.lastPathComponent;
            weakSelf.fileName = [fileName_ stringByDeletingPathExtension];
            
            [weakSelf starthandleP12File];
        }
    }];
}


- (void)starthandleP12File {
    
    [self getP12Password];
}

- (void)getP12Password {
    
    __weak typeof(self) weakSelf = self;
    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:@"确定"];
    [alert setMessageText:@"请输入p12文件密码"];
    [alert setAlertStyle:NSAlertStyleCritical];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [alert setAccessoryView:input];
    
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertFirstButtonReturn){
            NSLog(@"确定");
            
            if (input.stringValue.length > 0) {
                
                NSString *password = input.stringValue;
                
                NSString *cmdStr = [NSString stringWithFormat:@"openssl pkcs12 -clcerts -nokeys -out %@/%@.pem -in %@ -password pass:%@", _filePath, _fileName, _fullPath, password];
                NSLog(@"%@", cmdStr);
                system([cmdStr UTF8String]);
                
                [weakSelf setPemPassword:password];
            }
            
            
        }else if(returnCode == NSAlertSecondButtonReturn){
            NSLog(@"删除");
        }
    }];
}


- (void)setPemPassword:(NSString *)password {
    
    
    __weak typeof(self) weakSelf = self;
    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:@"确定"];
    [alert setMessageText:@"请输入您想设置的pem密码"];
    [alert setAlertStyle:NSAlertStyleCritical];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    input.placeholderString = @"请输入您想设置的pem密码";
    [alert setAccessoryView:input];
    
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertFirstButtonReturn){
            NSLog(@"确定");
            
            if (input.stringValue.length > 0) {
                
                NSString *cmdStr = [NSString stringWithFormat:@"openssl pkcs12 -nocerts -out %@/%@_key.pem -in %@ -passin pass:%@ -passout pass:%@", _filePath, _fileName, _fullPath, password, input.stringValue];
                NSLog(@"%@", cmdStr);
                system([cmdStr UTF8String]);
                
                [weakSelf unitPemFile];
            }
            else {
                
                
            }
        }
    }];
}

- (void)unitPemFile {
    
    //合成
    NSString *cmdStr = [NSString stringWithFormat:@"cat %@/%@.pem %@/%@_key.pem > %@/ck.pem", _filePath, _fileName, _filePath, _fileName, _filePath];
    NSLog(@"%@", cmdStr);
    system([cmdStr UTF8String]);
    
    
    //删除两个中间文件
    cmdStr = [NSString stringWithFormat:@"rm -rf %@/%@.pem", _filePath, _fileName];
    NSLog(@"%@", cmdStr);
    system([cmdStr UTF8String]);
    
    cmdStr = [NSString stringWithFormat:@"rm -rf %@/%@_key.pem", _filePath, _fileName];
    NSLog(@"%@", cmdStr);
    system([cmdStr UTF8String]);
}






//        生成文件夹
//        system("mkdir /Users/apple/Desktop/test");

- (void)save {
    
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:@"ck.pem"];
    [panel setMessage:@"Choose the path to save the document"];
    [panel setAllowsOtherFileTypes:YES];
    [panel setAllowedFileTypes:@[@"pem"]];
    [panel setExtensionHidden:YES];
    [panel setCanCreateDirectories:YES];
    [panel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton)
        {
            NSString *path = [[panel URL] path];
            [@"onecodego" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end

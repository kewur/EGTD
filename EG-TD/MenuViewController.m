//
//  MenuViewController.m
//  EG-TD
//
//  Created by metin okur on 08.10.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//deneme
#import "MenuViewController.h"
#import "EG_TDAppDelegate.h"


@implementation MenuViewController

@synthesize LoginButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(IBAction) Loginbuttonpressed
{
    [(EG_TDAppDelegate*)[[UIApplication sharedApplication] delegate] ConnectToFB]; 
    
}








- (void)dealloc
{
    [LoginButton release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end

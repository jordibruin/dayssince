# DaysSince

<img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource126/v4/be/5a/0e/be5a0e88-78a2-33f7-13c3-601d70acf307/4145a3a9-ed53-42d2-8fe3-3be8bb0c90ec_Apple_iPhone_11_Pro_Max.png/460x0w.webp" width="200" /> <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource116/v4/36/d7/16/36d71602-ea3d-b473-e3f2-e736d95c4ae9/88b0c5ad-bcac-40da-b8d0-f4b141c86ee5_Apple_iPhone_11_Pro_Max__U00281_U0029.png/460x0w.webp" width="200" />


<img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource126/v4/9e/b1/bc/9eb1bce4-4abf-b7b4-7770-7422a848d98d/eb02e412-c27a-449d-85ec-40ced057d4f0_Apple_iPhone_11_Pro_Max__U00282_U0029.png/460x0w.webp" width="200" /> <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource116/v4/4f/e8/79/4fe879ca-8441-ab40-e3e3-44f52f6b6e06/80cb3077-03a1-4dba-b26e-b17718eff136_Apple_iPhone_11_Pro_Max__U00283_U0029.png/460x0w.webp" width="200" />

<img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource126/v4/e0/bd/d2/e0bdd221-33c3-d82e-d657-cea669b551bf/0659ea1d-9a9c-4521-9841-e513db9baf35_Apple_iPhone_11_Pro_Max__U00284_U0029.png/460x0w.webp" width="200" /> <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource126/v4/33/1b/e1/331be1f1-9162-9286-8493-19015a759802/e6c1f190-6883-4d01-93ae-37057bddd665_Apple_iPhone_11_Pro_Max__U00285_U0029.png/460x0w.webp" width="200" />



DaysSince is an iOS app that helps you count the days that passed since you last did the things important to you! 🕦🌱

You can find it on the App Store 👇:
https://apps.apple.com/us/app/days-since-track-memories/id1634218216

## Features
With DaysSince you can:
  - Create new events to keep track of
  - Count the days since you've last done an event
  - Receive reminders (daily, weekly, monthly)
  - Customize your events into categories with different colors. 
  - Widgets to display your events on your home screen.
  - Custom color themes
  - 5 different app icons
  - Create your own custom categories
  - Request and vote for new features

# Getting Started
Make sure you fulfill the requirements. 

## Requirements
- iOS 16.4+
- Xcode 14.3+
- macOS Ventura 13.0 or later

## Deployment
You can download the app from the App Store [here](https://apps.apple.com/us/app/days-since-track-memories/id1634218216). 

You can clone this github repository on your computer and open it with Xcode. Or you can directly click on "Open with Xcode" from Github.

// TODO: add a screenshot of the open with xcode

Once you open the project in XCode, no additional set up is needed. Use the standard steps to:
- Build the project (Command+B)
- Run the project (Command+R)

## Testing
Please test all of your code before making a PR. There are no in-built unit tests right now. 

## Usage
Watch the demo videos of Days Since here:
- [[Watch here]](https://drive.google.com/file/d/1kv7eCcrCw2BGQ29B5S2bFPamQYS7VTRx/view?usp=drive_link) Main demo 
- [[Watch here]](https://drive.google.com/file/d/13rRGs2l3ymdsgo-MhCHN2aKC0Ub2XDS5/view?usp=sharing) Demo of new features (custom categories and themes)

## Architechture
- The project doesn't have a database. All events and settings are stored in UserDefaults. This is done using the external [Defaults](https://github.com/sindresorhus/Defaults) package.
- There is a weak separation in terms of Model and View. 

## Libraries and Frameworks
- [Defaults](https://github.com/sindresorhus/Defaults) for storing all user data. It is basically a sugar coated UserDefaults. 
- [WishKit](https://www.wishkit.io) for colleting using feedback. Users can suggest or vote for new features. 

## Design
- All design and brainstorming is done in Sketch. Please contact Vicki (see Meta info section) if you want to be added to the Sketch project.
- The app icons were designed using Figma. 

## Team task collaboration tools
Right now it is only Vicki working on the project. There are no external tools (i.e Jira). You can keep track of tasks using the Issues tab on Github.

# Contribute
We would love it if you contribute to Days Since. You can see some of the open Issues on Github and make a PR. 

## Workflow
Reporting bugs:

If you find a bug please contact Vicki (see Meta Info section) or directly open a new issue with a description and screenshots of the bug. 

Submitting pull requests:

If you made a bug fix or a feature contribution, please submit a pull request and request Vicki as a reviewer. Please make sure your code is tested and clear. 

Providing feedback:
Any feedback is much appreciated!😊🚀 Please contact Vicki (see Meta Info section) or open new issues on Github.

Improving documentation:
If you see missing documentation info or something that is not clear, please open an issue or submit a pull request. 

# Meta Info
Victoria Petrova - Contact me on X [here](https://twitter.com/vicki_petrovaa) - victoria_petrowa@icloud.com

Jordi Bruin - Contact me on X [here](https://twitter.com/jordibruin)

# Project 4 - *Twitbot*

Time spent: **16** hours spent in total

## User Stories

The following **required** functionality is completed:

- Hamburger menu
    - [x] Dragging anywhere in the view should reveal the menu.
    - [x] The menu should include links to your profile, the home timeline, and the mentions view.
    - [x] The menu can look similar to the example or feel free to take liberty with the UI.
- Profile page
    - [x] Contains the user header view
    - [x] Contains a section with the users basic stats: # tweets, # following, # followers
- Home Timeline
    - [ ] Tapping on a user image should bring up that user's profile page

The following **optional** features are implemented:

- Profile Page
    - [ ] Implement the paging view for the user description.
    - [ ] As the paging view moves, increase the opacity of the background screen. See the actual Twitter app for this effect
    - [ ] Pulling down the profile page should blur and resize the header image.
- Account switching
    - [ ] Long press on tab bar to bring up Account view with animation
    - [ ] Tap account to switch to
    - [ ] Include a plus button to Add an Account
    - [ ] Swipe to delete an account

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. Priority of gesture recognizier

## Video Walkthrough

Here's a walkthrough of implemented user stories:

![walkthroungh](Twitbot.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

- I get stuck with gesture recognizer :( when I tap on user avatar, my VC triggered segue to show DetailTweetController instead of triggering tap gesture of avatar. I don't know how to fix it yet!'

## License

Copyright [2016] [Dam Vu Duy]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

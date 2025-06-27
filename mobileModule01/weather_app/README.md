                            Module01
EX00 : weather_app                   

Goal of the Exercise:
Build the basic structure of a responsive weather app in Flutter. It includes a top app bar with a search field and a geolocation button, and a bottom navigation bar with 3 tabs: “Currently”, “Today”, and “Weekly”. Each tab just shows its name for now. Users should be able to switch tabs by tapping or swiping.

Main Widgets to Use:
AppBar: top bar with search and geolocation button

TextField: search input field inside the AppBar

IconButton: buttons for search and geolocation

BottomAppBar: bottom bar holding the tabs

TabBar: shows the tabs with icons and text

TabBarView: displays content for each tab

TabController: controls syncing between the tabs and the content, and manages tap and swipe navigation

Why TabController is Important:
The TabController keeps the tab selection and the displayed content in sync. It also handles smooth switching when the user taps a tab or swipes between tabs. Without it, the tabs and content would not stay coordinated, which would hurt the user experience.
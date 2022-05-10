#  Happier Reminders

## Description

Happier Reminders is an app designed to send inspirational/encouraging reminders to users. It allows you to add quotes to collections, configure push notifications and view saved quotes.

## Requirements

- macOS
- Xcode
- Optional: an iPhone/iPad running iOS/iPadOS 15 or above, if you want to test it on an actual device (rather than the simulator).

## Installaton and Usage

1. Download or clone the repo.
2. cd into the project directory.
3. Open happierReminders.xcodeproj.
4. Click the build button and use the app on your device / in the built-in simulator.

## Contents

The project currently contains several view controllers, custom views, controllers for data, Core Data store, and more.

### View Controllers

1. **CollectionsViewController** - Contains the table view displaying the user's collections, as well as the ability to add and delete collections.
2. **CollectionTabBarViewController** - The tab bar controller for the collection view (contains the QuotesViewController and the ManageViewController).
3. **QuotesViewController** - Contains the table view displaying the quotes in the current collection, as well as the ability to trigger adding/editing quotes and delete quotes.
4. **ManageViewController** - Contains the manage view, which allows editing the collection's details.
5. **AddQuoteViewController** - Contains the form for editing/adding a new quote.
6. **FetchQuoteViewcontroller** - Contains the form for fetching a quote from the network.

### Views

1. **CollectionTableViewCell** - Contains the custom cell for the CollectionViewController's table.
2. **AlertFactory** - A factory for generating UIAlertControllers.
3. **Select** - A custom Select UIControl, which allows multiple or single selection from a list of values.

### Protocols

1. **ErrorHandler** - Empty protocol with an extension for generating error alerts.

### Model

1. **happierReminders.xcdatamodeld** - The app's Core Data store.
2. **DataManager** - The class responsible for setting up and managing the Core Data Stack. Also contains some helpers for NSFetchedResultsController and NSManagedObject handling.
3. **CollectionArrayTransformers** - Contains the transformers for the Core Data "Transformable" attributes.
4. **NotificationController** - The class responsible for setting up and managing push notifications.
5. **Collection+Extensions** - Extension for the Collection class. Contains a helper for generating a random qutoe.
6. **Quote+Extensions** - Extension for the Quote class. Contains common setup for new quotes.

### API Client

1. **APIClient** - API Client for interacting with the different APIs and processing the results.
2. **MotivationalQuote** - Contains Codable-conforming models for one of the APIs' data.

## Known Issues

There are no current issues at the time.

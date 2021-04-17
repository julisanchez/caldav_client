# CalDAV Client

A CalDAV client for dart. It allows to make CalDAV requests to a server easily and quickly.

## Tutorial

### SetUp

To use the caldav client you need to create an instance of `CalDavClient` with the url to which the requests will be made.

```dart
  var client = CalDavClient(
    baseUrl: ...,
  );
```

### Initial Sync

The first thing you may want to do is an initial synchronization that will return the `path`, `displayname` and `ctag` of each calendar collection.
This ctag works like a change id. Every time the ctag has changed, you know something in the calendar has changed too.

```dart
  var response = await client.initialSync(path);
```

Return prop: `getctag` and `displayname`.

### Get Objects

If what you want is to get the calendar data you need to use `getObjects`. With this method you will be able to obtain the `calendar-data`, in addition to the `path` and the `etag`.
These data are obtained by each `.ics` file, that is, each calendar object. The method must receive as a parameter the path of the collection.
The etag changes when the calendar object changes.

```dart
  var response = await client.getObjects(collectionPath);
```

Return prop: `getetag` and `calendar-data`.

### Get Changes
You must first perform another initial Sync to see if the ctag changed. If it changed, then you can more specifically check each object to see which one changed. For this you must use `getChanges` which returns each `etag`. Remember that each etag changes when the object changes. Besides the etag you should check if there is any url more or some url less.

```dart
  var response = await client.getChanges(collectionPath);
```

Return prop: `getetag`.

### Download .ics
If you want to download the .ics file of each calendar object you must use downloadIcs. The first parameter is the path of the file to download, and the second is the path of the directory to which you want to save it.

```dart
  var response = await client.downloadIcs(objectPath, pathToSave);
```

### Multiget
Constantly consulting with getObject can result in high bandwidth consumption. If we query the data with downloadIcs it can be tedious to do it for each changed object. For this problem we have a solution, and that is to use `multiget`. Multiget allows us to consult the data of several calendar objects, not necessarily all of them.
It receives as the first parameter the path of the collection and as the second the list of objects to consult.

```dart
  var files = ['object1.ics', 'object2.ics'];

  var response = await client.multiget(collectionPath, files);
```

Return prop: `getetag` and `calendar-data`.

### Update Calendar
If you want to update an object you just have to use the `updateCal` method. It receives as a parameter the path of the object to update, the etag and the calendar object with which it will be replaced. The calendar must follow the [ICalendar format][icalendar].

[icalendar]: https://icalendar.org/RFC-Specifications/iCalendar-RFC-5545/

```dart
  var response = await client.updateCal(objectPath, etag, icalendar);
```
A few notes:
* You must not change the UID of the original object
* Every object should hold only 1 event or task.
* You cannot change an VEVENT into a VTODO.

### Create Calendar
Creating a calendar object is quite simple, you just have to bear in mind that the path to be used is not being used by another object.

```dart
  var response = await client.createCal(newObjectPath, icalendar);
```

### Delete Caledar
Deleting a calendar object might be the easiest thing to do. Only the etag of the second parameter must coincide with the etag of the object to be deleted. The object to delete is the one found in the path of the first parameter.

```dart
  var response = await client.deleteCal(objectPath, etag);
```

### Multistatus
The results of the queries with caldav are returned through multistatus. Multistatus contains the information of different elements (either calendars or objects), along with the state with which it was returned. It is constituted as indicated in the following tree diagram:

```bash
.
+-- Multistatus  
    +-- Response (list)
        +-- href
        +-- Propstat
            +-- prop (map)
            +-- status

```
`Response`: list with the answers of each element consulted.

`href`: path of the queried element.

`Propstat`: properties obtained along with the status that were returned.

`prop`: map which contains the property name as a key. You must check in each method which property it returns.

The following methods include a multistatus object in the response:
* initialSync
* getObjects
* getChanges
* multiget

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/julisanchez/ical-parser/issues


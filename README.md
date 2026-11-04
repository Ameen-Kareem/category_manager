# Local Hierarchical Category Manager (Flutter + Bloc)

Login with JSONPlaceholder, see the profile, and manage an unlimited-depth
category tree that is saved in a local SQLite database.

## Setup

Needs Flutter 3.x (Dart 3).

```bash
# 1. create the android/ios folders once (keeps lib/ and pubspec.yaml)
flutter create --platforms=android,ios --project-name category_manager .

# 2. install packages
flutter pub get

# 3. run (internet is needed for login)
flutter run

# 4. tests
flutter test
```

Login: type a user ID from 1 to 10. Other IDs give a "not found" error.
For release builds on Android add the INTERNET permission to
`android/app/src/main/AndroidManifest.xml` (debug builds already have it).

## Project structure

```
lib/
  main.dart
  models/      user, category, category_node (tree helpers), page_result
  services/    api_service.dart       (REST call)
  data/        database_helper.dart   (tables)
               category_repository.dart (all SQL queries)
  bloc/
    auth/      auth_bloc, auth_event, auth_state
    category/  category_bloc, category_event, category_state
  screens/     login, profile, category
  widgets/     category_tile, category_detail_view, add_category_dialog
test/          tree tests
```

Flow: UI -> Bloc -> Repository / ApiService -> SQLite / HTTP.
The widgets never write SQL or call the API directly.

## State management: flutter_bloc

I used `Bloc` (events + states) for both features:

* `AuthBloc` - events: `AppStarted`, `LoginPressed`, `LogoutPressed`.
* `CategoryBloc` - events: `LoadCategories`, `AddCategory`, `DeleteCategory`,
  `ToggleCategory`, `SearchCategories`.

Reasons: every user action is an explicit event, so the flow is easy to follow
and test, and the UI only reacts to states (`BlocBuilder` to draw,
`BlocListener` for things like the snackbar and closing the add dialog).
States use `Equatable` so the UI only rebuilds when something really changed.

## Local database: sqflite (SQLite)

Categories are relational data (parent -> children), so SQL fits well:

* `categories(id, name, parent_id, created_at)`
* `parent_id` is a foreign key with `ON DELETE CASCADE`, so deleting a category
  also deletes everything below it.
* Data is stored in a file, so it stays after closing/restarting the app.
* `LIKE`, `LIMIT` and `OFFSET` make search and pagination simple.

## Category hierarchy

Each row only knows its parent (`parent_id`, `NULL` for root). There is no
depth limit in the table or in the code.

* **Unique names:** before inserting, the repository checks if the same name
  (case-insensitive) already exists under the same parent. The same name under
  a different parent is allowed.
* **Building the tree:** `buildTree` puts every category in a map and then adds
  each one to its parent's `children` list. It works for any depth.
* **Showing the tree:** `_getRows` in the category screen is recursive: it adds
  a node and, if that node is expanded, calls itself for its children.
* **Parent / path:** `getPath` in the repository is recursive: it gets the path
  of the parent first and then adds the current category.
* **Children:** loaded with a query on `parent_id`.

## Search and pagination

`searchCategories(query, page, pageSize, limit)`:

1. Finds categories whose name contains the text, at any depth.
2. For each match it returns the category, its parent, its direct children and
   its full path (shown as `A > B > C` and as a small tree).
3. `limit` is optional. If it is set (for example 10) at most that many results
   are returned in total. If it is empty, all matches are returned.
4. Results are paged with `LIMIT/OFFSET` (page size 20), so only one page is
   loaded at a time. The screen shows page, page size and total count
   (`{page, page_size, total_count}` is also available from `PageResult.toMap()`).

## Other points

* Form validation on login and on the add-category dialog.
* Loading, empty, error and "no search results" states are handled.
* The tree screen loads all categories at once to build the tree; the search is
  paginated in the database.

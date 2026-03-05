Storage abstraction

This folder provides a StorageService interface and a FirebaseStorageService stub.
The app is structured so that storage can be swapped by providing a different
StorageService implementation via the storageProvider.

When integrating Firebase:
- Implement FirebaseStorageService.loadItems/saveItems to read/write Firestore documents.
- In main.dart, provide a concrete instance:

  final firebase = FirebaseStorageService();
  await firebase.init();

  runApp(ProviderScope(overrides:[storageProvider.overrideWithValue(firebase)], child: MyApp()));


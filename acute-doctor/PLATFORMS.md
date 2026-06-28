## Native folders

Run `flutter create . --platforms=android,ios --org in.acutework --project-name acutework`
to generate the native Android and iOS folders for this project.

After that, configure flavors:

### Android (`android/app/build.gradle`)
```gradle
flavorDimensions "env"
productFlavors {
    dev      { dimension "env"; applicationIdSuffix ".dev";     resValue "string", "app_name", "Acutework Dev" }
    staging  { dimension "env"; applicationIdSuffix ".staging"; resValue "string", "app_name", "Acutework Staging" }
    prod     { dimension "env";                                  resValue "string", "app_name", "Acutework" }
}
```

### iOS
Create three schemes in Xcode (`dev`, `staging`, `prod`) each pointing at the
matching `Debug-<flavor>` / `Release-<flavor>` configurations and the
corresponding `lib/main_<flavor>.dart` entrypoint.

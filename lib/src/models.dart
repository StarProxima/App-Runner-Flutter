part of 'app_runner.dart';

/// {@template InitializeBinding}
/// Callback to use your WidgetsBinding instance
/// {@endtemplate}
typedef InitializeBinding = WidgetsBinding Function();

/// {@template InitializeFunctions}
/// A callback to initialize your code.
/// Responsible for initializing custom methods, such as `Firebase`, `Sentry`, etc.
/// {@endtemplate}
typedef InitializeFunctions<T> = FutureOr<T> Function(WidgetsBinding binding);

/// {@template RunnerBuilder}
///  A builder that builds a widget based on a snapshot.
/// Child can be null, is a cached version of the widget that does not depend on the snapshot.
///
/// This builder must only return a widget and should not have any side effects as it may be called multiple times.
/// {@endtemplate}
typedef RunnerBuilder<T> = Widget Function(
  BuildContext context,
  AsyncSnapshot<T?> snapshot,
  Widget? child,
);

/// {@template OnError}
/// The [onError] function is used both to handle asynchronous errors by overriding [ZoneSpecification.handleUncaughtError] in [zoneSpecification], if any, and to handle errors thrown synchronously by the call to [body].
/// {@endtemplate}
typedef OnError = void Function(Object error, StackTrace stackTrace);

/// {@template RenderObjectBuilder}
/// Custom Builder for error handling in release mode
/// {@endtemplate}
typedef RenderObjectBuilder = RenderObject Function(BuildContext context);

/// {@template ErrorRenderObjectBuilder}
/// Custom Builder for error handling in debug and profile mode
/// {@endtemplate}
typedef ErrorRenderObjectBuilder = RenderObject Function(
  BuildContext context,
  FlutterErrorDetails errorDetails,
);

/// {@template RunnerConfiguration}
/// Runner Configuration
/// {@endtemplate}
@immutable
abstract class RunnerConfiguration {
  /// Runner Configuration
  /// - [widgetConfig] is responsible for configuring launched widgets and handling errors in widgets;
  /// - [onPlatformError] is callback that is invoked when an unhandled error occurs in the root isolate.
  /// If this method returns [false], the engine may use some fallback method to provide information about the error;
  const factory RunnerConfiguration({
    required WidgetConfiguration widgetConfig,
    ui.ErrorCallback? onPlatformError,
    bool keepOldCallback,
  }) = _RunnerConfiguration;

  /// Runner Configuration Guarded
  /// - [widgetConfig] is responsible for configuring launched widgets and handling errors in widgets;
  /// - [zoneConfig] responsible for the zone configuration in which your application will be launched;
  const factory RunnerConfiguration.guarded({
    required WidgetConfiguration widgetConfig,
    required ZoneConfiguration zoneConfig,
    bool keepOldCallback,
  }) = _RunnerConfigurationGuarded;

  const RunnerConfiguration._(this.widgetConfig, {this.keepOldCallback = true});

  /// {@macro WidgetConfiguration}
  final WidgetConfiguration widgetConfig;

  /// If this method returns [true], existing error handlers will be included in the new ones.
  final bool keepOldCallback;
}

class _RunnerConfiguration extends RunnerConfiguration {
  /// {@macro RunnerConfiguration}
  const _RunnerConfiguration({
    required WidgetConfiguration widgetConfig,
    this.onPlatformError,
    this.keepOldCallback = true,
  }) : super._(widgetConfig);

  /// A callback that is invoked when an unhandled error occurs in the root isolate.
  /// If this method returns [false], the engine may use some fallback method to provide information about the error.
  final ui.ErrorCallback? onPlatformError;
  final bool keepOldCallback;
}

class _RunnerConfigurationGuarded extends RunnerConfiguration {
  /// {@macro RunnerConfiguration}
  const _RunnerConfigurationGuarded({
    required WidgetConfiguration widgetConfig,
    required this.zoneConfig,
    this.keepOldCallback = true,
  }) : super._(widgetConfig);

  /// {@macro ZoneConfiguration}
  final ZoneConfiguration zoneConfig;
  final bool keepOldCallback;
}

/// {@template WidgetConfiguration}
/// Widget configuration, takes in itself:
/// - [child] widget of your application;
/// - [onFlutterError] error handler for flutter widgets;
/// - [errorBuilder] handler for handling error screen in debug and profile mode. Attention! This widget fragile, do not do it loaded his best done through [LeafRenderObjectWidget];
/// - [releaseErrorBuilder] handler for handling error screen in release mode. Attention! This widget fragile, do not do it loaded his best done through [LeafRenderObjectWidget];
/// - [initializeBinding] is responsible for initializing your [WidgetsBinding];
/// {@endtemplate}
@immutable
class WidgetConfiguration {
  /// {@macro WidgetConfiguration}
  const WidgetConfiguration({
    required this.child,
    required this.onFlutterError,
    this.errorBuilder,
    this.releaseErrorBuilder,
    this.initializeBinding,
  });

  /// Your application widget
  final Widget child;

  /// Called whenever the Flutter framework catches an error.
  final void Function(FlutterErrorDetails errorDetails) onFlutterError;

  /// {@macro ErrorRenderObjectBuilder}
  final ErrorRenderObjectBuilder? errorBuilder;

  /// {@macro RenderObjectBuilder}
  final RenderObjectBuilder? releaseErrorBuilder;

  /// {@macro InitializeBinding}
  final InitializeBinding? initializeBinding;
}

/// {@template ZoneConfiguration}
/// Zone configuration, takes in itself:
/// - [onZoneError] zone error handler;
/// - [zoneValues] local data for a specific zone;
/// - [zoneSpecification] zone specification;
/// {@endtemplate}
@immutable
class ZoneConfiguration {
  /// {@macro ZoneConfiguration}
  const ZoneConfiguration({
    required this.onZoneError,
    this.zoneValues,
    this.zoneSpecification,
  });

  /// {@macro OnError}
  final OnError onZoneError;

  /// Local zone values
  final Map<Object, Object>? zoneValues;

  /// A parameter object with custom zone function handlers for [Zone.fork].
  final ZoneSpecification? zoneSpecification;
}

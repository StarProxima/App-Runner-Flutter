part of 'app_runner.dart';

mixin _AppRunner on WidgetsBinding {
  static void run(RunnerConfiguration config) {
    if (config is _RunnerConfigurationGuarded) {
      runZonedGuarded<void>(
        () => _attach(config),
        config.zoneConfig.onZoneError,
        zoneValues: config.zoneConfig.zoneValues,
        zoneSpecification: config.zoneConfig.zoneSpecification,
      );
    } else if (config is _RunnerConfiguration) {
      _platformErrorSetup(config.onPlatformError, config.keepOldCallback);
      _attach(config);
    } else {
      _attach(config);
    }
  }

  static void _attach(RunnerConfiguration config) {
    final WidgetsBinding binding =
        config.widgetConfig.initializeBinding?.call() ??
            WidgetsFlutterBinding.ensureInitialized();

    binding
      ..scheduleAttachRootWidget(
        binding.wrapWithDefaultView(
          _App(
            widgetConfig: config.widgetConfig,
          ),
        ),
      )
      ..scheduleForcedFrame();

    _flutterErrorSetup(config.widgetConfig, config.keepOldCallback);
  }

  static void _flutterErrorSetup(
    WidgetConfiguration widgetConfig,
    bool keepOldCallback,
  ) {
    final FlutterExceptionHandler? oldCallback = FlutterError.onError;

    FlutterError.onError = (FlutterErrorDetails errorDetails) {
      if (keepOldCallback) oldCallback?.call(errorDetails);
      widgetConfig.onFlutterError(errorDetails);
    };
  }

  static void _platformErrorSetup(
      final ui.ErrorCallback? onPlatformError, bool keepOldCallback) {
    if (onPlatformError == null) return;

    final ui.ErrorCallback? oldCallback = PlatformDispatcher.instance.onError;

    PlatformDispatcher.instance.onError = (
      Object exception,
      StackTrace stackTrace,
    ) {
      final bool? oldCallbackResult =
          keepOldCallback ? oldCallback?.call(exception, stackTrace) : null;
      final bool newCallbackResult = onPlatformError(exception, stackTrace);

      return oldCallbackResult == null
          ? newCallbackResult
          : oldCallbackResult && newCallbackResult;
    };
  }
}

class _App extends StatelessWidget {
  const _App({
    Key? key,
    required this.widgetConfig,
  }) : super(key: key);

  final WidgetConfiguration widgetConfig;

  @override
  Widget build(BuildContext context) {
    return ReloadableWidget(
      builder: (BuildContext context) {
        ErrorWidget.builder =
            (FlutterErrorDetails errorDetails) => ErrorHandlerWidget(
                  errorDetails: errorDetails,
                  releaseErrorBuilder: widgetConfig.releaseErrorBuilder,
                  errorBuilder: widgetConfig.errorBuilder,
                );

        return widgetConfig.child;
      },
    );
  }
}

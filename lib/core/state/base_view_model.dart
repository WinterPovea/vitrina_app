import 'package:flutter/foundation.dart';

import '../error/app_exception.dart';

/// Los estados que TODA pantalla con datos remotos debe mostrar (rúbrica 5).
enum ViewStatus { idle, loading, data, empty, error }

/// Base de los ViewModels. Reglas:
///  - Recibe sus dependencias (repositorios / casos de uso) por constructor.
///  - NO importa el SDK remoto ni hace llamadas HTTP: delega en el repositorio.
///  - Expone estado + acciones; la vista solo los consume.
abstract class BaseViewModel extends ChangeNotifier {
  ViewStatus _status = ViewStatus.idle;
  AppException? _error;
  bool _disposed = false;

  ViewStatus get status => _status;
  AppException? get error => _error;
  String get errorMessage => _error?.message ?? 'Ocurrió un error inesperado.';
  bool get canRetry => _error?.isRetryable ?? true;

  @protected
  void setLoading() {
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
  }

  @protected
  void setLoaded({required bool isEmpty}) {
    _status = isEmpty ? ViewStatus.empty : ViewStatus.data;
    _error = null;
    notifyListeners();
  }

  @protected
  void setFailed(Object error) {
    _error = AppException.from(error);
    _status = ViewStatus.error;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

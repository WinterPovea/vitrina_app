import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/appointments/data/repositories/appointment_repository_impl.dart';
import '../../features/appointments/domain/repositories/appointment_repository.dart';
import '../../features/appointments/domain/usecases/book_appointment_use_case.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/viewmodels/auth_view_model.dart';
import '../../features/organization/data/repositories/organization_repository_impl.dart';
import '../../features/organization/domain/repositories/organization_repository.dart';
import '../../features/reviews/data/repositories/review_repository_impl.dart';
import '../../features/reviews/domain/repositories/review_repository.dart';
import '../../features/services/data/repositories/service_repository_impl.dart';
import '../../features/services/domain/repositories/service_repository.dart';
import '../../features/specialists/data/repositories/specialist_repository_impl.dart';
import '../../features/specialists/domain/repositories/specialist_repository.dart';
import '../config/app_config.dart';
import '../network/api_service.dart';

/// Raíz de composición: AQUÍ (y solo aquí) se decide qué implementación usa cada contrato.
/// Los ViewModels de cada pantalla reciben estos objetos con `context.read<...>()`.
/// Para pruebas, se reemplazan por dobles (mocktail) sin tocar el resto.
List<SingleChildWidget> buildAppProviders() => [
      Provider<ApiService>(create: (_) => ApiService(Supabase.instance.client)),

      // Repositorios (contrato -> implementación)
      Provider<AuthRepository>(
        create: (c) => AuthRepositoryImpl(c.read<ApiService>(), AppConfig.organizationId),
      ),
      Provider<OrganizationRepository>(
        create: (c) => OrganizationRepositoryImpl(c.read<ApiService>(), AppConfig.organizationId),
      ),
      Provider<SpecialistRepository>(create: (c) => SpecialistRepositoryImpl(c.read<ApiService>())),
      Provider<ServiceRepository>(create: (c) => ServiceRepositoryImpl(c.read<ApiService>())),
      Provider<AppointmentRepository>(create: (c) => AppointmentRepositoryImpl(c.read<ApiService>())),
      Provider<ReviewRepository>(create: (c) => ReviewRepositoryImpl(c.read<ApiService>())),

      // Casos de uso
      Provider<BookAppointmentUseCase>(
        create: (c) => BookAppointmentUseCase(c.read<AppointmentRepository>()),
      ),

      // Estado global: sesión
      ChangeNotifierProvider<AuthViewModel>(
        create: (c) => AuthViewModel(c.read<AuthRepository>()),
      ),
    ];

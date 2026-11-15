import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/appointments/presentation/pages/appointments_page.dart';
import '../../features/appointments/presentation/pages/booking_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/viewmodels/auth_view_model.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/home_shell.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/specialists/domain/repositories/specialist_repository.dart';
import '../../features/specialists/presentation/pages/specialist_detail_page.dart';
import '../../features/specialists/presentation/pages/specialists_page.dart';
import '../../features/specialists/presentation/viewmodels/specialist_list_view_model.dart';
import 'app_routes.dart';

/// Router con rutas protegidas: sin sesión solo se accede a sign-in / sign-up.
/// `refreshListenable` hace que el router reaccione al iniciar/cerrar sesión.
GoRouter createAppRouter(AuthViewModel auth) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (!auth.isAuthenticated && !AppRoutes.isPublic(loc)) return AppRoutes.signIn;
      if (auth.isAuthenticated && AppRoutes.isPublic(loc)) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.signIn, builder: (_, __) => const SignInPage()),
      GoRoute(path: AppRoutes.signUp, builder: (_, __) => const SignUpPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.home, builder: (_, __) => const HomePage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.specialists,
              // El ViewModel de la pantalla se crea aquí, con sus dependencias desde Provider.
              builder: (context, _) => ChangeNotifierProvider(
                create: (c) => SpecialistListViewModel(c.read<SpecialistRepository>())..load(),
                child: const SpecialistsPage(),
              ),
              routes: [
                GoRoute(
                  path: ':id', // parámetro de ruta
                  builder: (_, state) =>
                      SpecialistDetailPage(specialistId: state.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'book',
                      builder: (_, state) => BookingPage(
                        specialistId: state.pathParameters['id']!,
                        serviceId: state.uri.queryParameters['serviceId'], // parámetro query
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.appointments, builder: (_, __) => const AppointmentsPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfilePage()),
          ]),
        ],
      ),
    ],
  );
}

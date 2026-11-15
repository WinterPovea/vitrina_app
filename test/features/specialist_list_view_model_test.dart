import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitrina_app/core/error/app_exception.dart';
import 'package:vitrina_app/core/state/base_view_model.dart';
import 'package:vitrina_app/features/specialists/domain/entities/specialist.dart';
import 'package:vitrina_app/features/specialists/domain/repositories/specialist_repository.dart';
import 'package:vitrina_app/features/specialists/presentation/viewmodels/specialist_list_view_model.dart';

class MockSpecialistRepository extends Mock implements SpecialistRepository {}

void main() {
  late MockSpecialistRepository repo;
  late SpecialistListViewModel vm;

  const specialist = Specialist(id: '1', organizationId: 'org', displayName: 'Ana');

  setUp(() {
    repo = MockSpecialistRepository();
    vm = SpecialistListViewModel(repo);
  });

  test('carga datos', () async {
    when(() => repo.getSpecialists(query: any(named: 'query')))
        .thenAnswer((_) async => [specialist]);
    await vm.load();
    expect(vm.status, ViewStatus.data);
    expect(vm.specialists, hasLength(1));
  });

  test('estado vacío', () async {
    when(() => repo.getSpecialists(query: any(named: 'query'))).thenAnswer((_) async => []);
    await vm.load();
    expect(vm.status, ViewStatus.empty);
  });

  test('error de red permite reintentar y se recupera', () async {
    when(() => repo.getSpecialists(query: any(named: 'query')))
        .thenThrow(const AppException(AppErrorType.network, 'Sin conexión'));
    await vm.load();
    expect(vm.status, ViewStatus.error);
    expect(vm.canRetry, isTrue);

    when(() => repo.getSpecialists(query: any(named: 'query')))
        .thenAnswer((_) async => [specialist]);
    await vm.load();
    expect(vm.status, ViewStatus.data);
  });

  test('search pasa el texto limpio al repositorio', () async {
    when(() => repo.getSpecialists(query: any(named: 'query'))).thenAnswer((_) async => []);
    await vm.search('  ana ');
    verify(() => repo.getSpecialists(query: 'ana')).called(1);
  });
}

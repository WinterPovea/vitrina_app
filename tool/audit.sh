#!/usr/bin/env bash
# Auditoría automática de reglas de docs/CONVENTIONS.md. Uso: bash tool/audit.sh
cd "$(dirname "$0")/.." || exit 2
fail=0
check() { # check "descripción" "comando que imprime las violaciones"
  local out; out=$(bash -c "$2" 2>/dev/null)
  if [ -n "$out" ]; then echo "✗ $1"; echo "$out" | sed 's/^/    /'; fail=1; else echo "✓ $1"; fi
}
check "Sin shared_preferences" "grep -rn 'package:shared_preferences' lib; grep -nE '^\s*shared_preferences:' pubspec.yaml"
check "Sin BD local / caché de datos" "grep -rniwE 'sqflite|hive|isar|drift|cached_network_image' lib pubspec.yaml"
check "supabase_flutter solo en core/network, features/*/data y 2 excepciones de infraestructura" \
  "grep -rl 'package:supabase_flutter' lib | grep -vE '^lib/core/network/|^lib/core/error/app_exception.dart|^lib/core/di/app_providers.dart|^lib/features/[^/]+/data/'"
check "Presentación sin SDK ni ApiService" "grep -rnE 'supabase|ApiService' lib/features/*/presentation lib/shared"
check "Presentación sin instanciar repositorios (inyección por constructor)" "grep -rnE 'RepositoryImpl\(' lib/features/*/presentation lib/shared"
check "Sin colores hardcodeados (usar Theme/Brand)" "grep -rnE 'Color\(0x|Colors\.(red|blue|green|pink|purple|orange|yellow|amber|teal|grey|black)' lib/features lib/shared"
check "Sin rutas sueltas (usar AppRoutes)" "grep -rnE '\.(go|push|replace|pushReplacement)\(\s*[\"'\\'']/' lib/features lib/shared"
check "Sin textos del rubro uñas/belleza" "grep -rniE 'uñas|nail|manicur|acr[ií]lic|pedicur|belleza|salón|velvet|lumi[eè]re' lib"
check "Sin print()" "grep -rnE '(^|[^a-zA-Z_])print\(' lib"
exit $fail

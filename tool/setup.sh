#!/usr/bin/env bash
# Prepara el proyecto Android por primera vez. Uso:  bash tool/setup.sh
# Requiere Flutter instalado (flutter doctor sin errores en Android).
set -euo pipefail
cd "$(dirname "$0")/.."

if [ ! -d android ]; then
  echo "▶ Generando carpeta android/ ..."
  flutter create . --platforms=android --project-name vitrina_app --org ec.edu.vitrina
fi

MANIFEST=android/app/src/main/AndroidManifest.xml
python3 - "$MANIFEST" <<'PY'
import sys,re
p=sys.argv[1]; s=open(p,encoding='utf-8').read()
if 'android.permission.INTERNET' not in s.split('<application')[0]:
    s=s.replace('<application','    <uses-permission android:name="android.permission.INTERNET"/>\n    <application',1)
if '<queries>' not in s:
    q='''    <queries>
        <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>
        <intent><action android:name="android.intent.action.DIAL"/><data android:scheme="tel"/></intent>
    </queries>
'''
    s=s.replace('<application',q+'    <application',1)
open(p,'w',encoding='utf-8').write(s)
print('▶ AndroidManifest parcheado (INTERNET + queries para WhatsApp/tel)')
PY

# flutter_secure_storage necesita minSdk 23
for f in android/app/build.gradle android/app/build.gradle.kts; do
  [ -f "$f" ] && sed -i -E 's/minSdk(Version)?\s*=?\s*(flutter\.minSdkVersion|[0-9]+)/minSdk = 23/' "$f" && echo "▶ minSdk=23 en $f"
done

[ -f env/dev.json ] || { cp env/dev.example.json env/dev.json; echo "▶ Creado env/dev.json: edítalo con tus credenciales"; }
flutter pub get
echo "✔ Listo. Ejecuta:  flutter run --dart-define-from-file=env/dev.json"

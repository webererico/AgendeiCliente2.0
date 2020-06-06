# agendei

Agendei - Agendamento otimizado

## Como iniciar o projeto

Maneiras para executar o software:

1.PELO APK GERADO: Instalar o apk no Android. O arquivo encontra-se na pasta: Build>app>outputs>apk>release, com o nome app-release.apk. Para instalá-lo no Android é necessário dar autorização no aparelho. (Caso não rode em seu Android o apk, é necessário executar o passo 3).

2. PELO IOS: Instalar no iOS. Basta abrir o projeto no Xcode e executar na pasta Runner. (Irá automaticamente abrir nesta pasta) com o aparelho conectado ao computador (mac) no primeiro Build.
(É possível executar no IOS Emulator ou no própprio aparelho IOS direto do Android Studio), Basta seguir o tópico 3 e selecionar o IOS device no Android Studio)

3. PELO ANDROID E IOS EMULADO E DISPOSITIVO REAL: seguir o procedimento:
    1. Instalar Android Studio: https://developer.android.com/studio/install
    2. Instalar o SDK Flutter: https://flutter.dev/docs/get-started/install
    3. Instalar um emulador Android
    4. Executar o comando “flutter pub get” dentro da pasta principal
    5. Abrir o projeto no Android Studio e clicar em run.

OBS: Caso o Android Studio não localize o APK do Flutter(Dart), seguir os passos:
    1. File->Settings->Language & Framework->Flutter
    2. Choose flutter SDK path: the first time we install flutter, we choose the location where the flutter should be installed. Choose this location.
    3. Click OK and the android studio will refresh. Carry on if the problem is solved.
    4. If you are still stuck with the error.

OBS: Para BUGs na compilação do IOS, limpar a pasta do ios do projeto com os seguintes passos:
pod deintegrate (dentro da pasta iOS)
flutter clean
flutter pub cache repair
cd Pod install (dentro da pasta iOS)
Pod repo update (dentro da pasta iOS)
rm iOS/Podfile
Flutter run --verbose

#include "Update.h"
#include "AdminPrivilegeManager.h"
#include <QApplication>
#include <QMessageBox>
#include <Windows.h>
#include <QSettings>

typedef void (*StartFunc)();
typedef void (*StopFunc)();

int main(int argc, char* argv[])
{
    QSettings settings("Sigma", "Config");
    settings.setValue("verSigmaExe", 1.0);

    HANDLE hMutex = CreateMutexW(nullptr, TRUE, L"Sigma");
    if ((GetLastError() == ERROR_ALREADY_EXISTS)) {
        return 0;
    }

    if (!AdminPrivilegeManager::getInstance().ensureAdminPrivileges()) {
        return 0;
    }

    QApplication app(argc, argv);

    Update::getInstance().run();

    HMODULE hSigmaLib = LoadLibraryW(L"SigmaLib.dll");
    if (!hSigmaLib) {
        QMessageBox::critical(nullptr, "Error", "Cannot load SigmaLib.dll");
        return -1;
    }

    StartFunc startFunc = (StartFunc)GetProcAddress(hSigmaLib, "sigmalib_start");
    StopFunc stopFunc = (StopFunc)GetProcAddress(hSigmaLib, "sigmalib_stop");

    if (!startFunc || !stopFunc) {
        QMessageBox::critical(nullptr, "Error", "Cannot find start/stop function in SigmaLib.dll");
        FreeLibrary(hSigmaLib);
        return -1;
    }

    startFunc();

    int result = app.exec();

    stopFunc();

    if (hMutex) {
        ReleaseMutex(hMutex);
        CloseHandle(hMutex);
    }

    if (hSigmaLib) {
        FreeLibrary(hSigmaLib);
    }

    return result;
}

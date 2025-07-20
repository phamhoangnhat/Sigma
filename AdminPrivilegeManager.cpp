#include "AdminPrivilegeManager.h"
#include <QSettings>
#include <QMessageBox>
#include <QDebug>
#include <Windows.h>
#include <shellapi.h>
#include <cstdlib>

AdminPrivilegeManager& AdminPrivilegeManager::getInstance()
{
    static AdminPrivilegeManager instance;
    return instance;
}

AdminPrivilegeManager::AdminPrivilegeManager(QObject* parent)
    : QObject(parent)
{
}

AdminPrivilegeManager::~AdminPrivilegeManager()
{
}

bool AdminPrivilegeManager::ensureAdminPrivileges()
{
    QSettings settings("Sigma", "Config");
    bool modeAdmin = settings.value("modeAdmin", false).toBool();
    if (modeAdmin && !isRunningAsAdmin()) {
        if (relaunchAsAdmin()) {
            return false;
        }
        else {
            qDebug() << "Insufficient administrator privileges. Application continues without admin.";
            return true;
        }
    }

    return true;
}

bool AdminPrivilegeManager::isRunningAsAdmin()
{
    BOOL isAdmin = FALSE;
    PSID adminGroup = nullptr;
    SID_IDENTIFIER_AUTHORITY authority = SECURITY_NT_AUTHORITY;

    if (AllocateAndInitializeSid(&authority, 2,
        SECURITY_BUILTIN_DOMAIN_RID,
        DOMAIN_ALIAS_RID_ADMINS,
        0, 0, 0, 0, 0, 0,
        &adminGroup))
    {
        CheckTokenMembership(nullptr, adminGroup, &isAdmin);
        FreeSid(adminGroup);
    }

    return isAdmin;
}

bool AdminPrivilegeManager::relaunchAsAdmin()
{
    wchar_t exePath[MAX_PATH];
    GetModuleFileNameW(nullptr, exePath, MAX_PATH);

    SHELLEXECUTEINFOW sei = { sizeof(sei) };
    sei.lpVerb = L"runas";
    sei.lpFile = exePath;
    sei.nShow = SW_SHOWNORMAL;

    if (!ShellExecuteExW(&sei)) {
        DWORD err = GetLastError();
        if (err == ERROR_CANCELLED)
            return false;
    }

    return true;
}

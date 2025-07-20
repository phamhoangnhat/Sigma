#ifndef ADMINPRIVILEGEMANAGER_H
#define ADMINPRIVILEGEMANAGER_H

#include <QObject>

class AdminPrivilegeManager : public QObject
{
    Q_OBJECT

public:
    static AdminPrivilegeManager& getInstance();
    bool ensureAdminPrivileges();

private:
    explicit AdminPrivilegeManager(QObject* parent = nullptr);
    ~AdminPrivilegeManager();

    AdminPrivilegeManager(const AdminPrivilegeManager&) = delete;
    AdminPrivilegeManager& operator=(const AdminPrivilegeManager&) = delete;

    bool isRunningAsAdmin();
    bool relaunchAsAdmin();
};

#endif // ADMINPRIVILEGEMANAGER_H
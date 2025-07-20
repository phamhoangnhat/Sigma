#include "Update.h"

#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <QEventLoop>
#include <QFile>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QRandomGenerator>
#include <QSettings>
#include <QTextStream>
#include <QTimer>

Update& Update::getInstance()
{
    static Update instance;
    return instance;
}

Update::Update(QObject* parent)
    : QObject(parent)
{
    updateUrl = "https://raw.githubusercontent.com/phamhoangnhat/Sigma/main/update.dat";
    tempDir = QDir::tempPath();
    appDir = QCoreApplication::applicationDirPath();
    downloadDir = "";
}

Update::~Update()
{
}

int Update::run()
{
    QSettings settings("Sigma", "Config");
    bool modeAutoUpdate = settings.value("modeAutoUpdate", "true").toBool();
    settings.setValue("modeAutoUpdate", modeAutoUpdate ? "true" : "false");
    if (!modeAutoUpdate) {
        qDebug() << "Không cập nhật ứng dụng";
        return -1;
    }

    QDir().mkpath(tempDir);
    QString pathFileDataUpdate = tempDir + "/" + generateRandomString(10) + ".dat";

    QString fileName = downloadFile(updateUrl, pathFileDataUpdate);
    if (fileName.isEmpty()) {
        qDebug() << "Đã xảy ra lỗi khi cập nhật ứng dụng";
        return 0;
    }

    QString newVersion;
    QMap<QString, QString> downloadMap;
    if (!readUpdateInfo(pathFileDataUpdate, newVersion, downloadMap)) {
        qDebug() << "Đã xảy ra lỗi khi cập nhật ứng dụng";
        QFile::remove(pathFileDataUpdate);
        return 0;
    }

    QFile::remove(pathFileDataUpdate);
    QString currentVersion = settings.value("appNameFull", "").toString();
    if (newVersion.isEmpty() || (newVersion == currentVersion)) {
        qDebug() << "Không có bản cập nhật mới nào";
        return 1;
    }

    downloadDir = tempDir + "/" + generateRandomString(10);
    QDir().mkpath(downloadDir);

    for (auto it = downloadMap.begin(); it != downloadMap.end(); ++it) {
        QString url = it.key();
        QString finalName = it.value();
        QString finalDownloadPath = downloadDir + "/" + finalName;

        if (downloadFile(url, finalDownloadPath).isEmpty()) {
            qDebug() << "Đã xảy ra lỗi khi cập nhật ứng dụng";
            return 0;
        }
    }

    QDir dir(downloadDir);
    QStringList fileList = dir.entryList(QDir::Files);
    for (const QString& fileName : fileList) {
        QString srcPath = downloadDir + "/" + fileName;
        QString destPath = appDir + "/" + fileName;

        QFile::remove(destPath);
        if (!QFile::rename(srcPath, destPath)) {
            qDebug() << "Đã xảy ra lỗi khi cập nhật ứng dụng";
            return 0;
        }
    }

    QDir(downloadDir).removeRecursively();

    settings.setValue("version", newVersion);

    qDebug() << "Đã cập nhật thành công phiên bản:" << newVersion;
    return 2;
}

bool Update::readUpdateInfo(const QString& filePath, QString& newVersion, QMap<QString, QString>& downloadMap)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return false;

    QTextStream in(&file);
    if (!in.atEnd())
        newVersion = in.readLine().trimmed();

    while (!in.atEnd()) {
        QString url = in.readLine().trimmed();
        if (url.isEmpty() || in.atEnd())
            break;

        QString fileName = in.readLine().trimmed();
        if (fileName.isEmpty())
            return false;

        downloadMap[url] = fileName;
    }
    return true;
}

QString Update::downloadFile(const QString& url, const QString& outputPath)
{
    QNetworkRequest request(url);
    QNetworkReply* reply = manager.get(request);

    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);

    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);

    timer.start(60000);
    loop.exec();

    if (!timer.isActive()) {
        reply->abort();
        reply->deleteLater();
        return QString();
    }

    if (reply->error() != QNetworkReply::NoError) {
        reply->deleteLater();
        return QString();
    }

    QFile file(outputPath);
    if (!file.open(QIODevice::WriteOnly)) {
        reply->deleteLater();
        return QString();
    }

    file.write(reply->readAll());
    file.close();
    reply->deleteLater();

    return outputPath;
}

QString Update::generateRandomString(int length)
{
    const QString possibleCharacters("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789");
    QString randomString;
    for (int i = 0; i < length; ++i) {
        int index = QRandomGenerator::global()->bounded(possibleCharacters.length());
        randomString.append(possibleCharacters.at(index));
    }
    return randomString;
}

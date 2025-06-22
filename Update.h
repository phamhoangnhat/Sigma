#ifndef UPDATE_H
#define UPDATE_H

#include <QObject>
#include <QMap>
#include <QStringList>
#include <QNetworkAccessManager>

class Update : public QObject
{
    Q_OBJECT

public:
    static Update& getInstance();
    int run();

private:
    explicit Update(QObject* parent = nullptr);
    ~Update();

    Update(const Update&) = delete;
    Update& operator=(const Update&) = delete;

    bool readUpdateInfo(const QString& filePath, QString& newVersion, QMap<QString, QString>& downloadMap);
    QString downloadFile(const QString& url, const QString& outputPath);
    QString generateRandomString(int length);

private:
    QNetworkAccessManager manager;
    QString updateUrl;
    QString tempDir;
    QString appDir;
    QString downloadDir;
};

#endif // UPDATE_H
#include <QApplication>
#include "mainwindow.h"
#include <QQmlDebuggingEnabler>
#include <QSignalMapper>
#include "singleinstance/singleinstance.h"

int main(int argc, char *argv[]) {

	QQmlDebuggingEnabler enabler;

	// Set app name (needed later-on)
	QApplication::setApplicationName("photoqt");

	// We store this as a QString, as this way we don't have to explicitely cast VERSION to a QString below
	QString version = VERSION;

	// Create a new instance (includes handling of argc/argv)
	// This class ensures, that only one instance is running. If one is already running, we pass the commands to the main process and exit.
	// If no process is running yet, we create a LocalServer and continue below
	SingleInstance a(argc, argv);



	// SOME START-UP CHECKS
	// TO-DO: some clean-up

	// Ensure that the config folder exists
	QDir dir(QDir::homePath() + "/.photoqt");
	if(!dir.exists()) {
		if(a.verbose) std::clog << "Creating ~/.photoqt/" << std::endl;
		dir.mkdir(QDir::homePath() + "/.photoqt");
	}

	// This int holds 1 if PhotoQt was updated and 2 if it's newly installed
	bool photoQtUpdated = false;
	bool photoQtInstalled = false;
	QString settingsFileTxt = "";

	// Check if the settings file exists. If not, create an empty file.
	QFile file(QDir::homePath() + "/.photoqt/settings");
	if(!file.exists()) {
		if(!file.open(QIODevice::WriteOnly))
			std::cerr << "ERROR: Couldn't create settings file! Please ensure that you have read&write access to your home directory" << std::endl;
		else {
			if(a.verbose) std::clog << "Creating empty settings file" << std::endl;
			QTextStream out(&file);
			out << "Version=" + version + "\n";
			file.close();
		}

		photoQtUpdated = true;

	// If file does exist, check if it is from a previous version -> PhotoQt was updated
	} else {
		if(!file.open(QIODevice::ReadWrite))
			std::cerr << "ERROR: Couldn't read settings file! Please ensure that you have read&write access to home directory" << std::endl;
		else {
			QTextStream in(&file);
			settingsFileTxt = in.readAll();

			if(a.verbose) std::clog << "Checking if first run of new version" << std::endl;

			// If it doesn't contain current version (some previous version)
			if(!settingsFileTxt.contains("Version=" + version + "\n")) {
				file.close();
				file.remove();
				file.open(QIODevice::ReadWrite);
				QStringList allSplit = settingsFileTxt.split("\n");
				allSplit.removeFirst();
				QString allFile = "Version=" + version + "\n" + allSplit.join("\n");
				in << allFile;
				photoQtInstalled = true;
			}

			file.close();

		}
	}

	/****************************************************/
	// DEVELOPMENT ONLY
	photoQtUpdated = a.update;
	photoQtInstalled = a.install;
	// DEVELOPMENT ONLY
	/****************************************************/

#ifdef GM
	Magick::InitializeMagick(*argv);
#endif

	if(QFile(QDir::homePath()+"/.photoqt/cmd").exists())
		QFile(QDir::homePath()+"/.photoqt/cmd").remove();

	// This boolean stores if PhotoQt needs to be minimized to the tray
	bool startintray = a.startintray;

	// If PhotoQt is supposed to be started minimized in system tray
	if(startintray) {
		if(a.verbose) std::clog << "Starting minimised to tray" << std::endl;
		// If the option "Use Tray Icon" in the settings is not set, we set it
		QFile set(QDir::homePath() + "/.photoqt/settings");
		if(set.open(QIODevice::ReadOnly)) {
			QTextStream in(&set);
			QString all = in.readAll();
			if(!all.contains("TrayIcon=1")) {
				if(all.contains("TrayIcon=0"))
					all.replace("TrayIcon=0","TrayIcon=1");
				else
					all += "\n[Temporary Appended]\nTrayIcon=1\n";
				set.close();
				set.remove();
				if(!set.open(QIODevice::WriteOnly))
					std::cerr << "ERROR: Can't enable tray icon setting!" << std::endl;
				QTextStream out(&set);
				out << all;
				set.close();
			} else
				set.close();
		} else
			std::cerr << "Unable to ensure TrayIcon is enabled - make sure it is enabled!!" << std::endl;
	}

#if (QT_VERSION >= QT_VERSION_CHECK(5, 4, 0))
	// Opt-in to High DPI usage of Pixmaps for larger screens with larger font DPI
	a.setAttribute(Qt::AA_UseHighDpiPixmaps, true);
#endif

	// LOAD THE TRANSLATOR
	QTranslator trans;

	// We use two strings, since the system locale usually is of the form e.g. "de_DE"
	// and some translations only come with the first part, i.e. "de",
	// and some with the full string. We need to be able to find both!
	if(a.verbose) std::clog << "Checking for translation" << std::endl;
	QString code1 = "";
	QString code2 = "";
	if(settingsFileTxt.contains("Language=") && !settingsFileTxt.contains("Language=en") && !settingsFileTxt.contains("Language=\n")) {
		code1 = settingsFileTxt.split("Language=").at(1).split("\n").at(0).trimmed();
		code2 = code1;
	} else if(!settingsFileTxt.contains("Language=en")) {
		code1 = QLocale::system().name();
		code2 = QLocale::system().name().split("_").at(0);
	}
	if(a.verbose) std::clog << "Found following language: " << code1.toStdString()  << "/" << code2.toStdString() << std::endl;
	if(QFile(":/lang/photoqt_" + code1 + ".qm").exists()) {
		std::clog << "Loading Translation:" << code1.toStdString() << std::endl;
		trans.load(":/lang/photoqt_" + code1);
		a.installTranslator(&trans);
		code2 = code1;
	} else if(QFile(":/lang/photoqt_" + code2 + ".qm").exists()) {
		std::clog << "Loading Translation:" << code2.toStdString() << std::endl;
		trans.load(":/lang/photoqt_" + code2);
		a.installTranslator(&trans);
		code1 = code2;
	}

	// Check if thumbnail database exists. If not, create it
	QFile database(QDir::homePath() + "/.photoqt/thumbnails");
	if(!database.exists()) {

		if(a.verbose) std::clog << "Create Thumbnail Database" << std::endl;

		QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", "thumbDB1");
		db.setDatabaseName(QDir::homePath() + "/.photoqt/thumbnails");
		if(!db.open()) std::cerr << "ERROR: Couldn't open thumbnail database:" << db.lastError().text().trimmed().toStdString() << std::endl;
		QSqlQuery query(db);
		query.prepare("CREATE TABLE Thumbnails (filepath TEXT,thumbnail BLOB, filelastmod INT, thumbcreated INT, origwidth INT, origheight INT)");
		query.exec();
		if(query.lastError().text().trimmed().length()) std::cerr << "ERROR (Creating Thumbnail Datbase):" << query.lastError().text().trimmed().toStdString() << std::endl;
		query.clear();


	} else {

		if(a.verbose) std::clog << "Opening Thumbnail Database" << std::endl;

		// Opening the thumbnail database
		QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE","thumbDB2");
		db.setDatabaseName(QDir::homePath() + "/.photoqt/thumbnails");
		if(!db.open()) std::cerr << "ERROR: Couldn't open thumbnail database:" << db.lastError().text().trimmed().toStdString() << std::endl;

		QSqlQuery query_check(db);
		query_check.prepare("SELECT COUNT( * ) AS 'Count' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Thumbnails' AND COLUMN_NAME = 'origwidth'");
		query_check.exec();
		query_check.next();
		if(query_check.record().value(0) == 0) {
			QSqlQuery query(db);
			query.prepare("ALTER TABLE Thumbnails ADD COLUMN origwidth INT");
			query.exec();
			if(query.lastError().text().trimmed().length()) std::cerr << "ERROR (Adding origwidth to Thumbnail Database):" << query.lastError().text().trimmed().toStdString() << std::endl;
			query.clear();
			query.prepare("ALTER TABLE Thumbnails ADD COLUMN origheight INT");
			query.exec();
			if(query.lastError().text().trimmed().length()) std::cerr << "ERROR (Adding origheight to Thumbnail Database):" << query.lastError().text().trimmed().toStdString() << std::endl;
			query.clear();
		}
		query_check.clear();

	}

	qApp->setQuitOnLastWindowClosed(true);

	/***************************
	 ***************************/
	// The Window has to be initialised *AFTER* the checks above to ensure that the settings exist and are updated and can be loaded
//		MainWindow w(0,verbose);
	MainWindow w(0);
	/***************************
	 ***************************/

	QObject::connect(&a, SIGNAL(interaction(QString)), &w, SLOT(remoteAction(QString)));

	// We move from old way of handling image formats to new way
	// We can't do it before here, since we need access to global settings
	QFile fileformatsFile(QDir::homePath() + "/.photoqt/fileformats.disabled");
	if(!fileformatsFile.exists()) {

		// File content of disabled fileformats
		QString fileformatsDisabled = "*.epi\n";
		fileformatsDisabled += "*.epsi\n";
		fileformatsDisabled += "*.eps\n";
		fileformatsDisabled += "*.epsf\n";
		fileformatsDisabled += "*.eps2\n";
		fileformatsDisabled += "*.eps3\n";
		fileformatsDisabled += "*.ept\n";
		fileformatsDisabled += "*.pdf\n";
		fileformatsDisabled += "*.ps\n";
		fileformatsDisabled += "*.ps2\n";
		fileformatsDisabled += "*.ps3\n";
		fileformatsDisabled += "*.hp\n";
		fileformatsDisabled += "*.hpgl\n";
		fileformatsDisabled += "*.jbig\n";
		fileformatsDisabled += "*.jbg\n";
		fileformatsDisabled += "*.pwp\n";
		fileformatsDisabled += "*.rast\n";
		fileformatsDisabled += "*.rla\n";
		fileformatsDisabled += "*.rle\n";
		fileformatsDisabled += "*.sct\n";
		fileformatsDisabled += "*.tim\n";
		fileformatsDisabled += "**.psb\n";
		fileformatsDisabled += "**.psd\n";
		fileformatsDisabled += "**.xcf\n";

		// Write 'disabled filetypes' file
		if(fileformatsFile.open(QIODevice::WriteOnly)) {
			QTextStream out(&fileformatsFile);
			out << fileformatsDisabled;
			fileformatsFile.close();
		} else
			std::cerr << "ERROR: Can't write default disabled fileformats file" << std::endl;


		// Update settings with new values
		w.setDefaultFileFormats();

	}

	// DISPLAY MAINWINDOW
	w.showFullScreen();
	if(!startintray) {
		bool keepOnTop = settingsFileTxt.contains("KeepOnTop=1");
		if(settingsFileTxt.contains("WindowMode=1")) {
			if(keepOnTop) {
				settingsFileTxt.contains("WindowDecoration=1")
						  ? w.setFlags(Qt::Window | Qt::WindowStaysOnTopHint)
						  : w.setFlags(Qt::Window | Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint);
			} else {
				settingsFileTxt.contains("WindowDecoration=1")
						  ? w.setFlags(Qt::Window)
						  : w.setFlags(Qt::Window | Qt::FramelessWindowHint);
			}

			QSettings settings("photoqt","photoqt");
			if(settings.allKeys().contains("mainWindowGeometry") && settingsFileTxt.contains("SaveWindowGeometry=1")) {
				w.show();
				w.setGeometry(settings.value("mainWindowGeometry").toRect());
			} else
				w.showMaximized();

		} else {
			if(keepOnTop) w.setFlags(Qt::WindowStaysOnTopHint | Qt::FramelessWindowHint);
			QString(getenv("DESKTOP")).startsWith("Enlightenment") ? w.showMaximized() : w.showFullScreen();
		}
	} else
		w.hide();

	// Possibly disable thumbnails
	if(a.nothumbs) {
		if(a.verbose) std::clog << "Disabling Thumbnails" << std::endl;
		w.disableThumbnails();
	}

	w.startup_filename = a.filename;
	QTimer::singleShot(100, &w, SLOT(openNewFile()));

	return a.exec();


}

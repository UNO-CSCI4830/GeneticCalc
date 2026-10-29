import sys
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQuick import QQuickView

from backend import CrossBackend

QML_DIR = Path(__file__).resolve().parent / "qml"

def main() -> int:
    app = QGuiApplication(sys.argv)
    view = QQuickView()
    view.setTitle("Genetic Cross Calculator")
    view.setResizeMode(QQuickView.ResizeMode.SizeRootObjectToView)
    view.engine().addImportPath(str(QML_DIR))


    backend = CrossBackend()
    view.rootContext().setContextProperty("backend", backend)

    view.setSource(QUrl.fromLocalFile(str(QML_DIR / "gencalcuiv3.qml")))

    if view.status() == QQuickView.Status.Error:
        for err in view.errors():
            print(err.toString(), file=sys.stderr)
        return 1

    view.resize(1024, 559)
    view.setMinimumSize(view.size())
    view.show()
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
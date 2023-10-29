import itertools
import os
import sys
import traceback
import winreg
from pathlib import Path

import PySide6.QtCore as QtCore
import PySide6.QtGui as QtGui
import PySide6.QtWidgets as QtWidgets
from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QListWidget, QStackedWidget,
    QPushButton, QHBoxLayout, QFileDialog, QLabel, QLineEdit
)

from InstallerParams import InstallerParams
from WorkerThread import WorkerThread

PAGE_NAME_OPTIONS = "Options"
# PAGE_NAME_OPTIONS_CUSTOM = "Options"
PAGE_NAME_CONVERT = "Convert"
PAGE_NAME_FINISH = "Finish"

SIDEBAR_ITEMS = [PAGE_NAME_OPTIONS, PAGE_NAME_CONVERT, PAGE_NAME_FINISH]


def get_game_path(game: str):
    try:
        registry_key = winreg.OpenKey(
            winreg.HKEY_LOCAL_MACHINE,
            f"SOFTWARE\\Wow6432Node\\Bethesda Softworks\\{game}"
        )

        game_path, _ = winreg.QueryValueEx(
            registry_key, "installed path")
        winreg.CloseKey(registry_key)
        return game_path
    except FileNotFoundError:
        # Handle the error if the key or value does not exist
        print("Registry key or value not found.")
        return None
    except Exception as e:
        # Handle other possible exceptions
        print(f"An error occurred: {e}")
        return None


def check_fallout4_installation(path_str: str):
    path = Path(path_str)

    if not path.exists():
        return False, f"Path {path_str} does not exist."

    fallout4_exe_path = path / "Fallout4.exe"

    if not fallout4_exe_path.exists():
        return False, f"Fallout4.exe not found at \"{fallout4_exe_path}\"."

    elric_path = path / "Tools\\Elric\\Elrich.exe"

    if not elric_path.exists():
        return (
            False,
            f"Elrich.exe not found at \"{elric_path}\". "
            f"Is the Fallout 4 Creation Kit installed?"
        )

    return True, "Success"


def check_falloutnv_installation(path_str: str):
    path = Path(path_str)

    if not path.exists():
        return False, f"Path {path_str} does not exist."

    fallout_nv_path = path / "FalloutNV.exe"

    if not fallout_nv_path.exists():
        return False, f"FalloutNV.exe not found at \"{fallout_nv_path}\"."

    return True, "Success"


class PageData:
    name: str
    goto: callable
    index: int

    def __init__(self, name: str):
        self.name = name
        self.index = SIDEBAR_ITEMS.index(name)


class InterruptException(Exception):
    pass


class DeletePathThread(QtCore.QThread):
    task_done = QtCore.Signal()
    output_received = QtCore.Signal(str)

    def __init__(self, paths: list[Path]):
        super().__init__()

        self.paths = paths
        self._stop_flag = False
        self.failed = False
        self.interrupted = False
        self.mutex = QtCore.QMutex()

    def run(self):
        try:
            for path in self.paths:
                self.stop_if_requested()

                self.output_received.emit(f"Deleting \"{path}\"...")

                self.delete_all_in_directory(path)

                if path.exists():
                    # noinspection PyBroadException
                    try:
                        path.rmdir()
                    except Exception:
                        traceback.print_exc()

                        self.failed = True
        except InterruptException:
            self.interrupted = True

            pass

        self.task_done.emit()

    def stop(self):
        self.mutex.lock()
        self._stop_flag = True
        self.mutex.unlock()

    def stop_if_requested(self):
        self.mutex.lock()

        if self._stop_flag:
            self.mutex.unlock()

            raise InterruptException()

        self.mutex.unlock()

    def delete_all_in_directory(self, root_dir):
        # List all files and directories in the current directory
        for item in os.listdir(root_dir):
            self.stop_if_requested()

            item_path = os.path.join(root_dir, item)

            # If it's a directory, recursively delete its contents
            if os.path.isdir(item_path):
                self.delete_all_in_directory(item_path)

                # Once all contents of the directory are deleted, delete the
                # directory itself
                # noinspection PyBroadException
                try:
                    os.rmdir(item_path)
                except Exception:
                    traceback.print_exc()

                    self.failed = True
            else:
                # Delete the file
                # noinspection PyBroadException
                try:
                    os.remove(item_path)
                except Exception:
                    traceback.print_exc()

                    self.failed = True


class ProcessingDialog(QtWidgets.QDialog):
    def __init__(self, worker):
        super().__init__()
        self.worker = worker
        self.init_ui()

    def init_ui(self):
        layout = QVBoxLayout()
        self.label = QLabel("Processing...")
        self.label.setMinimumWidth(200)
        self.label.setMinimumHeight(100)
        self.label.setWordWrap(True)
        layout.addWidget(self.label)

        # Add Cancel button and connect its slot
        cancel_button = QPushButton("Cancel")
        cancel_button.clicked.connect(self.cancel_task)
        layout.addWidget(cancel_button)

        self.setLayout(layout)

        # Start the worker thread
        self.worker.task_done.connect(self.on_task_done)
        self.worker.output_received.connect(self.update_output)

        self.worker.start()

    @QtCore.Slot()
    def cancel_task(self):
        self.worker.stop()

    @QtCore.Slot()
    def on_task_done(self):
        self.close()

    @QtCore.Slot(str)
    def update_output(self, text):
        self.label.setText(text)


class Installer(QWidget):
    def __init__(self, params: InstallerParams = None):
        super().__init__()

        self.params = params

        self.setWindowTitle("FNV to FO4")

        # Main layout
        layout = QHBoxLayout(self)

        # Sidebar
        self.sidebar = QListWidget(self)

        self.sidebar.addItems(SIDEBAR_ITEMS)
        self.sidebar.setCurrentRow(0)
        self.sidebar.setMaximumWidth(150)
        self.sidebar.setEnabled(False)  # Make sidebar non-interactable
        layout.addWidget(self.sidebar)

        # Content area
        self.pages = QStackedWidget(self)
        layout.addWidget(self.pages)

        self.page_options = PageData(
            name=PAGE_NAME_OPTIONS,
        )

        # self.page_options_custom = PageData("Options")

        self.page_convert = PageData(
            name=PAGE_NAME_CONVERT,
        )

        self.page_finish = PageData(
            name=PAGE_NAME_FINISH,
        )

        # First step page
        self.pages.addWidget(self.create_welcome_page())
        self.pages.addWidget(self.create_config_page())
        self.pages.addWidget(self.create_finish_page())

        # Connect sidebar selection change to update displayed page
        self.sidebar.currentRowChanged.connect(self.pages.setCurrentIndex)

    def create_directory_selector(self, label_text, line_edit_text=None,
                                  input_check_func=None):
        """Utility function to create a directory selector."""
        layout = QVBoxLayout()

        status_label = QLabel()
        status_label.setAlignment(Qt.AlignmentFlag.AlignTop)
        status_label.setContentsMargins(0, 0, 0, 0)
        status_label.setWordWrap(True)

        def update_status(line_edit_text_value):
            if (input_check_func is not None and
                    line_edit_text_value is not None):
                success, error_message = input_check_func(line_edit_text_value)

                status_label.setText(error_message)

                if success:
                    status_label.setStyleSheet("color: green;")
                else:
                    status_label.setStyleSheet("color: red;")

        update_status(line_edit_text)

        h_layout = QHBoxLayout()
        label = QLabel(label_text)
        label.setFixedWidth(100)
        line_edit = QLineEdit(line_edit_text)
        line_edit.textChanged.connect(lambda: update_status(line_edit.text()))
        button = QPushButton("Browse")
        button.clicked.connect(
            lambda: self.browse_directory(line_edit, update_status))
        h_layout.addWidget(label)
        h_layout.addWidget(line_edit)
        h_layout.addWidget(button)

        layout.addLayout(h_layout)
        layout.addWidget(status_label)

        return layout, line_edit

    def browse_directory(self, line_edit, update_status):
        """
        Open a directory dialog and update the line edit with the selected
        directory.
        """
        directory = QFileDialog.getExistingDirectory(self, "Select Directory")
        if directory:
            line_edit.setText(directory)

            update_status(directory)

    def create_welcome_page(self):
        page = QWidget()
        layout = QVBoxLayout()

        welcome_label = QLabel("Welcome to FNV to FO4")
        welcome_label.setAlignment(Qt.AlignmentFlag.AlignTop)

        layout.addWidget(welcome_label)

        self.next_btn = QPushButton("Start")
        self.next_btn.clicked.connect(self.goto_convert_page)

        installation_label = QLabel("Select installation / output paths:")
        installation_label.setAlignment(Qt.AlignmentFlag.AlignBottom)
        layout.addWidget(installation_label)

        falloutnv_path = get_game_path("falloutnv")

        self.directory1, self.directory1_line_edit = (
            self.create_directory_selector(
                "Fallout: New Vegas",
                line_edit_text=falloutnv_path,
                input_check_func=check_falloutnv_installation,
            )
        )

        fallout4_path = get_game_path("Fallout4")

        self.directory2, self.directory2_line_edit = (
            self.create_directory_selector(
                "Fallout 4",
                line_edit_text=fallout4_path,
                input_check_func=check_fallout4_installation,
            )
        )
        self.directory3, self.directory3_line_edit = (
            self.create_directory_selector(
                "Output",
                line_edit_text=str(Path(os.getcwd()) / "output")
            )
        )

        layout.addLayout(self.directory1)
        layout.addLayout(self.directory2)
        layout.addLayout(self.directory3)

        self.install_mode_selector = self.create_install_mode_selector()
        layout.addLayout(self.install_mode_selector)

        layout.addWidget(self.next_btn)

        page.setLayout(layout)

        return page

    def create_install_mode_selector(self):
        layout = QVBoxLayout()

        express_layout = QHBoxLayout()

        # Radio button for male
        self.radio_button_express = (
            QtWidgets.QRadioButton(text="Express conversion", checked=True))

        combobox1 = QtWidgets.QComboBox()
        combobox1.addItem('Base game')
        combobox1.setEnabled(False)

        # adding signal and slot
        self.radio_button_express.toggled.connect(self.express_mode_selected)

        express_layout.addWidget(self.radio_button_express)
        express_layout.addWidget(combobox1)

        # Radio button for female
        self.radio_button_custom = (
            QtWidgets.QRadioButton(text="Custom conversion"))
        self.radio_button_custom.setCheckable(False)
        self.radio_button_custom.setEnabled(False)

        # adding signal and slot
        self.radio_button_custom.toggled.connect(self.custom_mode_selected)

        layout.addLayout(express_layout)
        layout.addWidget(self.radio_button_custom)

        return layout

    def express_mode_selected(self, selected):
        if selected:
            self.next_btn.setText("Start")
            self.next_btn.clicked.connect(self.goto_convert_page)

    def custom_mode_selected(self, selected):
        if selected:
            self.next_btn.setText("Next")
            self.next_btn.clicked.connect(self.goto_convert_page)

    def create_config_page(self):
        page = QWidget()
        layout = QVBoxLayout()
        layout.addWidget(QLabel("Conversion logs"))

        self.text_edit = QtWidgets.QTextEdit()
        layout.addWidget(self.text_edit)

        # You'd typically have configuration input widgets here

        self.conversion_next_btn = QPushButton()
        self.conversion_next_btn_connections = []

        layout.addWidget(self.conversion_next_btn)

        page.setLayout(layout)
        return page

    def cancel_conversion(self):
        self.thread.stop()

    def on_conversion_done(self):
        if self.thread.interrupted:
            self.conversion_next_btn.setText("Back")
            self.add_conversion_next_button_connection(self.goto_start_page)
        else:
            self.conversion_next_btn.setText("Next")
            self.add_conversion_next_button_connection(self.goto_finish_page)

    def create_finish_page(self):
        page = QWidget()
        layout = QVBoxLayout()
        layout.addWidget(QLabel("Conversion complete"))

        close_btn = QPushButton("Close")
        close_btn.clicked.connect(self.close)
        layout.addWidget(close_btn)

        page.setLayout(layout)
        return page

    def convert_not_ready(self, reason: str):
        QtWidgets.QMessageBox.critical(self, "Error", reason)

    def clear_output_directories(
            self, extracted_path: Path, temp_path: Path, output_path: Path):
        dlg = QtWidgets.QMessageBox(self)
        dlg.setWindowTitle("Files from a previous conversion exist")
        dlg.setText(
            f"The following directories need to be empty:\n"
            f"- Extracted: {extracted_path}\n"
            f"- Temp: {temp_path}\n"
            f"- Output: {output_path}\n"
            "Clear these directories now?"
        )
        dlg.setStandardButtons(
            QtWidgets.QMessageBox.StandardButton.Yes |
            QtWidgets.QMessageBox.StandardButton.No
        )
        dlg.setIcon(QtWidgets.QMessageBox.Icon.Question)
        button = dlg.exec()

        if button == QtWidgets.QMessageBox.StandardButton.Yes:
            paths = []

            for path in itertools.chain(
                    extracted_path.iterdir(),
                    temp_path.iterdir(),
                    output_path.iterdir()
            ):
                if path.name.lower() not in {
                    "meshes",
                    "textures",
                    "lodsettings",
                    "materials",
                } and path.suffix.lower() not in {
                    ".esm",
                    ".esp",
                }:
                    self.convert_not_ready(
                        f"Unexpected file or directory found in output path: "
                        f"\"{path}\". Please clear the output directory "
                        f"manually and try again.")

                paths.append(path)

            processing_dialog = ProcessingDialog(DeletePathThread(paths))

            processing_dialog.exec()

            if processing_dialog.worker.interrupted:
                return False

            if processing_dialog.worker.failed:
                self.convert_not_ready(
                    "Failed to clear output directory. "
                    "Please clear the output directory manually and try again."
                )

                return False

            return True
        else:
            return False

    def add_conversion_next_button_connection(self, connection):
        self.conversion_next_btn_connections.append(connection)
        self.conversion_next_btn.clicked.connect(connection)

    def clear_conversion_next_button_connections(self):
        for connection in self.conversion_next_btn_connections:
            self.conversion_next_btn.clicked.disconnect(connection)

        self.conversion_next_btn_connections.clear()

    def goto_convert_page(self):
        self.clear_conversion_next_button_connections()

        self.add_conversion_next_button_connection(self.cancel_conversion)

        self.conversion_next_btn.setText("Cancel")

        fnv_path = Path(self.directory1_line_edit.text())
        fo4_path = Path(self.directory2_line_edit.text())
        output_path = Path(self.directory3_line_edit.text())
        extracted_path = Path(os.getcwd()) / "extracted"
        temp_path = Path(os.getcwd()) / "temp"

        for success, msg in [
            check_falloutnv_installation(str(fnv_path)),
            check_fallout4_installation(str(fo4_path)),
        ]:
            if not success:
                self.convert_not_ready(msg)

                return

        output_path.mkdir(parents=True, exist_ok=True)

        resources = [
            fnv_path / "Data" / "Fallout - Meshes.bsa",
            fnv_path / "Data" / "Fallout - Textures.bsa",
            fnv_path / "Data" / "Fallout - Textures2.bsa",
            fnv_path / "Data" / "Update.bsa",
            fnv_path / "Data" / "FalloutNV.esm",
        ]

        plugins = [
            path.name for path in resources
            if path.suffix.lower() in {".esm", ".esp"}
        ]

        for plugin in plugins:
            plugin_path = fo4_path / "Data" / plugin

            if plugin_path.exists():
                if not self.params.ignore_existing_files:
                    self.convert_not_ready(
                        f"Plugin \"{plugin}\" already exists in "
                        f"\"{plugin_path}\". "
                        f"Please remove it and try again."
                    )

                    return
                else:
                    print(f"Ignoring existing plugin \"{plugin}\".")

        if (list(extracted_path.iterdir()) or
                list(temp_path.iterdir()) or
                list(output_path.iterdir())):
            if not self.params.ignore_existing_files:
                if not self.clear_output_directories(
                        extracted_path=extracted_path,
                        temp_path=temp_path,
                        output_path=output_path,
                ):
                    return
            else:
                print("Ignoring existing files.")

        # Change page.
        self.pages.setCurrentIndex(self.page_convert.index)
        self.sidebar.setCurrentRow(self.page_convert.index)

        # Start worker thread.
        self.start_subprocess(
            fnv_path=fnv_path,
            fo4_path=fo4_path,
            extracted_path=extracted_path,
            temp_path=temp_path,
            output_path=output_path,
            resources=resources,
        )

    def goto_start_page(self):
        self.pages.setCurrentIndex(self.page_options.index)
        self.sidebar.setCurrentRow(self.page_options.index)

    def goto_finish_page(self):
        self.pages.setCurrentIndex(self.page_finish.index)
        self.sidebar.setCurrentRow(self.page_finish.index)

    def start_subprocess(
            self,
            fnv_path: Path,
            fo4_path: Path,
            extracted_path: Path,
            temp_path: Path,
            output_path: Path,
            resources: list[Path]
    ):
        self.text_edit.clear()

        self.thread = WorkerThread(
            fnv_path=fnv_path,
            fo4_path=fo4_path,
            extracted_path=extracted_path,
            temp_path=temp_path,
            output_path=output_path,
            resources=resources,
            installer_params=self.params,
        )

        self.thread.output_received.connect(self.update_output)
        self.thread.exception_occurred.connect(self.handle_exception)
        self.thread.task_done.connect(self.on_conversion_done)

        self.thread.start()

    def update_output(self, text):
        self.text_edit.insertPlainText(text)
        self.text_edit.moveCursor(QtGui.QTextCursor.MoveOperation.End)

    def handle_exception(self, exception):
        QtWidgets.QMessageBox.critical(
            self, "Error", f"An exception occurred: {exception}")
        self.thread.quit()


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser()

    parser.add_argument("--skip_bsas", action="store_true")
    parser.add_argument("--skip_meshes", action="store_true")
    parser.add_argument("--skip_optimize", action="store_true")
    parser.add_argument("--skip_data_files", action="store_true")
    parser.add_argument("--skip_plugin_extract", action="store_true")
    parser.add_argument("--skip_plugin_import", action="store_true")
    parser.add_argument("--ignore_existing_files", action="store_true")
    parser.add_argument("--debug", action="store_true")

    args = parser.parse_args()

    app = QApplication(sys.argv)

    window = Installer(params=InstallerParams(
        skip_bsas=args.skip_bsas,
        skip_meshes=args.skip_meshes,
        skip_optimize=args.skip_optimize,
        skip_data=args.skip_data_files,
        skip_plugin_extract=args.skip_plugin_extract,
        skip_plugin_import=args.skip_plugin_import,
        ignore_existing_files=args.ignore_existing_files,
        debug=args.debug,
    ))

    window.resize(600, 400)
    window.show()
    sys.exit(app.exec())

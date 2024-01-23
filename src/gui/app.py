import itertools
import os
import sys
import traceback
import winreg
from pathlib import Path
import json

import PySide6.QtCore as QtCore
import PySide6.QtGui as QtGui
import PySide6.QtWidgets as QtWidgets
from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QListWidget, QStackedWidget,
    QPushButton, QHBoxLayout, QFileDialog, QLabel, QLineEdit
)

from InstallerParams import InstallerParams
from WorkerThread import WorkerThread, LOOSE_FILES_PLUGIN_NAME
from ProcessingDialog import ProcessingDialog
from DeletePathThread import DeletePathThread
from PluginData import PluginData

PAGE_NAME_OPTIONS = "Options"
# PAGE_NAME_OPTIONS_CUSTOM = "Options"
PAGE_NAME_CONVERT = "Convert"
PAGE_NAME_FINISH = "Finish"

REQUIRED_PATHS = [
    Path("build\\nifskope_converter\\release\\NifSkope.exe"),
    Path("build\\xedit_converter\\xEdit.exe"),
    Path("bin\\bsab\\bsab.exe"),
]

SIDEBAR_ITEMS = [PAGE_NAME_OPTIONS, PAGE_NAME_CONVERT, PAGE_NAME_FINISH]

DEBUG = False


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

    archive2_path = path / "Tools" / "Archive2" / "Archive2.exe"

    if not archive2_path.exists():
        return (
            False,
            f"Archive2.exe not found at \"{archive2_path}\". "
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

        self.page_options_custom = PageData(
            name=PAGE_NAME_OPTIONS,
        )
        self.page_options_custom.index = len(SIDEBAR_ITEMS)

        self.templates = self.load_templates()

        # First step page
        self.pages.addWidget(self.create_welcome_page())
        self.pages.addWidget(self.create_config_page())
        self.pages.addWidget(self.create_finish_page())
        self.pages.addWidget(self.create_custom_options_page())

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

    def get_fnv_data_path(self):
        fnv_data_path = Path(self.directory1_line_edit.text()) / "Data"

        if not fnv_data_path.exists():
            raise FileNotFoundError(
                f"Path \"{fnv_data_path}\" does not exist.")

        return fnv_data_path

    def open_file_dialog(self):
        fnv_data_path = self.get_fnv_data_path()

        files, _ = QFileDialog.getOpenFileNames(
            self, 'Open File',
            dir=str(fnv_data_path),
            filter="*.bsa *.esm *.esp"
        )

        if files:
            for file in files:
                self.list_widget.addItem(file)

    def open_folder_dialog(self):
        fnv_data_path = self.get_fnv_data_path()

        folder = QFileDialog.getExistingDirectory(
            self, 'Open Folder', dir=str(fnv_data_path))
        if folder:
            self.list_widget.addItem(folder)

    def clear_list(self):
        self.list_widget.clear()

    def create_custom_options_page(self):
        page = QWidget()
        layout = QVBoxLayout()

        welcome_label = QLabel("Custom conversion")
        welcome_label.setAlignment(Qt.AlignmentFlag.AlignTop)

        layout.addWidget(welcome_label)

        file_options_layout = QHBoxLayout()

        # Create buttons for file/folder selection and list clearing
        self.btn_select_files = QPushButton('Select Files')
        self.btn_select_folders = QPushButton('Select Folders')
        self.btn_clear_list = QPushButton('Clear List')

        # Create a list widget to display selected files/folders
        self.list_widget = QListWidget()

        # Connect buttons to their respective functions
        self.btn_select_files.clicked.connect(self.open_file_dialog)
        self.btn_select_folders.clicked.connect(self.open_folder_dialog)
        self.btn_clear_list.clicked.connect(self.clear_list)

        # Add widgets to the layout
        file_options_layout.addWidget(self.btn_select_files)
        file_options_layout.addWidget(self.btn_select_folders)
        file_options_layout.addWidget(self.btn_clear_list)
        layout.addLayout(file_options_layout)
        layout.addWidget(self.list_widget)

        navbox_layout = QHBoxLayout()

        self.custom_options_back_btn = QPushButton("Back")
        self.custom_options_back_btn.clicked.connect(self.goto_start_page)
        self.custom_options_next_btn = QPushButton("Start")
        self.custom_options_next_btn.clicked.connect(
            lambda: self.goto_convert_page(using_custom_options=True))

        # checkbox_skip_bsas = QtWidgets.QCheckBox("Skip BSAs")
        # # checkbox_skip_bsas.stateChanged.connect(
        #
        # layout.addWidget(QtWidgets.QCheckBox("Skip BSAs"))
        # layout.addWidget(QtWidgets.QCheckBox("Skip mesh conversion"))
        # layout.addWidget(QtWidgets.QCheckBox("Skip mesh optimization"))
        # layout.addWidget(QtWidgets.QCheckBox("Skip plugin extract"))
        # layout.addWidget(QtWidgets.QCheckBox("Skip plugin import"))
        # layout.addWidget(QtWidgets.QCheckBox("Ignore existing files"))

        navbox_layout.addWidget(self.custom_options_back_btn)
        navbox_layout.addWidget(self.custom_options_next_btn)

        layout.addLayout(navbox_layout)


        page.setLayout(layout)

        return page

    def load_templates(self):
        with open("src/gui/templates.json") as f:
            templates = json.load(f)

        return templates

    def create_template_options(self):
        self.template_selector = QtWidgets.QComboBox()
        self.template_selector.addItems(self.templates.keys())
        self.template_selector.currentTextChanged.connect(self.template_selected)

        # Initialize current template.
        self.template_selected(self.template_selector.currentText())

        return self.template_selector

    def template_selected(self, selected):
        self.current_template = self.templates[selected]

    def create_install_mode_selector(self):
        layout = QVBoxLayout()

        express_layout = QHBoxLayout()

        # Radio button for male
        self.radio_button_express = (
            QtWidgets.QRadioButton(text="Express conversion", checked=True))

        combobox1 = self.create_template_options()

        # adding signal and slot
        self.radio_button_express.toggled.connect(self.express_mode_selected)

        express_layout.addWidget(self.radio_button_express)
        express_layout.addWidget(combobox1)

        # Radio button for female
        self.radio_button_custom = (
            QtWidgets.QRadioButton(text="Custom conversion"))
        # self.radio_button_custom.setCheckable(False)
        # self.radio_button_custom.setEnabled(False)

        # adding signal and slot
        self.radio_button_custom.toggled.connect(self.custom_mode_selected)

        layout.addLayout(express_layout)
        layout.addWidget(self.radio_button_custom)

        return layout

    def express_mode_selected(self, selected):
        if selected:
            self.next_btn.setText("Start")
            self.next_btn.clicked.disconnect(self.goto_custom_options_page)
            self.next_btn.clicked.connect(self.goto_convert_page)


    def custom_mode_selected(self, selected):
        if selected:
            self.next_btn.setText("Next")
            self.next_btn.clicked.disconnect(self.goto_convert_page)
            self.next_btn.clicked.connect(self.goto_custom_options_page)

    def create_config_page(self):
        page = QWidget()
        layout = QVBoxLayout()
        layout.addWidget(QLabel("Conversion logs"))

        self.text_length = 0
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
                    ".ba2",
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

    def goto_convert_page(self, using_custom_options=False):
        self.clear_conversion_next_button_connections()

        self.add_conversion_next_button_connection(self.cancel_conversion)

        self.conversion_next_btn.setText("Cancel")

        fnv_path = Path(self.directory1_line_edit.text())
        fo4_path = Path(self.directory2_line_edit.text())
        output_path = Path(self.directory3_line_edit.text())
        extracted_path = Path(os.getcwd()) / "extracted"
        temp_path = Path(os.getcwd()) / "temp"

        output_path.mkdir(parents=True, exist_ok=True)
        extracted_path.mkdir(parents=True, exist_ok=True)
        temp_path.mkdir(parents=True, exist_ok=True)

        for success, msg in [
            check_falloutnv_installation(str(fnv_path)),
            check_fallout4_installation(str(fo4_path)),
        ]:
            if not success:
                self.convert_not_ready(msg)

                return

        # resources = []
        plugins: list[PluginData] = []

        if using_custom_options:
            # Create a plugin for loose files.
            no_bsa_plugin = PluginData(
                name=LOOSE_FILES_PLUGIN_NAME,
                path=fnv_path / "Data" / LOOSE_FILES_PLUGIN_NAME,
                resources=[]
            )

            for index in range(self.list_widget.count()):
                item = self.list_widget.item(index)
                item_text = item.text()

                if item_text.endswith(".esp") or item_text.endswith(".esm"):
                    plugins.append(PluginData(
                        name=item_text,
                        path=fnv_path / "Data" / item_text,
                        resources=[]
                    ))
                else:
                    no_bsa_plugin.resources.append(fnv_path / "Data" / item_text)

            if no_bsa_plugin.resources:
                plugins.append(no_bsa_plugin)
        else:
            for _dict in self.current_template["plugins"]:
                plugin_data = PluginData(
                    name=_dict["name"],
                    path=fnv_path / "Data" / _dict["name"],
                    resources=[
                        fnv_path / "Data" / v
                        for v in _dict["resources"]
                    ]
                )

                plugins.append(plugin_data)

            # PluginData()
            #
            # resources = [
            #     fnv_path / "Data" / v
            #     for v in self.current_template["resources"]
            # ]

        # plugins = [
        #     path.name for path in resources
        #     if path.suffix.lower() in {".esm", ".esp"}
        # ]

        for plugin in plugins:
            plugin_path = fo4_path / "Data" / plugin.name

            if plugin_path.exists():
                if not self.params.ignore_existing_files:
                    self.convert_not_ready(
                        f"Plugin \"{plugin.name}\" already exists in "
                        f"\"{plugin_path}\". "
                        f"Please remove it and try again."
                    )

                    return
                else:
                    print(f"Ignoring existing plugin \"{plugin_path}\".")

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
            resources=plugins,
        )

    def goto_start_page(self):
        self.pages.setCurrentIndex(self.page_options.index)
        self.sidebar.setCurrentRow(self.page_options.index)

    def goto_finish_page(self):
        self.pages.setCurrentIndex(self.page_finish.index)
        self.sidebar.setCurrentRow(self.page_finish.index)

    def goto_custom_options_page(self):
        self.pages.setCurrentIndex(self.page_options_custom.index)
        self.sidebar.setCurrentRow(self.page_options.index)

    def start_subprocess(
            self,
            fnv_path: Path,
            fo4_path: Path,
            extracted_path: Path,
            temp_path: Path,
            output_path: Path,
            resources: list[PluginData]
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
        if self.text_length > 100000:
            new_text = self.text_edit.toPlainText()[-50000:]
            self.text_edit.setPlainText(new_text)
            self.text_length = len(new_text)

        self.text_length += len(text)

        self.text_edit.insertPlainText(text)

        self.params.log_file.write(text)

        self.text_edit.moveCursor(QtGui.QTextCursor.MoveOperation.End)

    def handle_exception(self, exception, exc_type=None, tb=None):
        # Convert traceback to a string if it's provided
        tb_string = "".join(traceback.format_exception(exc_type, exception, tb)) if tb else ""

        # Display the exception and the traceback (if available) in the QMessageBox
        QtWidgets.QMessageBox.critical(
            self,
            "Error",
            f"An exception occurred:\n{exception}\n\nTraceback:\n{tb_string}"
        )
        self.thread.quit()


def error_handler(type_, value, tb):
    traceback.print_exception(type_, value, tb)

    # Convert traceback to a string
    tb_string = "".join(traceback.format_exception(type_, value, tb))

    # Display the exception and the traceback in the QMessageBox
    QtWidgets.QMessageBox.critical(
        None,
        "Error",
        f"An exception occurred:\n{value}\n\nTraceback:\n{tb_string}"
    )


def pre_startup_check():
    error_msg = (
        "Failed to find the required files. "
        "Did you run the application from the correct working directory?"
    )

    failed = False

    for path in REQUIRED_PATHS:
        if path.exists():
            continue

        error_msg += f"\n - {path.absolute()}"

        failed = True

    if not failed:
        return True

    QtWidgets.QMessageBox.critical(None, "Error", error_msg)

    return False


if __name__ == '__main__':
    sys.excepthook = error_handler

    import argparse

    parser = argparse.ArgumentParser()

    parser.add_argument("--skip_bsas", action="store_true")
    parser.add_argument("--skip_meshes", action="store_true")
    parser.add_argument("--skip_optimize", action="store_true")
    parser.add_argument("--skip_data_files", action="store_true")
    parser.add_argument("--skip_plugin_extract", action="store_true")
    parser.add_argument("--skip_plugin_import", action="store_true")
    parser.add_argument("--skip_lod_settings", action="store_true")
    parser.add_argument("--ignore_existing_files", action="store_true")
    parser.add_argument("--debug", action="store_true")

    args = parser.parse_args()

    if args.debug:
        DEBUG = True

    app = QApplication(sys.argv)

    if not pre_startup_check():
        sys.exit(1)

    with open("log.txt", "w") as f:
        window = Installer(params=InstallerParams(
            skip_bsas=args.skip_bsas,
            skip_meshes=args.skip_meshes,
            skip_optimize=args.skip_optimize,
            skip_data=args.skip_data_files,
            skip_plugin_extract=args.skip_plugin_extract,
            skip_plugin_import=args.skip_plugin_import,
            ignore_existing_files=args.ignore_existing_files,
            skip_lod_settings=args.skip_lod_settings,
            debug=args.debug,
            log_file=f,
        ))

        window.resize(600, 400)
        window.show()
        sys.exit(app.exec())

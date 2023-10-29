import os
import shutil
import subprocess
import time
from pathlib import Path

import PySide6.QtCore as QtCore

from InstallerParams import InstallerParams


class InterruptException(Exception):
    pass


class WorkerThread(QtCore.QThread):
    output_received = QtCore.Signal(str)
    exception_occurred = QtCore.Signal(Exception)
    task_done = QtCore.Signal()

    def __init__(
            self,
            fnv_path: Path,
            fo4_path: Path,
            extracted_path: Path,
            temp_path: Path,
            output_path: Path,
            resources: list[Path],
            installer_params: InstallerParams,
    ):
        super().__init__()

        self.archives = [
            resource for resource in resources if resource.suffix == ".bsa"]
        self.plugins = [
            resource for resource in resources
            if resource.suffix in {".esp", ".esm"}
        ]

        self.cwd = Path(os.getcwd())
        self.output_path = output_path
        self.extracted_path = extracted_path
        self.temp_path = temp_path
        self.mutex = QtCore.QMutex()
        self.failed = False
        self.interrupted = False
        self._stop_flag = False
        self.installer_params = installer_params
        self.fnv_path = fnv_path
        self.fo4_path = fo4_path

        self.x_edit_converter_path = self.cwd / "build\\xedit_converter"
        self.x_edit_data_path = self.x_edit_converter_path / "data"
        self.x_edit_exe_path = self.x_edit_converter_path / "xEdit.exe"

    def run(self):
        try:
            if not self.installer_params.skip_bsas:
                self.extract_bsas()

            if not self.installer_params.skip_meshes:
                self.convert_meshes()

            if not self.installer_params.skip_optimize:
                self.optimize_meshes()

            self.move_materials()

            if not self.installer_params.skip_data:
                self.copy_data_files()

            if not self.installer_params.skip_plugin_extract:
                self.extract_plugin_data()

            if not self.installer_params.skip_plugin_import:
                self.import_plugin_data()

            if not self.installer_params.skip_plugin_move:
                self.move_plugins_to_output()
        except InterruptException:
            self.interrupted = True
        except Exception as e:
            self.failed = True

            self.exception_occurred.emit(e)

            if self.installer_params.debug:
                raise

        self.task_done.emit()

    def stop(self):
        self.mutex.lock()
        self._stop_flag = True
        self.mutex.unlock()

    def stop_requested(self):
        self.mutex.lock()

        if self._stop_flag:
            self.mutex.unlock()

            return True

        self.mutex.unlock()

        return False

    def stop_if_requested(self):
        if self.stop_requested():
            raise InterruptException()

    def extract_bsas(self):
        if not self.archives:
            return

        path_bsab = self.cwd / "bin" / "bsab" / "bsab.exe"

        argument_list_meshes = [path_bsab, "-e", "-f", "meshes"]
        argument_list_textures = [path_bsab, "-e", "-f", "textures"]

        for archive in self.archives:
            argument_list_meshes.append(str(archive))
            argument_list_textures.append(str(archive))

        output_path_textures = self.output_path / "textures"

        output_path_textures.mkdir(parents=True, exist_ok=True)

        argument_list_meshes.append(str(self.extracted_path))
        argument_list_textures.append(str(output_path_textures))

        self.output_received.emit("Extracting meshes...")

        process = subprocess.Popen(
            argument_list_meshes,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            # text=True,
            shell=False,
        )

        for line in process.stdout:
            self.output_received.emit(line.decode("utf-8"))

            if self.stop_requested():
                process.kill()

                raise InterruptException

        self.output_received.emit("Extracting meshes... [DONE]")

        self.output_received.emit("Extracting textures...")

        process = subprocess.Popen(
            argument_list_textures,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            # text=True,
            shell=False,
        )

        for line in process.stdout:
            self.output_received.emit(line.decode("utf-8"))

            if self.stop_requested():
                process.kill()

                raise InterruptException

        self.output_received.emit("Extracting textures... [DONE]")

        subprocess.run(
            ["takeown", "/f", str(output_path_textures)],
            check=True)

        nested_textures_path = output_path_textures / "textures"

        if nested_textures_path.exists():
            nested_textures_path.rename(output_path_textures / "new_vegas")

    def run_long_task(self, cmd: list[str] | str, cwd: Path = None,
                      shell=False):
        process = subprocess.Popen(cmd, cwd=cwd, shell=shell)

        while True:
            retcode = process.poll()

            # Process has finished.
            if retcode is not None:
                break

            if self.stop_requested():
                process.kill()

                raise InterruptException

            time.sleep(0.2)

    def convert_meshes(self):
        self.output_received.emit("Converting meshes...")

        path_nifskope = (
                self.cwd / "build\\nifskope_converter\\release\\NifSkope.exe")

        cmd = [
            path_nifskope,
            "--convert",
            str(self.temp_path),
            str(self.extracted_path),
            str(self.extracted_path),
        ]

        self.run_long_task(cmd)

        self.output_received.emit("Converting meshes... [DONE]")

    def optimize_meshes(self):
        self.output_received.emit("Optimizing meshes...\n")

        elric_path = self.fo4_path / "Tools" / "Elric" / "Elrich.exe"
        convert_target = self.temp_path / "meshes"
        elric_output_path = self.output_path / "meshes"
        failed = False

        for _ in range(100):
            self.stop_if_requested()

            command = [
                '"' + str(elric_path) + '"',
                ".\\Settings\\PCMeshes.esf",
                f"-ElricOptions.ConvertTarget=\"{str(convert_target)}\"",
                f"-ElricOptions.OutputDirectory=\"{str(elric_output_path)}\"",
            ]
            command = " ".join(command)

            self.run_long_task(
                command,
                cwd=self.cwd / "src\\models-and-animations\\elric\\",
            )

            source_files_path = os.path.join(str(self.temp_path), "meshes")
            source_files = [os.path.join(dp, f) for dp, dn, filenames in
                            os.walk(source_files_path) for f in filenames]
            existing_files = []

            for file in source_files:
                self.stop_if_requested()

                relative_path = file.removeprefix(str(self.temp_path) + "\\")
                dest_path = self.output_path / relative_path

                if not os.path.isfile(dest_path):
                    if not failed:
                        self.output_received.emit("[FAILED]\n")

                    self.output_received.emit(f"Failed: {relative_path}\n")

                    os.remove(file)
                    failed = True

                    break

                existing_files.append(file)

            for file in existing_files:
                self.stop_if_requested()

                os.remove(file)

            if not failed:
                break

        if failed:
            self.output_received.emit(
                f"Some meshes failed to optimize and will not be included in "
                f"the output.\n")

        self.output_received.emit("Optimizing meshes... [DONE]\n")

    def move_materials(self):
        self.output_received.emit("Moving materials...\n")

        if not (self.temp_path / "materials").exists():
            print("No materials to move")

            self.output_received.emit("Moving materials... [DONE]\n")

            return

        shutil.move(
            src=str(self.temp_path / "materials"),
            dst=str(self.output_path / "materials"),
        )

        self.output_received.emit("Moving materials... [DONE]\n")

    def copy_data_files(self):
        self.output_received.emit("Copying data files...\n")

        data_files_dir = self.cwd / "src" / "data"

        # Iterate over the files and subdirectories in the source directory
        for item in data_files_dir.iterdir():
            source_item = os.path.join(data_files_dir, item)
            destination_item = os.path.join(self.output_path, item.name)

            if os.path.isdir(source_item):
                shutil.copytree(source_item, destination_item)
            else:
                shutil.copy(source_item, destination_item)

        self.output_received.emit("Copying data files... [DONE]\n")

    def extract_plugin_data(self):
        self.output_received.emit("Extract plugin data...\n")

        if not self.plugins:
            self.output_received.emit("No plugins to convert\n")
            self.output_received.emit("Extract plugin data... [DONE]\n")

            return

        x_edit_mode = "-FNV"

        if len(self.plugins) > 1:
            raise NotImplementedError("Multiple plugins not supported yet")

        x_edit_plugin = self.plugins[0]

        command = [
            self.x_edit_exe_path,
            x_edit_mode,
            "-script:Extract",
            f"-plugin:{x_edit_plugin.name}",
            "-nobuildrefs",
            "-autoload",
            "-autoexit",
            "-IKnowWhatImDoing"
        ]

        working_directory = self.x_edit_converter_path

        if self.x_edit_data_path.exists():
            shutil.rmtree(self.x_edit_data_path)

        self.x_edit_data_path.mkdir(exist_ok=True)

        self.run_long_task(command, cwd=working_directory)

        self.output_received.emit("Extract plugin data... [DONE]\n")

    def import_plugin_data(self):
        self.output_received.emit("Import plugin data...\n")

        if not self.plugins:
            self.output_received.emit("No plugins to import\n")

            return

        x_edit_mode = "-FO4"

        command = [
            self.x_edit_exe_path,
            x_edit_mode,
            "-script:Import",
            f"-plugin:Fallout4.esm",
            "-nobuildrefs",
            "-autoload",
            "-autoexit",
            "-IKnowWhatImDoing"
        ]

        working_directory = self.x_edit_converter_path

        self.run_long_task(command, cwd=working_directory)

        self.output_received.emit("Import plugin data... [DONE]\n")

    def move_plugins_to_output(self):
        for plugin in self.plugins:
            shutil.move(
                src=str(self.fo4_path / "Data" / plugin.name),
                dst=str(self.output_path / plugin.name),
            )

            self.output_received.emit(f"Moved {plugin.name} to output path\n")

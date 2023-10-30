from dataclasses import dataclass


@dataclass
class InstallerParams:
    skip_bsas: bool = False
    skip_meshes: bool = False
    skip_optimize: bool = False
    skip_data: bool = False
    skip_plugin_extract: bool = False
    skip_plugin_import: bool = False
    skip_plugin_move: bool = False
    ignore_existing_files: bool = False
    debug: bool = False
    skip_lod_settings: bool = False

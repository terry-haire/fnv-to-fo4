fn getFilesRecursive root pattern =
(
dir_array = GetDirectories (root+"/*")
for d in dir_array do
  join dir_array (GetDirectories (d+"/*"))
my_files = #()
for f in dir_array do
  join my_files (getFiles (f + pattern))
my_files
)
--get all .ms files from the folder meshes --and all its subfolders:
list = getFilesRecursive "D:\\Games\Fallout New Vegas\FNVExtracted\Data\meshes\architecture" "*.nif"
for i = 1 to list.count do print list[i]
print list.count
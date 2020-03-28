# CBZator
A very simple bash script to convert folders of images into a single `cbz` archive.

## Dependencies

The script needs `detox` installed.

## Usage

`./cbzator.sh [-h] [--merge <input_cbz> <folder_to_add>] [<input_directory> <output_directory>]`

### Creation mode

To generate a `cbz` archive from images in input directory: `./cbzator.sh in_dir out_dir`.

- `in_dir` must be a folder containing `.jpg` files OR a folder of folders containing `.jpg` files. To use with `.png` just edit the script.
Note that `sort -V` is used to determine image/folder ordering.
- `out_dir` is the path where the script will place the resulting archive (called `my_archive.cbz`). It will also create a temporary directory `temp` which will be removed when finished. If it already exists the script will overwrite its content.

Note that, as a side effect, filenames in `in_dir` may be changed by detox.

### Append mode

You can also add images to a previously generated archive by specifying option `-m` or `--merge`. Images will be appended to the previous one. The new images are sorted with `sort -V` and the output file will be placed in the same folder as the file given in input, with name `my_archive.cbz`. If the file already exists it is replaced.

Example: `./cbzator.sh -m path_to_file.cbz new_images_dir`. 

Folder `new_images_dir` must have the same format as `in_dir` described above.


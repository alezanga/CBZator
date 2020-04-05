# CBZator
A very simple bash script to convert folders of images into a single `cbz` archive.

## Dependencies

Only `zip` and `unzip` packages (and `coreutils`).

## Usage

`./cbzator.sh [-h] [--merge <input_cbz> <folder_to_add>] [<input_directory> <output_directory>]`

### Creation mode

To generate a `cbz` archive from images in input directory: `./cbzator.sh in_dir out_dir`.

- `in_dir` must be a folder containing `.jpg` files OR a folder of folders containing `.jpg` files. It won't work as expected if the folder contains a mixture of folders and images. 
  To use with `.png` just edit the script.
  Note that `sort -V` is used to determine image/folder ordering.
- `out_dir` is the path where the script will place the resulting archive, called `my_archive.cbz`. If this file already exists it will ask for confirmation before deleting it. The script will also create a temporary directory `temp` which will be removed when finished. If the folder already exists the script will overwrite its content.

### Append mode

You can also add images to a previously generated archive by specifying option `-m` or `--merge`. Images will be appended to the previous one. The new images are sorted with `sort -V` and the output file with name `my_archive.cbz` will be placed in the same folder as the file given in input. If the file already exists it is replaced.

Example: `./cbzator.sh -m path_to_file.cbz new_images_dir`. 

Folder `new_images_dir` must have the same format as `in_dir` described above.

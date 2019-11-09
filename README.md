# CBZator
A bash script to convert folders of images into a single cbz archive.

## Dependences

The script needs `detox` installed.

## Usage

`./cbzator.sh [-h] <input_directory> <output_directory>`

To generate a cbz archive from images in input directory: `./cbzator.sh in_dir out_dir`.

- `in_dir` must be a folder containing `.jpg` files OR a folder of folders containing `.jpg` files. To use with `.png` just edit the script. Also avoid to use name with blank spaces.
Note that `sort -V` is used to determine image/folder ordering.

- `out_dir` is the path where the script will place the resulting archive (called `my_archive.cbz`). It will also create a temorary directory `temp` which will be removed when finished. If it already exists the script will overwrite its content.
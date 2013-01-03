tagger.rb
============

Fill out music files ID3 tags based on file names, directory name or given information.

This is nothing new and I'm sure there are lots of softwares like this, but I created it to help me organize my music collection quickly and I like it.

## Usage

It's a Ruby script, so you should have it installed to use it. Running any newer version of Ruby (1.8 or 1.9) should be fine.

Run the script with no parameters to get an explanation of how to use it.

## Examples

Take a real example from some files I had in my disk. The directory is called "(2006) Ziltoid The Omniscient" and has the songs for the aforementioned album by the artist Devin Townsend. The files are:

	01 ZTO(1).mp3
	02 By Your Command(1).mp3
	03 Ziltoid Attaxx!!(1).mp3
	04 Solar Winds(1).mp3
	05 Hyperdrive(1).mp3
	06 N9(1).mp3
	07 Planet Smasher(1).mp3
	08 Omnidimensional Creator(1).mp3
	09 Color Your World(1).mp3
	10 The Greys(1).mp3
	11 Tall Latte.mp3

Let's say all these MP3s have no ID3 tags. How can you set them with this script? Assuming `tagger.rb` is somewhere in your path:

    $ cd "(2006) Ziltoid The Omniscient"
    $ tagger.rb . -f "%T %t(1)" -d "(%y) %A"

You see the pattern on the file names? They have the track number, followed by the title of the song followed by a "(1)" (which is not important and I want to ignore). So the file pattern "%T %t(1)" captures the "%T" (track number) and the "%t" (song title). Also we have a directory pattern "(%y) %A" that sets the year with "%y" and album name with "%A".

Since I know that the artist name is "Devin Townsend" I can set it for all the files inconditionally. The final command looks like this:

    $ tagger.rb . -f "%T %t(1)" -d "(%y) %A" -i "%a:Devin Townsend"

The commands it will run for the files are:

    id3v2 "01 ZTO(1).mp3" -T "01" -t "ZTO" -y "2006" -A "Ziltoid The Omniscient" -a "Devin Townsend"
    id3v2 "02 By Your Command(1).mp3" -T "02" -t "By Your Command" -y "2006" -A "Ziltoid The Omniscient" -a "Devin Townsend"
    ...

Use the `-s` option to print the resulting command if you want to be sure your pattern is extracting the correct data. You can read more about the patterns in the script help option.
## What

* tipitaka from offline worldtipitaka.org (http://archive.is/Ugwv)
* categorized raw html pages
* all in one file, marshalled by ruby (1.9.3)

## Why

* to remove all garbage
* to get pure xml or even db

## Progress

- [x] just categorized html files
- [ ] remove garbage?
- [ ] extract schema?
- [ ] be sure that no data is lost?
- [ ] output data file and ruby interface to it

## Usage

* `git clone git://github.com/sowcow/canon.git; cd canon`
* `gunzip canon.gz -c > canon`
* read/run canon.rb

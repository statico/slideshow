#!/usr/bin/env coffee

fs = require 'fs'
path = require 'path'

basedir = process.argv[2]
if not basedir
    console.error "usage: #{ process.argv[1] } <dir>"
    process.exit 1

j = (filename) -> path.join basedir, filename

filenames = fs.readdirSync basedir
if /back-in-the-day/.test basedir
    filenames.sort()
else
    filenames.sort (a, b) ->
        at = fs.statSync(j a).mtime.getTime()
        bt = fs.statSync(j b).mtime.getTime()
        return bt - at

obj =
    paths: []
    nonImages: []

for filename in filenames
    continue if /^\./.test filename
    continue if filename in ['index.html', 'images.json']
    if /\.(jpe?g|gif|png|webm)$/.test filename
        obj.paths.push filename
    else
        stat = fs.statSync j filename
        suffix = if stat.isDirectory() then '/' else ''
        obj.nonImages.push filename + suffix

content = JSON.stringify obj, null, '  '
fs.writeFileSync j('images.json'), content

# Send to Maya Vim Plug-in

Bridge Vim editor with Autodesk Maya.  
+ Autodesk Maya 2023 supported.

## Install

+ Vundle (http://github.com.gmarik/vundle)
    - `Plugin "chiaxin/send2maya.vim"`

## Setting

## Call Function

`:call send2maya#send("all")`

## Set Key-map

For example, I want to key "leader" than "m" launch transfer all in normal mode.  
Launch transfer selected in virtual mode.

`nnoremap <leader>m send2maya#send("all")<CR>`  
`vnoremap <leader>m <ESC>send2maya#send("selected")<CR>`

## License

[MIT License](http://en.wikipedia.org/wiki/MIT_License)

# Send to Maya Vim Plug-in

Bridge Vim editor with Autodesk Maya.  
+ Autodesk Maya 2023 supported.

## Install

+ Vundle (http://github.com.gmarik/vundle)
    - `Plugin "chiaxin/send2maya.vim"`

## Setting

- Vim (In .vimrc)
    + Specific command port
        * `let g:send_2_maya_python_port=7001`
        * `let g:send_2_maya_mel_port=7002`
        * If not set, Python port is 7001, Mel port is 7002 by default.

### Maya Command Port

- Python
    + `import maya.cmds as mc`
    + `mc.commandPort(n=":7001", stp="python")`
    + `mc.commandPort(n=":7002", stp="mel")`

- MEL
    + `commandPort -n ":7001" -stp "python";`
    + `commandPort -n ":7002" -stp "mel";`

## Call Function

`:call send2maya#send("all")`

## Set Key-map

For example, I want to key "leader" than "m" launch transfer all in normal mode.  
Launch transfer selected in virtual mode.

`nnoremap <leader>m send2maya#send("all")<CR>`  
`vnoremap <leader>m <ESC>send2maya#send("selected")<CR>`

## License

[MIT License](http://en.wikipedia.org/wiki/MIT_License)

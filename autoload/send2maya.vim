"
" send2maya.vim
"
" Author : Chia Xin Lin (nnnight@gmail.com)
"

let g:send_2_maya_python_port=7001
let g:send_2_maya_mel_port=7002

function! s:get_visual_selection()
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - 2]
    let lines[0]  = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction

function! send2Maya#send(mode)

python3 << EOF
import vim
import socket
import tempfile
import os
import os.path
import re

class MayaBridge():
    ExtensionPortMap = { 'py': 7001, 'mel': 7002 }
    def __init__(self):
        self.commands = ""
        self.language = vim.eval("expand('%:e')")
        mode = vim.eval('a:mode')
        if mode == 'selected':
            self.commands = vim.eval('s:get_visual_selection()')
        elif mode == 'all':
            full_path = vim.eval("expand('%:p')")
            with open(full_path, 'r', encoding='utf-8') as FileHandle:
                self.commands = "".join(FileHandle.readlines())
        else:
            print("Unknown mode : " + mode)
        _, self.temp_file = tempfile.mkstemp(prefix='send2maya')

    @classmethod
    def port_update(cls):
        '''
            Update command port from plug-in global variable.
        '''
        py_port = vim.eval('g:send_2_maya_python_port')
        mel_port= vim.eval('g:send_2_maya_mel_port')
        cls.ExtensionPortMap['py'] = int(py_port)
        cls.ExtensionPortMap['mel']= int(mel_port)
        print('[send2maya] Port : {} (Python), {} (MEL).'.format(py_port, mel_port))

    def _wrapper(self) -> str:
        '''
            Get for transfer socket command.
        [::args::]
            None
        [::return::]
            The socket command : str
        '''
        command = ""
        with open(self.temp_file, 'w', encoding='utf-8') as FileHandle:
            FileHandle.write(self.commands)
        if self.language == 'py':
            command = 'import __main__\n'
            command +='with open("{0}", "r") as FH:\n'.format(
                self.temp_file.replace("\\", "/")
            )
            command += '    exec("".join(FH.readlines()), {0}, {0})'.format(
                '__main__.__dict__'
            )
        elif self.language == 'mel':
            command = 'source "{0}";'.format(self.temp_file)
        else:
            print("[send2maya] Unknown file extension : " + self.language)
        command = command.replace("\\", "/")
        return command

    def _clean_up(self):
        if os.path.isfile(self.temp_file):
            os.remove(self.temp_file)
            self.temp_file = None
            vim.eval('echo "Clean : {}"'.format(self.temp_file))

    def _send_to_maya(self):
        if not self.commands:
            return
        if self.language not in MayaBridge.ExtensionPortMap.keys():
            print("[send2maya] Send to Maya file must is *.py or *.mel!")
            return
        command = self._wrapper()
        if not command:
            return
        # === Run Socket Transfer ===
        try:
            Host = '127.0.0.1'
            Port = MayaBridge.ExtensionPortMap[self.language]
            Addr = (Host, Port)
            socket_inst = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            socket_inst.connect(Addr)
            socket_inst.send(command.encode())
            message = socket_inst.recv(4096)
            print("[send2maya] Receive: {0}".format(message.decode()))
        except Exception:
            import traceback
            traceback.print_exc()
            print("[send2maya] Failed send to maya.")
        else:
            print("[send2maya] Send to Maya successful.")
        finally:
            socket_inst.close()

    def run(self):
        MayaBridge.port_update()
        self._send_to_maya()

if __name__ == '__main__':
    bridge = MayaBridge()
    bridge.run()
EOF
endfunction

# This file is a minimal pyformat vim-integration. To install:
# - Change 'binary' if clang-format is not on the path (see below).
# - Add to your .vimrc:
#
# :function FormatPY()
# :  let l:lines="all"
# :  pyf <path-to-this-file>/pyformat.py
# :endfunction
# noremap <C-P> :pyf :call FormatPY()<CR>
# inoremap <C-P> <C-O> :pyf :call FormatPY()<CR>
#
# It operates on the current, potentially unsaved buffer. To revert a
# formatting, just undo.
from __future__ import print_function

import difflib
import subprocess
import sys
import vim
import os

# Change this to the full path if pyformat is not on the path.
binary = 'pyformat'
binary_options = '--in-place'

binary = 'autopep8'
binary_options = '--in-place --aggressive --aggressive --max-line-length 80'

binary = 'yapf'
binary_options = "--in-place --style google"

tempfile = '/tmp/pyformat'


def main():
    # Save the current text to a temp file.
    text = '\n'.join(vim.current.buffer)
    with open(tempfile, 'w') as file_:
        file_.write(text)

    # Avoid flashing an ugly cmd prompt on Windows.
    startupinfo = None
    if sys.platform.startswith('win32'):
        startupinfo = subprocess.STARTUPINFO()
        startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        startupinfo.wShowWindow = subprocess.SW_HIDE

    # Call formatter and get output.
    os.system('{} {} {}'.format(binary, binary_options, tempfile))
    with open(tempfile, 'r') as file_:
        lines = file_.read().splitlines()

    # Update buffer with new lines.
    sequence = difflib.SequenceMatcher(None, vim.current.buffer, lines)
    for op in reversed(sequence.get_opcodes()):
        if op[0] is not 'equal':
            vim.current.buffer[op[1]:op[2]] = lines[op[3]:op[4]]

    # cleanup
    os.remove(tempfile)

main()


" Custom syntax highlighting
syn match cppIfndef "^#ifndef [A-Z_]\+$"
hi link cppIfndef               Ignore

syn match cppDefine "^#define [A-Z_]\+$"
hi link cppDefine               Ignore

syn match cppEndif "^#endif .\+$"
hi link cppEndif                Ignore

syn match cppNamespace "^\s*namespace\s\+[A-Za-z0-9_]*"
hi link cppNamespace            Question

syn match DefinedType "\v\w@<!(\u|_+[A-Z0-9])[A-Z0-9_]*\w@!"
hi link DefinedType             Operator

syn match cppPointer "[a-zA-Z0-9_<>]*\*[a-zA-Z0-9_]* *[a-zA-Z0-9_]*"
hi link cppPointer              cppPointer

syn match cppPassPointer "&[a-zA-Z0-9_]\+"
hi link cppPassPointer          cppPointer

syn match cppPassedRef "\v>\&"
hi link cppPassedRef            Operator

syn match cppObjectPointer "\v>\.*\-*\>*<"
hi link cppObjectPointer       Operator

syn match NameSpace ":*\w\+\w*::"
hi link NameSpace               Delimiter

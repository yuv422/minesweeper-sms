" Vim syntax file
" Language:	GNU Assembler
" Maintainer:	Erik Wognsen <erik.wognsen@gmail.com>
"		Previous maintainer:
"		Kevin Dahlhausen <kdahlhaus@yahoo.com>
" Last Change:	2010 Apr 18

" Thanks to Ori Avtalion for feedback on the comment markers!

" For version 5.x: Clear all syntax items
" For version 6.0 and later: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn case ignore

" storage types

syn match asmLabel		"[a-z_][a-z0-9_]*:"he=e-1
syn match asmIdentifier		"[a-z_][a-z0-9_]*"

syn match decNumber		"0\+[1-7]\=[\t\n$,; ]"
syn match decNumber		"[1-9]\d*"
syn match octNumber		"0[0-7][0-7]\+"
syn match hexNumber		"\$[0-9a-fA-F]\+"
syn match binNumber		"%[0-1]*"

syn keyword asmTodo		contained TODO

syn region asmComment		start="/\*" end="\*/" contains=asmTodo
syn match asmComment		";.*" contains=asmTodo

syn match asmInclude		"\.include"
syn match asmCond		"\.if"
syn match asmCond		"\.else"
syn match asmCond		"\.endif"
syn match asmMacro		"\.macro"
syn match asmMacro		"\.endm"

syn match asmDirective		"\.[a-z][a-z]\+"


syn keyword asmKeywords1		adc add and bit call ccf cp cpd cpdr cpi cpir cpl daa dec di djnz ei ex exx halt im in inc ind indr ini inir jp jr ld ldd lddr ldi ldir neg nop or otdr otir out outd outi pop push res ret reti retn rl rla rlc rlca rld rr rra rrc rrca rrd rst sbc scf set sla sra srl sub xor  


syn keyword asmKeywords2		a f b c d e h l af bc de hl ix iy i r "af\'" 
syn keyword asmKeywords2		sp pc syn 

syn keyword asmKeyWords3 z nz nc po pe p m


syn keyword asmKeyWords5 align args asc bank banks banksize bankstotal data db defaultslot desc ds dsb dsw dw export force free fsize instanceof map nargs overwrite read returnorg semifree size skip slot slotsize start superfree swap to



syn case match

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_asm_syntax_inits")
  if version < 508
    let did_asm_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  " The default methods for highlighting.  Can be overridden later
  HiLink asmSection	Special
  HiLink asmLabel	Label
  HiLink asmComment	Comment
  HiLink asmTodo	Todo
  HiLink asmDirective	Type

  HiLink asmInclude	Include
  HiLink asmCond	PreCondit
  HiLink asmMacro	Macro

  HiLink hexNumber	Number
  HiLink decNumber	Number
  HiLink octNumber	Number
  HiLink binNumber	Number

  HiLink asmIdentifier Identifier
  HiLink asmType	Type

  HiLink asmKeyWords1	Statement
  HiLink asmKeyWords2	Macro
  HiLink asmKeyWords3	Statement
  HiLink asmKeyWords5	Statement

  delcommand HiLink
endif

let b:current_syntax = "z80asm"

" vim: ts=8

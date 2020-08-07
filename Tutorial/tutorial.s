		AREA mycode, CODE, READONLY
		EXPORT __main
		ALIGN
		ENTRY
__main	PROC
		movw	r6, #0xC038
		movt	r6, #0x2009
		movw	r4, #0xC020
		movt	r4, #0x2009
		movw	r5, #0x0000
		movt	r5, #0xb000
		str		r5, [r4]
		movt	r5, #0x1000
		str		r5, [r6]
here	b		here
		ENDP
		END

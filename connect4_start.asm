;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	description: 	Connect 4 game!				;
;								;
; 								;
;	file:		connect4_start.asm			;
;	This is the starter code for the Connect4 game		;
;								;
;	author:		Birgi Tamersoy/Nina Telang		;
;	date:		04/09/2013				;
;		update:	04/10/2013 -> finished & tested.	;
;		update: 04/12/2013 -> re-arranged for students.	;
;				   -> added 2nd dia. check.	;
;								;	
;		update: 11/05/15				;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.ORIG x3000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Main Program						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	JSR INIT
ROUND
	JSR DISPLAY_BOARD
	JSR GET_MOVE
	JSR UPDATE_BOARD
	JSR UPDATE_STATE

	ADD R6, R6, #0
	BRz ROUND

	JSR DISPLAY_BOARD
	JSR GAME_OVER

	HALT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Functions & Constants!!!				;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	DISPLAY_TURN						;
;	description:	Displays the appropriate prompt.	;
;	inputs:		None!					;
;	outputs:	None!					;
;	assumptions:	TURN is set appropriately!		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DISPLAY_TURN
	ST R0, DT_R0
	ST R7, DT_R7

	LD R0, TURN
	ADD R0, R0, #-1
	BRp DT_P2
	LEA R0, DT_P1_PROMPT
	PUTS
	BRnzp DT_DONE
DT_P2
	LEA R0, DT_P2_PROMPT
	PUTS

DT_DONE

	LD R0, DT_R0
	LD R7, DT_R7

	RET
DT_P1_PROMPT	.stringz 	"Player 1, choose a column: "
DT_P2_PROMPT	.stringz	"Player 2, choose a column: "
DT_R0		.blkw	1
DT_R7		.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	GET_MOVE						;
;	description:	gets a column from the user.		;
;			also checks whether the move is valid,	;
;			or not, by calling the CHECK_VALID 	;
;			subroutine!				;
;	inputs:		None!					;
;	outputs:	R6 has the user entered column number!	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GET_MOVE
	ST R0, GM_R0
	ST R7, GM_R7

GM_REPEAT
	JSR DISPLAY_TURN
	GETC
	OUT
	JSR CHECK_VALID
	LD R0, ASCII_NEWLINE
	OUT

	ADD R6, R6, #0
	BRp GM_VALID

	LEA R0, GM_INVALID_PROMPT
	PUTS
	LD R0, ASCII_NEWLINE
	OUT
	BRnzp GM_REPEAT

GM_VALID

	LD R0, GM_R0
	LD R7, GM_R7

	RET
GM_INVALID_PROMPT 	.stringz "Invalid move. Try again."
GM_R0			.blkw	1
GM_R7			.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	UPDATE_BOARD						;
;	description:	updates the game board with the last 	;
;			move!					;
;	inputs:		R6 has the column for last move.	;
;	outputs:	R5 has the row for last move.		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UPDATE_BOARD
	ST R1, UP_R1
	ST R2, UP_R2
	ST R3, UP_R3
	ST R4, UP_R4
	ST R6, UP_R6
	ST R7, UP_R7

	; clear R5
	AND R5, R5, #0
	ADD R5, R5, #6

	LEA R4, ROW6
	
UB_NEXT_LEVEL
	ADD R3, R4, R6

	LDR R1, R3, #-1
	LD R2, ASCII_NEGHYP

	ADD R1, R1, R2
	BRz UB_LEVEL_FOUND

	ADD R4, R4, #-7
	ADD R5, R5, #-1
	BRnzp UB_NEXT_LEVEL

UB_LEVEL_FOUND
	LD R4, TURN
	ADD R4, R4, #-1
	BRp UB_P2

	LD R4, ASCII_O
	STR R4, R3, #-1

	BRnzp UB_DONE
UB_P2
	LD R4, ASCII_X
	STR R4, R3, #-1

UB_DONE		

	LD R1, UP_R1
	LD R2, UP_R2
	LD R3, UP_R3
	LD R4, UP_R4
	LD R6, UP_R6
	LD R7, UP_R7

	RET
ASCII_X	.fill	x0058
ASCII_O	.fill	x004f
UP_R1	.blkw	1
UP_R2	.blkw	1
UP_R3	.blkw	1
UP_R4	.blkw	1
UP_R5	.blkw	1
UP_R6	.blkw	1
UP_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHANGE_TURN						;
;	description:	changes the turn by updating TURN!	;
;	inputs:		none!					;
;	outputs:	none!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHANGE_TURN
	ST R0, CT_R0
	ST R1, CT_R1
	ST R7, CT_R7

	LD R0, TURN
	ADD R1, R0, #-1
	BRz CT_TURN_P2

	ST R1, TURN
	BRnzp CT_DONE

CT_TURN_P2
	ADD R0, R0, #1
	ST R0, TURN

CT_DONE
	LD R0, CT_R0
	LD R1, CT_R1
	LD R7, CT_R7

	RET
CT_R0	.blkw	1
CT_R1	.blkw	1
CT_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_WINNER						;
;	description:	checks if the last move resulted in a	;
;			win or not!				;
;	inputs:		R6 has the column of last move.		;
;			R5 has the row of last move.		;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_WINNER
	ST R5, CW_R5
	ST R6, CW_R6
	ST R7, CW_R7

	AND R4, R4, #0
	
	JSR CHECK_HORIZONTAL
	ADD R4, R4, #0
	BRp CW_DONE

	JSR CHECK_VERTICAL
	ADD R4, R4, #0
	BRp CW_DONE

	JSR CHECK_DIAGONALS

CW_DONE

	LD R5, CW_R5
	LD R6, CW_R6
	LD R7, CW_R7

	RET
CW_R5	.blkw	1
CW_R6	.blkw	1
CW_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	UPDATE_STATE						;
;	description:	updates the state of the game by 	;
;			checking the board. i.e. tries to figure;
;			out whether the last move ended the game;
; 			or not! if not updates the TURN! also	;
;			updates the WINNER if there is a winner!;
;	inputs:		R6 has the column of last move.		;
;			R5 has the row of last move.		;
;	outputs:	R6 has  1, if the game is over,		;
;				0, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UPDATE_STATE
	ST R0, US_R0
	ST R1, US_R1
	ST R4, US_R4
	ST R7, US_R7
	
	; checking if the last move resulted in a win or not!
	JSR CHECK_WINNER
	
	ADD R4, R4, #0
	BRp US_OVER
	
	; checking if the board is full or not!
	AND R6, R6, #0
		
	LD R0, NBR_FILLED
	ADD R0, R0, #1
	ST R0, NBR_FILLED

	LD R1, MAX_FILLED
	ADD R1, R0, R1
	BRz US_TIE

US_NOT_OVER
	JSR CHANGE_TURN
	BRnzp US_DONE

US_OVER
	ADD R6, R6, #1
	LD R0, TURN
	ST R0, WINNER
	BRnzp US_DONE

US_TIE
	ADD R6, R6, #1

US_DONE
	LD R0, US_R0
	LD R1, US_R1
	LD R4, US_R4
	LD R7, US_R7

	RET
NBR_FILLED	.fill	#0
MAX_FILLED	.fill	#-36
US_R0		.blkw	1
US_R1		.blkw	1
US_R4		.blkw	1
US_R7		.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	INIT							;
;	description:	simply sets the BOARD_PTR appropriately!;
;	inputs:		none!					;
;	outputs:	none!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INIT
	ST R0, I_R0
	ST R7, I_R7

	LEA R0, ROW1
	ST R0, BOARD_PTR

	LD R0, I_R0
	LD R7, I_R7

	RET
I_R0	.blkw	1
I_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Global Constants!!!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ASCII_SPACE	.fill		x0020				;
ASCII_NEWLINE	.fill		x000A				;
TURN		.fill		1				;
WINNER		.fill		0				;
								;
ASCII_OFFSET	.fill		x-0030				;
ASCII_NEGONE	.fill		x-0031				;
ASCII_NEGSIX	.fill		x-0036				;
ASCII_NEGHYP	.fill	 	x-002d				;
								;
ROW1		.stringz	"------"			;
ROW2		.stringz	"------"			;
ROW3		.stringz	"------"			;
ROW4		.stringz	"------"			;
ROW5		.stringz	"------"			;
ROW6		.stringz	"------"			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;DO;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;NOT;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;CHANGE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;ANYTHING;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;ABOVE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;THIS!!!;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	DISPLAY_BOARD						;
;	description:	Displays the board.			;
;	inputs:		None!					;
;	outputs:	None!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DISPLAY_BOARD
	ST R0, DB_R0
	ST R7, DB_R7
Disp_R1
	LEA	R1, ROW1
L1	LDR	R0,R1,#0
	OUT
	ADD	R0,R0,#0
	BRz	Disp_R2
	LD	R0,ASCII_SPACE 
	OUT
	ADD	R1,R1,#1
	BRnzp	L1

Disp_R2	LD	R0,ASCII_NEWLINE
	OUT
	LEA	R1, ROW2
L2	LDR	R0,R1,#0
	OUT
	ADD	R0,R0,#0
	BRz	Disp_R3
	LD	R0,ASCII_SPACE 
	OUT
	ADD	R1,R1,#1
	BRnzp	L2

Disp_R3 LD	R0,ASCII_NEWLINE
	OUT
	LEA	R1, ROW3
L3	LDR	R0,R1,#0
	OUT
	ADD	R0,R0,#0
	BRz	Disp_R4
	LD	R0,ASCII_SPACE 
	OUT
	ADD	R1,R1,#1
	BRnzp	L3
	
Disp_R4	LD	R0,ASCII_NEWLINE
	OUT
	LEA	R1, ROW4
L4	LDR	R0,R1,#0
	OUT
	ADD	R0,R0,#0
	BRz	Disp_R5
	LD	R0,ASCII_SPACE 
	OUT
	ADD	R1,R1,#1
	BRnzp	L4

Disp_R5	LD	R0,ASCII_NEWLINE
	OUT
	LEA	R1, ROW5
L5	LDR	R0,R1,#0
	OUT
	ADD	R0,R0,#0
	BRz	Disp_R6
	LD	R0,ASCII_SPACE 
	OUT
	ADD	R1,R1,#1
	BRnzp	L5

Disp_R6	LD	R0,ASCII_NEWLINE
	OUT
	LEA	R1, ROW6
L6	LDR	R0,R1,#0
	OUT
	ADD	R0,R0,#0
	BRz	EndDisp
	LD	R0,ASCII_SPACE 
	OUT
	ADD	R1,R1,#1
	BRnzp	L6

EndDisp	LD	R0,ASCII_NEWLINE
	OUT
	LD R0, DB_R0
	LD R7, DB_R7

	RET
DB_R0	.blkw	1
DB_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	GAME_OVER						;
;	description:	checks WINNER and outputs the proper	;
;			message!				;
;	inputs:		none!					;
;	outputs:	none!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GAME_OVER
	ST	R7,GO_R7
	LD	R1,WINNER
	ADD	R1,R1,#-1
	BRz	GAMEOVER2
	BRn	GAMEOVER3

GAMEOVER1
	LEA	R0,P2WINS
	PUTS
	BRnzp	GAMEOVER

GAMEOVER2
	LEA	R0,P1WINS
	PUTS
	BRnzp	GAMEOVER

GAMEOVER3
	LEA	R0,TIE
	PUTS

GAMEOVER
	LD	R7,GO_R7
	RET
GO_R7	.blkw	1
P1WINS	.stringz	"Player 1 Wins."
P2WINS	.stringz	"Player 2 Wins."
TIE	.stringz	"There is a tie."
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_VALID						;
;	description:	checks whether a move is valid or not!	;
;	inputs:		R0 has the ASCII value of the move!	;
;	outputs:	R6 has:	0, if invalid move,		;
;				decimal col. val., if valid.    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_VALID
	ST	R0,CV_R0
	ST	R1,CV_R1
	ST	R2,CV_R2
	ST	R3,CV_R3
	ST	R7,CV_R7
	
	LD	R1,ASCII_NEGONE		;check if number is between 1 and 6
	LD	R2,ASCII_NEGSIX
	ADD	R1,R0,R1
	BRn	Not_Valid
	ADD	R2,R0,R2
	BRp	Not_Valid
	
	LEA	R1,ROW1			;check if column is filled
	LD	R3,ASCII_OFFSET
	ADD	R3,R0,R3
	ADD	R1,R1,R3
	ADD	R1,R1,#-1
	LDR	R2,R1,#0
	LD	R3,ASCII_NEGHYP
	ADD	R2,R2,R3
	BRnp	Not_Valid

Valid
	LD	R3,ASCII_OFFSET
	ADD	R6,R0,R3
	BRnzp	End_Check


Not_Valid	
	AND	R6,R6,0
	BRnzp	End_Check

End_Check
	LD	R0,CV_R0
	LD	R1,CV_R1
	LD	R2,CV_R2
	LD	R3,CV_R3
	LD	R7,CV_R7

	RET
CV_R0	.blkw	1
CV_R1	.blkw	1
CV_R2	.blkw	1
CV_R3	.blkw	1
CV_R7	.blkw	1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;USE THE FOLLOWING TO ACCESS THE BOARD!!!;;;;;;;;;;;;;;;;;;
;;;;;IT POINTS TO THE FIRST ELEMENT OF ROW1 (TOP-MOST ROW)!!!;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BOARD_PTR	.blkw	1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_HORIZONTAL					;
;	description:	horizontal check.			;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_HORIZONTAL
	ST	R0,CH_R0
	ST	R1,CH_R1
	ST	R2,CH_R2
	ST	R3,CH_R3
	ST	R5,CH_R5
	ST	R6,CH_R6
	ST	R7,CH_R7

	AND	R1,R1,#0
	ADD	R1,R1,#-3
	LD	R2,BOARD_PTR
	ADD	R5,R5,#-1
Get_Row	BRz	L7
	ADD	R2,R2,#7
	ADD	R5,R5,#-1
	BRnzp	Get_Row

L7	ADD	R2,R2,R6
	ADD	R2,R2,#-1
	LDR	R3,R2,#0
	NOT	R3,R3		
	ADD	R3,R3,#1

	ADD	R7,R2,#0	;checks tokens to right of last move
L8	LDR	R4,R7,#1
	ADD	R4,R4,R3
	BRnp	A1
	ADD	R7,R7,#1
	ADD	R1,R1,#1
	BRz	Horiz_Win
	BRnzp	L8
A1
	ADD	R7,R2,#0	;checks tokens to left of last move
L9	LDR	R4,R7,#-1
	ADD	R4,R4,R3
	BRnp	Horiz_NoWin
	ADD	R7,R7,#-1
	ADD	R1,R1,#1
	BRz	Horiz_Win
	BRnzp	L9


Horiz_NoWin
	AND	R4,R4,#0
	BRnzp	Done_CheckHoriz

Horiz_Win
	AND	R4,R4,#0
	ADD	R4,R4,#1	

Done_CheckHoriz
	LD	R0,CH_R0
	LD	R1,CH_R1
	LD	R2,CH_R2
	LD	R3,CH_R3
	LD	R5,CH_R5
	LD	R6,CH_R6
	LD	R7,CH_R7
	RET
CH_R0	.blkw	1
CH_R1	.blkw	1
CH_R2	.blkw	1
CH_R3	.blkw	1
CH_R5	.blkw	1
CH_R6	.blkw	1
CH_R7	.blkw	1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_VERTICAL						;
;	description:	vertical check.				;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_VERTICAL
	ST	R0,CV1_R0
	ST	R1,CV1_R1
	ST	R2,CV1_R2
	ST	R3,CV1_R3
	ST	R5,CV1_R5
	ST	R6,CV1_R6
	ST	R7,CV1_R7

	AND	R1,R1,#0
	ADD	R1,R1,#-3
	LD	R2,BOARD_PTR
	ADD	R5,R5,#-1
Get_Row1
	BRz	L10
	ADD	R2,R2,#7
	ADD	R5,R5,#-1
	BRnzp	Get_Row1

L10	ADD	R2,R2,R6
	ADD	R2,R2,#-1
	LDR	R3,R2,#0
	NOT	R3,R3		
	ADD	R3,R3,#1
;	
	ADD	R7,R2,#0	;checks tokens below last move
L11	LDR	R4,R7,#7
	ADD	R4,R4,R3
	BRnp	A2
	ADD	R7,R7,#7
	ADD	R1,R1,#1
	BRz	Vert_Win
	BRnzp	L11
A2
	ADD	R7,R2,#0	;checks tokens above last move
L12	LDR	R4,R7,#-7
	ADD	R4,R4,R3
	BRnp	Vert_NoWin
	ADD	R7,R7,#-7
	ADD	R1,R1,#1
	BRz	Vert_Win
	BRnzp	L12
Vert_NoWin
	AND	R4,R4,#0
	BRnzp	Done_CheckVert

Vert_Win
	AND	R4,R4,#0
	ADD	R4,R4,#1	

Done_CheckVert
	LD	R0,CV1_R0
	LD	R1,CV1_R1
	LD	R2,CV1_R2
	LD	R3,CV1_R3
	LD	R5,CV1_R5
	LD	R6,CV1_R6
	LD	R7,CV1_R7
	RET
CV1_R0	.blkw	1
CV1_R1	.blkw	1
CV1_R2	.blkw	1
CV1_R3	.blkw	1
CV1_R5	.blkw	1
CV1_R6	.blkw	1
CV1_R7	.blkw	1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_DIAGONALS						;
;	description:	checks diagonals by calling 		;
;			CHECK_D1 & CHECK_D2.			;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_DIAGONALS
	ST	R0,CD_R0
	ST	R1,CD_R1
	ST	R2,CD_R2
	ST	R3,CD_R3
	ST	R5,CD_R5
	ST	R6,CD_R6
	ST	R7,CD_R7

	AND	R1,R1,#0
	ADD	R1,R1,#-3
	LD	R2,BOARD_PTR
	ADD	R5,R5,#-1
Get_Row2
	BRz	L13
	ADD	R2,R2,#7
	ADD	R5,R5,#-1
	BRnzp	Get_Row2

L13	ADD	R2,R2,R6
	ADD	R2,R2,#-1
	LDR	R3,R2,#0
	NOT	R3,R3		
	ADD	R3,R3,#1
	
	JSR	CHECK_D1
	ADD	R4,R4,#0
	BRp	Done_CheckDiag
	JSR	CHECK_D2

Done_CheckDiag
	LD	R0,CD_R0
	LD	R1,CD_R1
	LD	R2,CD_R2
	LD	R3,CD_R3
	LD	R5,CD_R5
	LD	R6,CD_R6
	LD	R7,CD_R7
	RET
CD_R0	.blkw	1
CD_R1	.blkw	1
CD_R2	.blkw	1
CD_R3	.blkw	1
CD_R5	.blkw	1
CD_R6	.blkw	1
CD_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_D1						;
;	description:	1st diagonal check.			;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_D1	
	ST	R0,CD1_R0
	ST	R1,CD1_R1
	ST	R2,CD1_R2
	ST	R3,CD1_R3
	ST	R5,CD1_R5
	ST	R6,CD1_R6
	ST	R7,CD1_R7

	ADD	R7,R2,#0	;checks tokens from upper left to bottom right
L14	LDR	R4,R7,#8
	ADD	R4,R4,R3
	BRnp	A3
	ADD	R7,R7,#8
	ADD	R1,R1,#1
	BRz	Diag_Win
	BRnzp	L14
A3
	ADD	R7,R2,#0	
L15	LDR	R4,R7,#-8
	ADD	R4,R4,R3
	BRnp	Diag_NoWin
	ADD	R7,R7,#-8
	ADD	R1,R1,#1
	BRz	Diag_Win
	BRnzp	L15

Diag_NoWin
	AND	R4,R4,#0
	BRnzp	Done_CheckDiag1

Diag_Win
	AND	R4,R4,#0
	ADD	R4,R4,#1	
Done_CheckDiag1
	LD	R0,CD1_R0
	LD	R1,CD1_R1
	LD	R2,CD1_R2
	LD	R3,CD1_R3
	LD	R5,CD1_R5
	LD	R6,CD1_R6
	LD	R7,CD1_R7
	RET
CD1_R0	.blkw	1
CD1_R1	.blkw	1
CD1_R2	.blkw	1
CD1_R3	.blkw	1
CD1_R5	.blkw	1
CD1_R6	.blkw	1
CD1_R7	.blkw	1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_D2						;
;	description:	2nd diagonal check.			;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_D2	
	ST	R0,CD2_R0
	ST	R1,CD2_R1
	ST	R2,CD2_R2
	ST	R3,CD2_R3
	ST	R5,CD2_R5
	ST	R6,CD2_R6
	ST	R7,CD2_R7
	
	ADD	R7,R2,#0	;checks tokens from upper right to bottom left
L16	LDR	R4,R7,#6
	ADD	R4,R4,R3
	BRnp	A4
	ADD	R7,R7,#6
	ADD	R1,R1,#1
	BRz	Diag_Win1
	BRnzp	L16
A4
	ADD	R7,R2,#0	
L17	LDR	R4,R7,#-6
	ADD	R4,R4,R3
	BRnp	Diag_NoWin1
	ADD	R7,R7,#-6
	ADD	R1,R1,#1
	BRz	Diag_Win1
	BRnzp	L17

Diag_NoWin1
	AND	R4,R4,#0
	BRnzp	Done_CheckDiag2

Diag_Win1
	AND	R4,R4,#0
	ADD	R4,R4,#1	
Done_CheckDiag2
	LD	R0,CD2_R0
	LD	R1,CD2_R1
	LD	R2,CD2_R2
	LD	R3,CD2_R3
	LD	R5,CD2_R5
	LD	R6,CD2_R6
	LD	R7,CD2_R7
	RET
CD2_R0	.blkw	1
CD2_R1	.blkw	1
CD2_R2	.blkw	1
CD2_R3	.blkw	1
CD2_R5	.blkw	1
CD2_R6	.blkw	1
CD2_R7	.blkw	1

.END
.ORIG x3000

; === MAIN PROGRAM ===

; Display welcome message prompting for 5 test scores
LEA     R0, WELCOME_MSG
PUTS
WELCOME_MSG      .STRINGZ "Enter 5 Test Scores (0 - 99): "

; Print newline after welcome message
LD      R0, NEWLINE
OUT

; ----------- Input Scores -----------

; Prompt for Score 1 and read input
LEA     R0, SCORE1_MSG
PUTS
JSR     READ_SCORE              ; Read score, result in R3
LEA     R6, SCORE_ARRAY
STR     R3, R6, #0             ; Store score 1 at SCORE_ARRAY[0]
LD      R0, NEWLINE
OUT

; Prompt for Score 2 and read input
LEA     R0, SCORE2_MSG
PUTS
JSR     READ_SCORE
LEA     R6, SCORE_ARRAY
STR     R3, R6, #1             ; Store score 2 at SCORE_ARRAY[1]
LD      R0, NEWLINE
OUT

; Prompt for Score 3 and read input
LEA     R0, SCORE3_MSG
PUTS
JSR     READ_SCORE
LEA     R6, SCORE_ARRAY
STR     R3, R6, #2             ; Store score 3 at SCORE_ARRAY[2]
LD      R0, NEWLINE
OUT

; Prompt for Score 4 and read input
LEA     R0, SCORE4_MSG
PUTS
JSR     READ_SCORE
LEA     R6, SCORE_ARRAY
STR     R3, R6, #3             ; Store score 4 at SCORE_ARRAY[3]
LD      R0, NEWLINE
OUT

; Prompt for Score 5 and read input
LEA     R0, SCORE5_MSG
PUTS
JSR     READ_SCORE
LEA     R6, SCORE_ARRAY
STR     R3, R6, #4             ; Store score 5 at SCORE_ARRAY[4]
LD      R0, NEWLINE
OUT

; ----------- Calculate Minimum Score -----------

CALC_MIN
LD      R1, TOTAL_SCORES       ; Load total scores
LEA     R2, SCORE_ARRAY        ; Load base of score array
LD      R4, SCORE_ARRAY        ; Load first score as initial min
ST      R4, MIN_SCORE          ; Store first score as initial min
ADD     R2, R2, #1             ; Point R2 to next score
ADD     R1, R1, #-1            ; Decrement loop counter by 1 (since first score processed)

LOOP_MIN
LDR     R5, R2, #0            ; Load current score
NOT     R4, R4                ; Negate current min for subtraction
ADD     R4, R4, #1
ADD     R5, R5, R4            ; current score - min
BRn     SKIP_MIN_UPDATE       ; If negative, skip updating min

ADD     R2, R2, #1            ; Move to next score
LD      R4, SCORE_ARRAY       ; Reload first score (bug: should reload current min?)
AND     R5, R5, #0
ADD     R1, R1, #-1           ; Decrement loop counter
BRp     LOOP_MIN              ; Repeat until all scores checked

; Print minimum label, value and letter grade
LEA     R0, MIN_LABEL
PUTS
LD      R3, MIN_SCORE
AND     R1, R1, #0
JSR     PRINT_INT
LD      R0, SPACE
OUT
JSR     GET_LETTER_GRADE
JSR     STACK_POP
LD      R0, SPACE
OUT

JSR     CLEAR_REGS
LD      R0, NEWLINE
OUT

; ----------- Calculate Maximum Score -----------

CALC_MAX
LD      R1, TOTAL_SCORES       ; Load number of scores (5) into R1
LEA     R2, SCORE_ARRAY        ; Load base address of score array into R2
LD      R4, SCORE_ARRAY        ; Load first score value into R4 (current max)
ST      R4, MAX_SCORE          ; Store first score as initial max
ADD     R2, R2, #1             ; Point R2 to next score

LOOP_MAX
LDR     R5, R2, #0            ; Load current score from array
NOT     R4, R4                ; Negate current max (for subtraction)
ADD     R4, R4, #1
ADD     R5, R5, R4            ; Compute (current score - max)
BRp     SKIP_MAX_UPDATE       ; If positive (score > max), skip updating max

; Print max label and value along with letter grade
LEA     R0, MAX_LABEL
PUTS
LD      R3, MAX_SCORE         ; Load max score for printing
AND     R1, R1, #0           ; Clear R1 (used for print subroutine)
JSR     PRINT_INT             ; Print integer value
LD      R0, SPACE
OUT
JSR     GET_LETTER_GRADE      ; Get letter grade for max score
JSR     STACK_POP             ; Pop and print letter grade character
LD      R0, SPACE
OUT

LD      R0, NEWLINE
OUT
JSR     CLEAR_REGS            ; Clear registers for next section

; ----------- Calculate Average Score -----------

CALC_AVG
LD      R1, TOTAL_SCORES       ; Load number of scores
LEA     R2, SCORE_ARRAY        ; Base address of scores
AND     R3, R3, #0             ; Clear R3 for sum

SUM_LOOP
LDR     R4, R2, #0            ; Load score at pointer
ADD     R3, R3, R4            ; Add to sum (R3 accumulates)
ADD     R2, R2, #1            ; Move pointer to next score
ADD     R1, R1, #-1           ; Decrement counter
BRp     SUM_LOOP              ; Loop while scores left

LD      R1, TOTAL_SCORES       ; Reload total scores
NOT     R1, R1                ; Negate total scores for division
ADD     R1, R1, #1
ADD     R4, R3, #0            ; Copy sum into R4 for division

DIV_LOOP
ADD     R4, R4, #0            ; Check if remainder is zero (to exit loop)
BRnz    DONE_AVG
ADD     R6, R6, #1            ; Increment quotient (average)
ADD     R4, R4, R1            ; Subtract divisor from remainder
BRp     DIV_LOOP

DONE_AVG
ST      R6, AVERAGE_SCORE     ; Store average score

; Print average label and value
LEA     R0, AVG_LABEL
PUTS
AND     R3, R3, #0
AND     R1, R1, #0
AND     R4, R4, #0
ADD     R3, R3, R6            ; Load average into R3 for printing
JSR     PRINT_INT
LD      R0, SPACE
OUT
JSR     GET_LETTER_GRADE      ; Get letter grade of average
JSR     STACK_POP             ; Print letter grade

HALT                         ; End program

; -------------------------------
; Constants and Data

NEWLINE             .FILL xA
SPACE               .FILL x20
ASCII_OFFSET_NEG    .FILL #-48     ; Used to convert ASCII digits to integer
ASCII_OFFSET_POS    .FILL #48
ASCII_OFFSET_30     .FILL #-30
TOTAL_SCORES        .FILL 5
RESTART_ADDR        .FILL x3000

MAX_SCORE            .BLKW 1
MIN_SCORE            .BLKW 1
AVG_DONE_FLAG        .BLKW 1
AVERAGE_SCORE        .BLKW 1

; Skip labels for min/max update branches
SKIP_MIN_UPDATE
LDR     R4, R2, #0
ST      R4, MIN_SCORE
ADD     R2, R2, #1
ADD     R1, R1, #-1
BRnzp   LOOP_MIN

SKIP_MAX_UPDATE
LDR     R4, R2, #0
ST      R4, MAX_SCORE
ADD     R2, R2, #1
ADD     R1, R1, #-1
BRp     LOOP_MAX

SCORE_ARRAY          .BLKW 5       ; Array to store 5 scores

MIN_LABEL            .STRINGZ "MIN: "
MAX_LABEL            .STRINGZ "MAX: "
AVG_LABEL            .STRINGZ "AVG: "

; Strings for input prompts
SCORE1_MSG  .STRINGZ "Score 1: "
SCORE2_MSG  .STRINGZ "Score 2: "
SCORE3_MSG  .STRINGZ "Score 3: "
SCORE4_MSG  .STRINGZ "Score 4: "
SCORE5_MSG  .STRINGZ "Score 5: "

RET_SLOT_1    .FILL x0
RET_SLOT_2    .FILL x0
RET_SLOT_3    .FILL x0
RET_SLOT_4    .FILL x0
RET_SLOT_5    .FILL x0
; -------------------------------
; Score Reading Routine

READ_SCORE
ST      R7, RET_SLOT_1         ; Save return address
JSR     CLEAR_REGS            ; Clear registers
LD      R4, ASCII_OFFSET_NEG  ; Load offset to convert ASCII to integer

GETC                         ; Get first digit from keyboard
OUT                          ; Echo input
ADD     R1, R0, #0           ; Copy input char to R1
ADD     R1, R1, R4           ; Convert ASCII to integer digit
ADD     R2, R2, #10          ; Prepare to multiply next digit by 10

MULTIPLY_10
ADD     R3, R3, R1           ; Add digit to R3 (accumulated value)
ADD     R2, R2, #-1          ; Decrement multiplier counter
BRp     MULTIPLY_10          ; Loop for more digits (?)

GETC                         ; Get second digit
OUT                          ; Echo input
ADD     R0, R0, R4           ; Convert ASCII to integer
ADD     R3, R3, R0           ; Add to accumulated value

LD      R0, SPACE
OUT

LD      R7, RET_SLOT_1        ; Restore return address
RET                         ; Return with result in R3

; -------------------------------
; Integer Print Routine

PRINT_INT
ST      R7, RET_SLOT_1        ; Save return address
LD      R5, ASCII_OFFSET_POS  ; ASCII offset for printing digits
ADD     R4, R3, #0            ; Copy integer to R4

DIVIDE_10
ADD     R1, R1, #1            ; Increment digit counter
ADD     R4, R4, #-10          ; Subtract 10 for division count
BRp     DIVIDE_10             ; Loop while positive

ADD     R1, R1, #-1           ; Adjust digit count
ADD     R4, R4, #10           ; Restore remainder
ADD     R6, R4, #-10          ; R6 = remainder - 10
BRnp    PRINT_POS             ; Branch if remainder >= 0

PRINT_NEG
ADD     R1, R1, #1
ADD     R4, R4, #-10

PRINT_POS
ST      R1, QUOTIENT          ; Store quotient (number of tens)
ST      R4, REMAINDER         ; Store remainder

LD      R0, QUOTIENT
ADD     R0, R0, R5            ; Convert quotient digit to ASCII
OUT                          ; Output quotient digit

LD      R0, REMAINDER
ADD     R0, R0, R5            ; Convert remainder digit to ASCII
OUT                          ; Output remainder digit

LD      R7, RET_SLOT_1        ; Restore return address
RET                         ; Return

QUOTIENT    .FILL x0
REMAINDER   .FILL x0

; -------------------------------
; Stack Operations for Letter Grades

STACK_PUSH
ST      R7, RET_SLOT_2         ; Save return address
JSR     CLEAR_REGS
LD      R6, STACK_PTR          ; Load current stack pointer
ADD     R6, R6, #0
BRnz    STACK_ERROR            ; If zero or negative, error (stack overflow)

ADD     R6, R6, #-1            ; Decrement stack pointer
STR     R0, R6, #0             ; Store R0 on stack
ST      R6, STACK_PTR          ; Update stack pointer
LD      R7, RET_SLOT_2         ; Restore return address
RET

STACK_PTR    .FILL x4000        ; Initial stack pointer address

STACK_POP
LD      R6, STACK_PTR          ; Load current stack pointer
ST      R1, RET_SLOT_5
LD      R1, STACK_BASE
ADD     R1, R1, R6
BRzp    STACK_ERROR            ; Check stack pointer for underflow

LD      R1, RET_SLOT_5

LDR     R0, R6, #0             ; Load top of stack into R0
ST      R7, RET_SLOT_4
OUT                          ; Output the letter grade character
LD      R0, SPACE
OUT                          ; Output space after letter grade
ADD     R6, R6, #1            ; Increment stack pointer
ST      R6, STACK_PTR          ; Save updated pointer
LD      R7, RET_SLOT_4
RET

STACK_BASE   .FILL xC000        ; Stack base address
STACK_ERROR_MSG .STRINGZ "STACK UNDERFLOW OR OVERFLOW. HALTING PROGRAM"

STACK_ERROR
LEA     R0, STACK_ERROR_MSG
PUTS
HALT

; -------------------------------
; Letter Grade Logic: Determine letter grade from numeric score

GET_LETTER_GRADE
AND     R2, R2, #0             ; Clear R2

CHECK_A
LD      R0, A_THRESHOLD        ; Load threshold (-90)
LD      R1, A_CHAR             ; Load 'A' character
ADD     R2, R3, R0             ; R3 + threshold
BRzp    STORE_GRADE            ; If >= threshold, store 'A'

CHECK_B
AND     R2, R2, #0
LD      R0, B_THRESHOLD
LD      R1, B_CHAR
ADD     R2, R3, R0
BRzp    STORE_GRADE

CHECK_C
AND     R2, R2, #0
LD      R0, C_THRESHOLD
LD      R1, C_CHAR
ADD     R2, R3, R0
BRzp    STORE_GRADE

CHECK_D
AND     R2, R2, #0
LD      R0, D_THRESHOLD
LD      R1, D_CHAR
ADD     R2, R3, R0
BRzp    STORE_GRADE

CHECK_F
AND     R2, R2, #0
LD      R0, F_THRESHOLD
LD      R1, F_CHAR
ADD     R2, R3, R0
BRNZP   STORE_GRADE            ; If all else fails, assign 'F'

RET

STORE_GRADE
ST      R7, RET_SLOT_1         ; Save return address
AND     R0, R0, #0
ADD     R0, R1, #0             ; Move letter grade char to R0
JSR     STACK_PUSH             ; Push letter grade on stack for later output
LD      R7, RET_SLOT_1         ; Restore return address
RET

; Thresholds for letter grades (negated for comparison)
A_THRESHOLD    .FILL #-90
A_CHAR         .FILL x41        ; ASCII 'A'

B_THRESHOLD    .FILL #-80
B_CHAR         .FILL x42        ; ASCII 'B'

C_THRESHOLD    .FILL #-70
C_CHAR         .FILL x43        ; ASCII 'C'

D_THRESHOLD    .FILL #-60
D_CHAR         .FILL x44        ; ASCII 'D'

F_THRESHOLD    .FILL #-50
F_CHAR         .FILL x46        ; ASCII 'F'

; -------------------------------
; Clear All Registers Routine

CLEAR_REGS
AND     R1, R1, #0
AND     R2, R2, #0
AND     R3, R3, #0
AND     R4, R4, #0
AND     R5, R5, #0
AND     R6, R6, #0
RET

.END


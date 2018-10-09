# Locals:     Are references
# Fields:     ALWAYS use copy/move
# 
# Calling a function?
#     Borrowed: Nothing special
#     Owned: Use copy/move (unless literal)
# 
# Using a parameter?
#     Borrowed: CAN'T use move, is a reference to whatever passed in
#     Owned: You can do whatever you want, it's your copy.

NOT_SET = 1

fangAnalyzer = (instruction, metadata)->
    switch instruction

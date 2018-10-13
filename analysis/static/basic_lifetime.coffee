{FrucError} = require '../../common/errors'
{Call} = require '../../compiler/fir/reg/instructions'

class LifetimeError extends FrucError
    # All instances of lifetime errors are because of users
    userError: true

# This implements a specific static analysis demo in the static analysis library
# I'm working on.
#
# What this code specifically does.
#   At compile time it will tell you if a variable may not be set.
#
# Eg.
#   if get_random_number() == 10
#       a = "foobar"
#   print(a)
#
# "a" might not be defined if the random number returned by get_random_number is
# not equal to 10. So this will result in a compiler error.
#
#   if get_random_number() == 10
#       a = "foobar"
#   else
#       a = "barfoo"
#   print(a)
#
# "a" is always going to be assigned no matter what, so this code will not cause
# a compiler error.
#
# It uses the static analysis engine that does the following, it associates some
# "static-metadata" with each variable. It inspects each instruction and calls
# one of the following operations we've defined depending on the situation.
SET = false
NOT_SET = true

# For each declared variable, its static-metadata for this analysis plugin
# is set to the return value of this function. ie. It's set to NOT_SET
exports.declare = (context, variable)->
    if variable.isParameter
        return SET
    return NOT_SET

# When the control flow merges, call the following function to figure out
# how to calculate its static-metadata. target and source are the values of
# the static-metadata in each branch.
#
# Eg.
# if ( ... ) {
#   // Change the state in some way in this branch
# } else {
#   // Change the state in a different way in this branch
# }
# // Merge gets called here for each variable
exports.merge = (context, variable, target, source)->
    # If it is NOT_SET in either branch then it could be NOT_SET in merged
    # branches too.
    if target == NOT_SET or source == NOT_SET
        return NOT_SET
    return SET

# Called when a variable is set by a given instruction. The return value is
# the new static-metadata state for the variable.
exports.set = (context, instruction, variable, state)->
    return SET

# Called when a variable is used by a given instruction. Returns nothing.
exports.get = (context, instruction, variable, state)->
    if state == NOT_SET
        context.error new LifetimeError instruction,
            "The variable #{variable.name} may not be defined at this point."
        return state

    if instruction.opcode == Call::opcode and instruction.function == 'move'
        return NOT_SET

    return state

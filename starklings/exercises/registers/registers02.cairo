%lang starknet
from starkware.cairo.common.math_cmp import is_le

# TODO
# Rewrite those functions with a high level syntax
@external
func sum_array(array_len : felt, array : felt*) -> (sum : felt):
    let (res) = rec_sum_array(array_len, array, 0)
    return (res)

    # [ap] = [fp - 4]; ap++
    # [ap] = [fp - 3]; ap++
    # [ap] = 0; ap++
    # call rec_sum_array
    # ret
end

func rec_sum_array(array_len : felt, array : felt*, sum : felt) -> (sum : felt):
    # while looping : accumulator takes value of sum+[array]
    if array_len != 0:
        return rec_sum_array(array_len - 1, array + 1, sum + [array])
    end

    # End of recursion, return some
    return (sum)

    # jmp continue if [fp - 5] != 0

    # stop:
    # [ap] = [fp - 3]; ap++
    # jmp done

    # continue:
    # [ap] = [[fp - 4]]; ap++
    # [ap] = [fp - 5] - 1; ap++
    # [ap] = [fp - 4] + 1; ap++
    # [ap] = [ap - 3] + [fp - 3]; ap++
    # call rec_sum_array

    # done:
    # ret
end

# TODO
# Rewrite this function with a low level syntax
# It's possible to do it with only registers, labels and conditional jump. No reference or localvar
@external
func max{range_check_ptr}(a : felt, b : felt) -> (max : felt):
    # let (res) = is_le(a, b)

    [ap] = [fp - 5]; ap++  # range_check_ptr
    [ap] = [fp - 4]; ap++  # a
    [ap] = [fp - 3]; ap++  # b

    call is_le  # is_le{range_check_ptr}(a,b)

    [ap] = [ap - 2]; ap++  # returned range_check_ptr
    # [ap] = [ap - 2]; ap++  # result
    # %{ print(memory[ap-1]) %}

    jmp b_higher if [ap - 2] != 0  # if res = 1 go to branch_b else go to branch b

    a_higher:
    [ap] = [fp - 4]; ap++  # return a
    jmp done

    b_higher:
    [ap] = [fp - 3]; ap++  # return b
    jmp done

    done:
    ret

    # if res == 1:
    #     return (b)
    # else:
    #     return (a)
    # end
end

#########
# TESTS #
#########

from starkware.cairo.common.alloc import alloc

@external
func test_max{range_check_ptr}():
    let (m) = max(21, 42)
    assert m = 42
    let (m) = max(42, 21)
    assert m = 42
    return ()
end

@external
func test_sum():
    let (array) = alloc()
    assert array[0] = 1
    assert array[1] = 2
    assert array[2] = 3
    assert array[3] = 4
    assert array[4] = 5
    assert array[5] = 6
    assert array[6] = 7
    assert array[7] = 8
    assert array[8] = 9
    assert array[9] = 10

    let (s) = sum_array(10, array)
    assert s = 55

    return ()
end

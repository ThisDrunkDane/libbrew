/*
 *  @Name:     remove
 *  
 *  @Author:   Brendan Punsky
 *  @Email:    bpunsky@gmail.com
 *  @Creation: 28-11-2017 00:10:03 UTC-5
 *
 *  @Last By:   Brendan Punsky
 *  @Last Time: 21-12-2017 20:40:11 UTC-5
 *  
 *  @Description:
 *  
 */

import "core:mem.odin"
import "core:raw.odin"

remove :: inline proc(array: ^[dynamic]$T, indices: ...int) do remove_unordered(array, ...indices);

// remove_unordered requires indices to be in order or it can fuck up big time
remove_unordered :: proc(array: ^[dynamic]$T, indices: ...int) {
    assert(array != nil && len(array^) != 0);

    a := cast(^raw.Dynamic_Array) array;

    for i := len(indices) - 1; i >= 0; i -= 1 {
        index := indices[i];

        if index < 0 || a.len <= 0 || a.len <= index do return;

        if index < a.len - 1 {
            array[index] = array[a.len-1];
        }

        a.len -= 1;
    }
}

remove_ordered :: proc(array: ^[dynamic]$T, indices: ...int) {
    assert(array != nil && len(array^) != 0);

    a := cast(^raw.Dynamic_Array) array;

    for idx, i in indices {
        index := idx - i;

        if index < 0 || a.len <= 0 || a.len <= index do return;

        if index < a.len - 1 {
            mem.copy(&array[index], &array[index+1], size_of(T) * (a.len - index));
        }
        
        a.len -= 1;
    }
}

remove_value :: proc(array: ^[dynamic]$T, values: ...T) {
    assert(array != nil && len(array^) != 0);

    indices := make([]int, 0, len(values));
    defer free(indices);

    for i in 0..len(array) {
        for value in values {
            when T == any {
                if array[i].data == value.data do append(&indices, i);
            } else {
                if array[i] == value do append(&indices, i);
            }
        }
    }

    remove(array, ...indices);
}

remove_value_ordered :: proc(array: ^[dynamic]$T, values: ...T) {
    assert(array != nil && len(array^) != 0);

    indices := make([]int, 0, len(values));
    defer free(indices);

    for i in 0..len(array) {
        for value in values {
            when T == any {
                if array[i].data == value.data do append(&indices, i);
            } else {
                if array[i] == value do append(&indices, i);
            }
        }
    }

    remove_ordered(array, ...indices);
}

pop_front :: inline proc(array: ^[dynamic]$T) -> T {
    tmp := array[0];
    
    remove_ordered(array, 0);
    
    return tmp;
}

append_front :: proc(array: ^[dynamic]$T, value: T) -> int {
    assert(array != nil);

    length := len(array);

    append(array, T{});

    if length != 0 {
        #no_bounds_check mem.copy(&array[1], &array[0], size_of(T) * length);
    }

    array[0] = value;

    return 0;
}
//! Regression tests for issue #9696: divergent control-flow expressions lower
//! through Monotype instead of tripping a postcheck invariant.

const expectLowersToLir = @import("lower_to_lir_harness.zig").expectLowersToLir;

test "issue 9696: if expression with only crash branches lowers to LIR" {
    try expectLowersToLir(
        \\choose : Bool -> Str
        \\choose = |flag| {
        \\    if flag {
        \\        crash "true branch"
        \\    } else {
        \\        crash "false branch"
        \\    }
        \\}
        \\
        \\main! = |_args| {
        \\    _ = choose(False)
        \\    Ok({})
        \\}
    );
}

test "issue 9696: match expression with only crash branches lowers to LIR" {
    try expectLowersToLir(
        \\choose : Bool -> Str
        \\choose = |flag| {
        \\    match flag {
        \\        True => { crash "true branch" }
        \\        False => { crash "false branch" }
        \\    }
        \\}
        \\
        \\main! = |_args| {
        \\    _ = choose(False)
        \\    Ok({})
        \\}
    );
}

test "issue 9696: if expression with reassigned branch state lowers to LIR" {
    try expectLowersToLir(
        \\choose : Bool -> Str
        \\choose = |flag| {
        \\    var message = "initial"
        \\    if flag {
        \\        message = "true branch"
        \\        _ = message
        \\        crash "true branch"
        \\    } else {
        \\        message = "false branch"
        \\        _ = message
        \\        crash "false branch"
        \\    }
        \\}
        \\
        \\main! = |_args| {
        \\    _ = choose(False)
        \\    Ok({})
        \\}
    );
}

test "issue 9696: condition-divergent if and match expressions lower to LIR" {
    try expectLowersToLir(
        \\choose_if : Bool -> Str
        \\choose_if = |flag| {
        \\    if (if flag { crash "condition" } else { crash "condition" }) {
        \\        "true"
        \\    } else {
        \\        "false"
        \\    }
        \\}
        \\
        \\choose_match : Bool -> Str
        \\choose_match = |flag| {
        \\    match if flag { crash "condition" } else { crash "condition" } {
        \\        True => "true"
        \\        False => "false"
        \\    }
        \\}
        \\
        \\main! = |_args| {
        \\    _ = choose_if(False)
        \\    _ = choose_match(False)
        \\    Ok({})
        \\}
    );
}

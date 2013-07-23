module unit_threaded.check;

@safe

import std.exception;
import std.conv;
import std.algorithm;
import std.traits;

class UnitTestException: Exception {
    this(string msg) {
        super(msg);
    }
}

void checkTrue(bool condition, string file = __FILE__, ulong line = __LINE__) {
    if(!condition) failEqual(condition, true, file, line);
}

void checkFalse(bool condition, string file = __FILE__, ulong line = __LINE__) {
    if(condition) failEqual(condition, false, file, line);
}

void checkEqual(T, U)(T value, U expected, string file = __FILE__, ulong line = __LINE__)
if(is(typeof(value != expected) == bool)) {
    if(value != expected) failEqual(value, expected, file, line);
}

void checkNotEqual(T)(T value, T expected, string file = __FILE__, ulong line = __LINE__) {
    if(value == expected) failEqual(value, expected, file, line);
}

void checkNull(T)(T value, string file = __FILE__, ulong line = __LINE__) {
    if(value !is null) fail(getOutputPrefix(file, line) ~ "Value is null");
}

void checkNotNull(T)(T value, string file = __FILE__, ulong line = __LINE__) {
    if(value is null) fail(getOutputPrefix(file, line) ~ "Value is null");
}

void checkIn(T, U)(T value, U container, string file = __FILE__, ulong line = __LINE__)
    if(isAssociativeArray!U)
{
    if(value !in container) {
        fail(getOutputPrefix(file, line) ~ "Value " ~ to!string(value) ~ " not in " ~ to!string(container));
    }
}

void checkIn(T, U)(T value, U container, string file = __FILE__, ulong line = __LINE__)
    if(!isAssociativeArray!U)
{
    if(!find(container, value)) {
        fail(getOutputPrefix(file, line) ~ "Value " ~ to!string(value) ~ " not in " ~ to!string(container));
    }
}

void checkNotIn(T, U)(T value, U container, string file = __FILE__, ulong line = __LINE__)
    if(isAssociativeArray!U)
{
    if(value in container) {
        fail(getOutputPrefix(file, line) ~ "Value " ~ to!string(value) ~ " in " ~ to!string(container));
    }
}

void checkNotIn(T, U)(T value, U container, string file = __FILE__, ulong line = __LINE__)
    if(!isAssociativeArray!U)
{
    if(find(container, value).length > 0) {
        fail(getOutputPrefix(file, line) ~ "Value " ~ to!string(value) ~ " in " ~ to!string(container));
    }
}

void utFail(in string output, in string file, in ulong line) {
    fail(getOutputPrefix(file, line) ~ output);
}

private void fail(in string output) pure {
    throw new UnitTestException(output);
}

private void failEqual(T, U)(in T value, in U expected, in string file, in ulong line) {
    throw new UnitTestException(getOutput(value, expected, file, line));
}

private string getOutput(T, U)(in T value, in U expected, in string file, in ulong line) {
    return getOutputPrefix(file, line) ~
        "Value " ~ to!string(value) ~
        " is not the expected " ~ to!string(expected) ~ "\n";
}

private string getOutputPrefix(in string file, in ulong line) {
    return "\n    " ~ file ~ ":" ~ to!string(line) ~ " - ";
}


private void assertCheck(E)(lazy E expression) {
    assertNotThrown!UnitTestException(expression);
}

unittest {
    assertCheck(checkTrue(true));
    assertCheck(checkFalse(false));
}


unittest {
    assertCheck(checkEqual(true, true));
    assertCheck(checkEqual(false, false));
    assertCheck(checkNotEqual(true, false));

    assertCheck(checkEqual(1, 1));
    assertCheck(checkNotEqual(1, 2));

    assertCheck(checkEqual("foo", "foo"));
    assertCheck(checkNotEqual("f", "b"));

    assertCheck(checkEqual(1.0, 1.0));
    assertCheck(checkNotEqual(1.0, 2.0));

    assertCheck(checkEqual([2, 3], [2, 3]));
    assertCheck(checkNotEqual([2, 3], [2, 3, 4]));

    int[] ints = [ 1, 2, 3];
    byte[] bytes = [ 1, 2, 3];
    assertCheck(checkEqual(ints, bytes));
    assertCheck(checkEqual(bytes, ints));

    assertCheck(checkEqual([1: 2.0, 2: 4.0], [1: 2.0, 2: 4.0]));
    assertCheck(checkNotEqual([1: 2.0, 2: 4.0], [1: 2.2, 2: 4.0]));
}

unittest {
    assertCheck(checkNull(null));
    class Foo { };
    assertCheck(checkNotNull(new Foo));
}

unittest {
    assertCheck(checkIn(4, [1, 2, 4]));
    assertCheck(checkNotIn(3.5, [1.1, 2.2, 4.4]));
    assertCheck(checkIn("foo", ["foo": 1]));
    assertCheck(checkNotIn(1.0, [2.0: 1, 3.0: 2]));
}

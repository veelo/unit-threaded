import testcase;
import std.stdio;

class Foo: TestCase {
    override void test() {
        assertTrue(5 == 3);
        assertFalse(5 == 5);
        assertEqual(5, 5);
        assertNotEqual(5, 3);
        assertEqual(5, 3);
    }
}


void main() {
    writeln("Testing Unit Threaded code...");
    auto foo = new Foo;
    auto result = foo.run();
    write(result.output);
}

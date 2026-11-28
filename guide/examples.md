# ghūl by example

Short programs, one per area of the language. Each compiles on its own with
the current compiler; a file that declares only definitions compiles with
`--library`. Imitate them, and look up anything they leave open in
`ghul/GHUL.md`. The first, `00-traps`, is the mistakes made most often, as
wrong and right pairs.

<!-- Generated from the maintainer's compiled example corpus. Edit the corpus, not this file. -->

## 00-traps

```ghul
// ghūl by example — 00: the traps, as wrong/right pairs.
// Every "wrong:" line is a comment; the right form beside it compiles.

use default

trap_names() is
    // .NET members are snake_case, not PascalCase
    // wrong: s.Length;  list.Count;  builder.Append(x)
    // the maths functions are bare names from use default: sqrt, floor, pi
    let r = sqrt(2.0);
    let n = "hello".length;

    // write_line must be imported (use IO.Std.write_line, or use default)
    write_line("hello {r} {n}");
si

trap_strings() is
    // strings have no + : join with interpolation
    // wrong: let s = "a" + "b";
    let s = "{"a"}{"b"}";

    // == compares references on strings; =~ compares text
    let built = "{"hel"}{"lo"}";
    // wrong: built == "hello"
    let same = built =~ "hello";
    write_line("{s} {same}");
si

trap_scalars() is
    // a number widens to a wider one (int -> long, single, double; long ->
    // single, double; single -> double) in arithmetic, call arguments, typed
    // slots and if/case/array joins; nothing narrows, and decimal and ==
    // never widen
    // wrong: let n: int = 2.5;  1.0m + 1;  1 == 1.0
    let ok = 1.0 + 1;
    let slot: double = 1;
    let joined = if ok > 1.0 then 1 else 2.5 fi;   // double
    let also = 1.0m + decimal(1);
    let same = double(1) == 1.0;
    write_line("{ok} {slot} {joined} {also} {same}");
si

trap_optionals() is
    let name: string? = lookup();
    // wrong: write_line(name) — a T? must be narrowed before use as a T
    if name? then
        write_line("hello, {name}");
    fi
si

lookup() -> string? => null

trap_locals() is
    // block keywords mirror their opener: is/si, if/fi, do/od, case/esac, try/yrt
    // a semicolon separates statements on one line; none is needed at line end
    let count mut = 0;
    count = count + 1; write_line("{count}");   // mut is required to reassign
si

trap_arrays() is
    // an ARRAY is read-only: it has no assigning indexer
    // wrong: let flags = [false, false, false]; flags[1] = true
    // a LIST is the mutable one: build it with |> LIST(), or repeat(value, n) |> LIST()
    let flags = repeat(false, 3) |> LIST();
    flags[1] = true;
    write_line("{flags[1]}");
si

// there is no main(): a program is its top-level statements, or an entry() function
// (see 10-hello)
// wrong: main() is ... si
```

## 10-hello

```ghul
// ghūl by example — 10: a complete minimal program.
// Top-level statements run in source order as the entry point; a file
// with top-level statements cannot also declare a namespace.

use default

write_line("hello");

for i in 1::3 do
    write_line("number {i}");
od

// top-level statements can await: the program ends when the last one finishes
await Concurrency.sleep(1);
write_line("done");

// An explicit entry is equally valid, with any of these signatures
// (parameters are recognised by type, in either order):
//   entry()
//   entry(args: string[]) -> int
//   entry(env: Ghul.Environment)
//   entry(args: string[], env: Ghul.Environment) -> int
//   entry() -> Concurrency.Future
//   entry(args: string[]) -> Concurrency.Future[int]   (the int is the exit status)
// A REPL cell's top-level statements cannot await.
```

## 20-scalars

```ghul
// ghūl by example — 20: scalar literals and conversion.
// byte and ubyte are the opposite way round from .NET: byte is signed.

use IO.Std.write_line

scalars() is
    let i = 12_345;               // int
    let hex = 0x1234_ABCD;        // int, hexadecimal
    let big = 1_000_000_000L;     // long
    let b = 99b;                  // byte
    let ub = 0ub;                 // ubyte
    let w = 123w;                 // word
    let sh = 4567s;               // short
    let us = 7890us;              // ushort
    let ratio = 123.456;          // double
    let coarse = 123.456s;        // single
    let price = 19.99m;           // decimal
    let huge = 900719925474099n;  // bigint
    let z = 3r + 4j;              // complex: r is real, j imaginary
    let letter = 'c';             // char

    // a backtick separates a suffix that would otherwise read as a hex digit
    let euro = 0x20AC`c;          // char
    let byte_max = 0xFF`ub;       // ubyte

    // int widens to long, single and double in arithmetic, at a call
    // argument, into a typed slot and in a join; anything else converts
    // explicitly
    let half = i / 2.0;           // the int widens to double
    let root = Ghul.Math.sqrt(i); // so does a call argument
    let exact = decimal(i) / 2m;  // decimal never widens; a scalar type is a converting constructor
    let code = int('A');          // 65
    let as_long: long = _(i);     // _ converts to the type the context expects
    let trunc = int(ratio);       // truncates; out of range wraps

    // int and long widen to bigint in arithmetic and ordering, from
    // ghul.runtime 52.1.0; == never widens, so compare with 2n, not 2
    let doubled = huge * 2n;

    write_line("{i} {hex} {big} {b} {ub} {w} {sh} {us} {ratio} {coarse} {price} {huge} {z * 2} {letter} {euro} {byte_max} {half} {root} {exact} {code} {as_long} {trunc} {doubled}");
si
```

## 25-strings

```ghul
// ghūl by example — 25: strings and interpolation.
// { starts an expression inside a literal; {{ and }} escape literal braces.

use default
use Ghul

strings() is
    let name = "alice";
    let age = 30;

    // interpolation converts any value; nested string literals need no escapes
    let greeting = "hello {name}, you are {age} years old";
    let inner = "{format("hello")}";

    // alignment and format specifiers, as in .NET
    let value = 1500.0;
    let padded = "[{value,12:F3}]";

    // escapes: \t \n \r \\ \uXXXX (exactly four hex digits, one char);
    // any other character after \ is that character, so \" is a quote
    let euro = "€";
    let braces = "{{}} \t A";

    // joining: interpolation, since there is no +
    let first = "hello";
    let second = "world";
    let both = "{first}, {second}";

    write_line("{greeting} {inner} {padded} {euro} {braces} {both}");
si

format(s: string) -> string => "<{s}>"

display_forms() is
    // interpolation writes any value: a sequence in brackets, a tuple in
    // parentheses; no $ is needed inside a string
    let xs = [1, 2, 3];
    let point = (x = 10, y = 20);

    write_line("{xs}");
    write_line("{point}");

    // $ gives that same text as a value, for use outside interpolation
    let text = $(xs);

    // inspect quotes strings and characters inside a value; it is in Ghul
    write_line("{inspect("top")}");
    write_line("{inspect(xs)}");

    // a sequence becomes text with string(p) / string(p, separator)
    let digits = xs |> string();
    let commas = ["a", "b", "c"] |> string(", ");
    write_line("{digits} {commas}");
si
```

## 30-variables

```ghul
// ghūl by example — 30: local variables.
// A bare let is immutable; a trailing mut allows reassignment.

use IO.Std.write_line

compute() -> int => 42

struct Point(x: int public, y: int public);

class Node(tag: string public);

variables() is
    let i = 1234;                // type inferred as int
    let k: int = 5678;           // explicit type

    let counter mut = 0;         // initialised, reassignable
    counter = counter + 1;

    let result: int mut;         // deferred: starts at the default value,
    result = compute();          // definite-assignment analysis covers reads

    let first = 1, second: int = 0, third = "three";    // one let, several variables

    let (a, b) = (10, "hello");  // tuple destructuring
    let (x, y) = Point(3, 7);   // positional deconstruct of a class
    let _ = compute();           // discard placeholder

    // null does not decide a type: the local becomes the optional of
    // whatever is assigned later
    let root mut = null;         // Node?, from the assignment below
    root = Node("first");
    write_line("{root.tag}");    // assignment narrows: no presence test needed

    // a mut local with no written type takes the join of its values
    let n mut = 1;
    n = 2;

    write_line("{i} {k} {counter} {result} {first} {second} {third} {a} {b} {x} {y} {n}");
si
```

## 40-control-flow

```ghul
// ghūl by example — 40: conditionals and loops.

use default

control_flow(xs: Collections.LIST[int]) is
    if xs.count > 2 then
        write_line("many");
    elif xs.count == 2 then
        write_line("two");
    else
        write_line("few");
    fi

    // an if is also an expression; with no else it produces an optional
    let sign = if xs.count >= 0 then "non-negative" else "negative" fi;
    write_line(sign);

    let counter mut = 0;
    while counter < 5 do
        counter = counter + 1;
    od

    do
        write_line("once");
        break;
    od

    for i in 1::5 do
        write_line("number {i}");
    od

    for x in xs do
        write_line("{x}");
    od

    // loop labels: break and continue can name an enclosing loop
    outer: for i in 0..3 do
        for j in 0..3 do
            if j > i then
                continue outer;
            fi

            if i == 2 then
                break outer;
            fi

            write_line("i {i} j {j}");
        od
    od
si

loops_as_values(xs: int{}) -> int is
    // every loop is an expression of optional type: break E produces the
    // value, normal exhaustion produces the absent value
    let found: int? = for x in xs do
        if x % 7 == 0 then break x fi;
    od;

    if let hit: int = found then
        write_line("found {hit}");
    fi

    let first_negative: int? = for x in xs do
        if x < 0 then break x fi;
    od;

    case first_negative
    when null then 0
    else 1
    esac
si
```

## 45-if-let-and-case

```ghul
// ghūl by example — 45: if let, while let, and case.

use default

enum Color is
    RED,
    GREEN,
si

union Shape is
    CIRCLE(radius: double);
    SQUARE(side: double);
si

class Customer(name: string public);

class Order(customer: Customer? public);

shape() -> Shape => Shape.CIRCLE(2.0)

if_let_forms(a: object?, pair: (int, string), entry: (Color, string), expected: int) is
    // presence test
    if let v = a then
        write_line("present: {v}");
    fi

    // type test: the variable is narrowed to the type in the then-arm
    if let s: string = a then
        write_line("string of length {s.length}");
    fi

    // destructuring with a literal leaf: position 0 must equal 1
    if let (1, name) = pair then
        write_line("first is one: {name}");
    fi

    // a leaf marked ~ tests against a value already in scope
    if let (~expected, name) = pair then
        write_line("expected: {name}");
    fi

    // an enum member leaf
    if let (Color.RED, label) = entry then
        write_line("red: {label}");
    fi

    // guards, separated by /\, run after the test with the variables in scope
    if let c: Shape.CIRCLE = shape() /\ c.radius > 3.0 then
        write_line("big circle {c.radius}");
    fi

    // several clauses, separated by commas: all must succeed; later clauses
    // can use earlier clauses' variables
    if let s: string = a, len = s.length then
        write_line("length {len}");
    fi

    // short form: the last path segment names the new variable
    let order = get_order();
    if let order.customer then
        write_line("customer: {customer.name}");
    fi
si

get_order() -> Order => Order(Customer("bob"))

while_let(a: object?) is
    // the loop runs while the clause matches; all if let forms work
    while let s: string = a do
        write_line("{s}");
        break;
    od
si

case_shapes(s: Shape) -> string =>
    // a case expression over a union: covering every variant needs no else
    case s
    when c: Shape.CIRCLE /\ c.radius > 3.0 then "big circle"
    when c: Shape.CIRCLE then "circle {c.radius}"
    when q: Shape.SQUARE then "square {q.side}"
    esac

case_values(status: int) -> string =>
    // a when with a list of values matches by =~; else catches the rest
    case status
    when 200 then "ok"
    when 500, 501, 502 then "server error"
    else "other"
    esac

case_bool(b: bool) -> int =>
    case b
    when true then 1
    when false then 0
    esac

describe_list(xs: int[]) -> string =>
    // sequence patterns: [] and [x, ..rest] together cover every list
    case xs
    when [] then "empty"
    when [x] then "one: {x}"
    when [x, ..more] then "{x} and {more.count} more"
    esac
```

## 50-blocks

```ghul
// ghūl by example — 50: block expressions, assert, and exceptions.

use default

blocks() is
    // a parenthesised block runs statements; its value is the last one
    let z = (let a = 3; let b = 4; a + b);

    // a block can be a whole => body; return exits the block, not the function
    write_line(sign_label(5));
    write_line("{z}");
si

sign_label(n: int) -> string => (
    if n < 0 then
        return "neg";
    fi;
    if n == 0 then
        return "zero";
    fi;
    "pos"
)

at(xs: Collections.LIST[int], i: int) -> int =>
    // assert ... else "message" in expr: checks a condition before an expression
    assert i >= 0 else "negative index" in
    xs[i]

checks(i: int) is
    assert i >= 0;                              // message is location + condition text
    assert i < 10 else "index out of range";    // message is prefixed with the location
si

exceptions() -> int is
    try
        risky();
        return 1;
    catch e: Ghul.DivideByZeroException
        write_line("div by zero: {e.message}");
        return 2;
    catch e: Ghul.Exception
        write_line("other: {e.message}");
        return 3;
    finally
        write_line("done");                     // runs before any return leaves the try
    yrt
si

risky() -> int => throw Ghul.Exception("not implemented")   // throw can be a whole body
```

## 55-functions

```ghul
// ghūl by example — 55: functions, literals, closures, and pipes.

use default

add(a: int, b: int) -> int => a + b                    // expression body

multiply(a: int, b: int) -> int is                     // block body; the tail is the value
    let result = a * b;
    result
si

// a case over the arguments as the body
gcd(a: int, b: int) -> int =>
    case (a, b)
    when (_, 0) then a
    else gcd(b, a % b)
    esac

// overloads at namespace scope, chosen by argument types
area(r: double) -> double => 3.14159 * r * r;
area(w: double, h: double) -> double => w * h

halve(n: int) -> int? => if n % 2 == 0 then n / 2 else null fi

label(n: int) -> string => "n={n}"

// in a file with no namespace block, a function may leave types out of its
// signature: they are inferred from the file, and the function is private
// to it. A return left out comes from an => expression, or from an is
// body's returns and its last statement; with every parameter typed, from
// its returns only
quarter(x: int) => x / 4                                // returns int
scaled(factor, x: double) -> double => factor * x       // factor typed from its calls

functions() is
    // literals: parameter and return types are usually inferred
    let twice = x => x * 2;
    let piped = 21 |> twice();           // x |> f() is f(x), with f a value here
    write_line("{twice(21)} {piped}");

    // a literal refers to itself with rec
    let factorial = n rec => if n <= 1 then 1 else n * rec(n - 1) fi;

    // closures: let is captured by value, let mut is shared by reference
    let count mut = 0;
    let bump = () => (count = count + 1; count);
    bump();
    write_line("{count}");

    // a destructure pattern as the literal's parameter
    let add_pair = ((a, b): (int, int)) => a + b;

    // function types as parameter and slot types
    let apply_to_ten = (f: (int) -> int) => f(10);
    let f2: (int, int) -> int = (a, b) => a + b;

    // a nested function is a local, usable as a value or by call
    score(x: int) -> int is
        if x < 0 then
            return 0;
        fi
        x * 2
    si

    let scored = [1, -2, 3] |> map(score) |> sum();

    // |> threads the left value as the first argument; chains associate left
    let evens_total = [1, 2, 3, 4, 5] |> filter(x => x % 2 == 0) |> sum();

    // ~> propagates absence: the call is skipped when the left value is absent
    let r = 8 |> halve() ~> label() ?? "none";

    // * as an argument partially applies the call: one parameter per *, and
    // the other arguments are evaluated once, here
    let add_ten = add(10, *);
    let scaled = [1, 2, 3] |> map(multiply(*, 100)) |> sum();

    write_line("{factorial(5)} {add_pair((3, 4))} {apply_to_ten(twice)} {f2(1, 2)} {scored} {evens_total} {r} {add_ten(5)} {scaled}");

    write_line("{quarter(20)} {scaled(2.0, 1.5)}");

    // use before a pipe disposes the produced value; .iterator binds first
    // for line in use IO.File.read_lines(path).iterator do ... od
si
```

## 57-loops-as-values

```ghul
// ghūl by example — 57: control flow that is a value.
// Each function here has a while-loop spelling with mut locals; these are
// the forms to write when they are no longer than the loop.

use default

// a sequence pattern peels a list: [] and [x, ..rest] cover every list,
// and rest is a view of the source, not a copy
sum_list(xs: int[]) -> int =>
    case xs
    when [] then 0
    when [x, ..rest] then x + sum_list(rest)
    esac

// nested patterns over a tuple of lists: a merge with no index variables
merge(xs: int[], ys: int[]) -> int{} =>
    case (xs, ys)
    when ([], _) then ys
    when (_, []) then xs
    when ([x, ..xr], [y, ..yr]) then
        if x <= y then [x] ++ merge(xr, ys) else [y] ++ merge(xs, yr) fi
    esac

// a nested recursive function carries the state a while loop would mutate
digit_sum(value: int, base: int) -> int is
    walk(remaining: int, total: int) -> int =>
        if remaining == 0 then total
        else walk(remaining / base, total + remaining % base) fi

    walk(value, 0)
si

// a case over a tuple as the whole body replaces a chain of ifs
fizz(n: int) -> string =>
    case (n % 3, n % 5)
    when (0, 0) then "FizzBuzz"
    when (0, _) then "Fizz"
    when (_, 0) then "Buzz"
    else "{n}"
    esac

// an unbounded source ended downstream replaces a sieve to a guessed limit
is_prime(n: int) -> bool =>
    n > 1 /\ 2::int(sqrt(double(n))) |> all(d => n % d != 0)

first_primes(count: int) -> int{} => from(2) |> filter(is_prime) |> take(count)

loops_as_values() is
    write_line("{sum_list([1, 2, 3])} {merge([1, 4], [2, 3]) |> join()}");
    write_line("{digit_sum(1234, 10)} {fizz(15)} {first_primes(5) |> join()}");
si
```

## 60-optionals

```ghul
// ghūl by example — 60: optionals.

use IO.Std.write_line

class Person(name: string public, age: int public) is
    describe() -> string => "{name} ({age})";
si

find_person(id: int) -> Person? => if id == 1 then Person("alice", 30) else null fi

optionals(id: int) is
    let p: Person? = find_person(id);

    // if p? narrows p inside the arm: use it as a Person directly
    if p? then
        write_line("hello {p.name}");
    fi

    // if let narrows and names the value in one step
    if let person = find_person(id) then
        write_line("hello, {person.name}");
    fi

    // ?. is coalescing member access and calls; the result is always optional
    let name = p?.name;              // string?
    let upper = p?.describe();       // string? — the call short-circuits too

    // ?? gives a fallback; it is right-associative, and ends an optional chain
    let display = p?.name ?? "unknown";

    // ! asserts presence: it throws when the value is absent
    let forced = find_person(1)!;

    write_line("{name} {upper} {display} {forced.name}");
si

coalescing(b: bool?) is
    // in a condition, ?? treats an absent value as the fallback
    if b ?? false then
        write_line("true");
    fi
si
```

## 65-collections-pipes

```ghul
// ghūl by example — 65: collections and the pipe combinators.

use default

class Person(name: string public);

people() -> Person{} =>
    [Person("alice"), Person("bob")]

square_if_even(x: int) -> int? => if x % 2 == 0 then x * x else null fi

collections() is
    // constructors take any sequence; element types come from the sequence
    let xs = LIST[int]([1, 2, 3]);
    let arr = [1, 2, 3] |> map(* * 2) |> ARRAY(); // array, built now
    let mut_list = [1, 2] |> LIST();              // LIST
    let names_set = ["a", "b"] |> SET();          // SET
    let scores = [("alice", 1), ("bob", 2)] |> MAP();
    let lazy: int[] = from(1) |> take(5) |> list(); // a T[], filled as it is read
    let by_name = MAP(people() |> map(p => (p.name, p)));
    let seen: SET[string] = _(["x"]);             // _ constructs what the context expects

    let alice = scores["alice"];

    // iterators: next reads one element, absent only at the end
    let it = xs.iterator;
    let first = it |> next();
    if first? then
        write_line("first {first}");
    fi

    for n in it do
        write_line("{n}");
    od

    // ++ joins sequences lazily, as cat does
    let all = [1, 2] ++ [3] ++ [4, 5];

    // lazy stages: map filter flat_map skip take cat index zip sort
    // terminals: reduce sum product count find find_map first only any
    //            all each join append_to list; the constructors ARRAY LIST
    //            SET MAP build a collection now
    let evens = [1, 2, 3, 4] |> filter(x => x % 2 == 0);
    let doubled = [1, 2] |> map(x => x * 2);
    let total = [1, 2, 3, 4, 5] |> sum();
    let folded = [1, 2, 3, 4, 5] |> reduce(1, (acc, x) => acc * x);
    let odd_count = [1, 2, 3] |> count(x => x % 2 == 1);
    let hit = [3, 7, 11] |> find(x => x % 7 == 0);              // int?
    let first_square = [1, 2, 3] |> find_map(square_if_even);
    let joined = ["a", "b"] |> join(", ");

    // each takes a (T) -> anything literal and discards its result
    ["x", "y"] |> each(n => seen.add(n));

    // min and max return MAYBE[T]: an empty sequence has neither
    let least = [3, 1, 2] |> min();
    if let l = least then
        write_line("least {l}");
    fi

    // pipes from values: repeat, from, stream
    let blanks = repeat(false, 100) |> LIST();
    let squares = from(1) |> map(n => n * n) |> take(5);
    let fibs = stream((0, 1), (a, b) => (a, (b, a + b)));    // (value, next state)

    // a pipe has no count member: count() is one of the terminals
    let n_all = all |> count();
    let n_squares = squares |> count();

    write_line("{xs.count} {arr.count} {mut_list.count} {names_set.count} {lazy.count} {alice} {n_all} {total} {folded} {odd_count} {hit} {first_square} {joined} {blanks.count} {n_squares} {first}");
si
```

## 70-generators-comprehensions

```ghul
// ghūl by example — 70: generators and comprehensions.

use default

counting(limit: int) -> int{} is
    let i mut = 0;
    while i < limit do
        yield i;
        i = i + 1;
    od
si

union Tree is
    NODE(left: Tree, value: int, right: Tree);
    EMPTY;
si

// yield in yields each element of a sequence: the usual recursive-generator form
preorder(t: Tree) -> int{} is
    if let node: Tree.NODE = t then
        yield in preorder(node.left);
        yield node.value;
        yield in preorder(node.right);
    fi
si

generators() is
    for n in counting(4) do
        write_line("{n}");
    od

    // a generator literal: each read runs the body again from the start
    let evens = (limit: int) is
        let n mut = 0;
        while n < limit do
            yield n;
            n = n + 2;
        od
    si;

    evens(6) |> each(n => write_line("{n}"));

    // an array comprehension builds its whole array before anything reads it
    let squares = [x * x for x in 1::5];
    let pairs = [(a, b) for a in 1::3 for b in a::3 if a != b];
    let lengths = [name.length for name in ["alpha", "beta"]];

    // braces make the same clauses lazy: a Pipe[T], so the source can be unbounded
    let naturals = {n for n in from(0)};
    let first_ten = naturals |> take(10) |> list();

    write_line("{squares.count} {pairs.count} {lengths.count} {first_ten.count}");
si
```

## 75-display

```ghul
// ghūl by example — 75: how values display.

use IO.Std.write_line
use Ghul

struct Point(x: int public, y: int public);

displaying() is
    let xs = [1, 2, 3];
    let found: string? = null;

    // $ writes a value as interpolation does: sequences in brackets, tuples
    // in parentheses, records as type and members, an absent value as null
    write_line("{$(xs)} {$((1, "one"))} {$(Point(3, 4))} {true} {found}");

    // inspect has the same structure but quotes strings and characters
    // inside a value; a string passed directly is written unquoted
    write_line("{inspect(xs)} {inspect("top")} {inspect((1, "one", 'c', true))}");

    // a type with its own to_string (or public members) is written by it
    write_line("{Point(1, 2)}");
si
```

## 80-classes-structs

```ghul
// ghūl by example — 80: classes, structs, and primary constructors.
// Name your own types PascalCase. The library names a concrete type in
// UPPER_SNAKE_CASE where it has an abstract alternative you may prefer (LIST,
// MAP, SET) and in PascalCase where it has none (StringBuilder); variants and
// enum members are UPPER_SNAKE_CASE.

use default

// primary constructor: parameters in the header become init parameters;
// a body declaration named _x or x captures the parameter instead
class Person(name: string, age: int) is
    _age;

    init(.., nickname: string) is       // .. expands to the primary parameters
        write_line("{name} aka {nickname} is {_age}");
    si

    describe() -> string => "{name} is {_age}";
si

class Animal abstract is                // abstract: never constructed; its abstract
    name: string;                       // member speak() must be implemented below
    init(name: string) is self.name = name; si
    speak() -> string;
si

class Cat: Animal is
    init(name: string) is super.init(name); si
    speak() -> string => "meow";
si

class Dog(name: string, breed: string public): Animal is
    super(name);                        // passes to the superclass init; no member for name
    speak() -> string => "woof";
    init(.., trick: string) is
        write_line("the {breed} can {trick}");
    si
si

struct Point(x: double public, y: double public);

class Holder(origin: Point field);     // field: a real field, mutable in place

classes() is
    let p = Person("alice", 30);        // the primary init
    let q = Person("bob", 40, "bobby"); // the secondary init

    let c: Animal = Cat("tom");
    write_line("{p.describe()} {q.describe()} {c.speak()} {c.name}");

    // structs are values: == is an error on them; =~ compares members
    let a = Point(1.0, 2.0);
    let b = Point(1.0, 2.0);
    // wrong: a == b
    if a =~ b then
        write_line("equal");
    fi

    // public primary parameters give a synthesised deconstruct
    let (x, y) = a;

    // a struct member of a class must be declared field to mutate in place;
    // a bare declaration is an auto-property, and struct gets are copies
    let h = Holder(a);
    h.origin.x = 9.0;

    let d = Dog("rex", "lab", "fetch");
    write_line("{x} {y} {h.origin.x} {d.breed}");
si
```

## 85-traits-unions-enums

```ghul
// ghūl by example — 85: traits, unions, and enums.

use default

trait Logged is
    log() is                            // a default body: implementors inherit it
        write_line("(no log message)");
    si
si

class Noisy: Logged is
    init() is si
    log() is
        super.log();                    // call the trait default
        write_line("plus my own message");
    si
si

trait Counted is
    count: int, = v;                    // readable and assignable trait property
si

class Tally: Counted is
    count: int public;
    init() is count = 0; si
si

union Tree is
    NODE(left: Tree, right: Tree);
    LEAF(value: int);
si

union Option[T] is
    SOME(value: T);
    NONE;                              // unit variant: one shared instance
si

union Result[T, E] is
    OK(value: T) default;               // default: ? tests OK, ! unwraps its field
    ERROR(error: E);
si

enum Suit is
    HEARTS,
    DIAMONDS,
si

enum Status is
    OK = 200,
    NOT_FOUND = 404,
si

traits() is
    let n = Noisy();
    n.log();

    let t = Tally();
    t.count = t.count + 1;
    write_line("{t.count}");
si

unions() is
    let tree: Tree = Tree.LEAF(42);
    let none: Option[int] = Option.NONE;

    if let leaf: Tree.LEAF = tree then
        write_line("leaf {leaf.value}");
    fi

    // a case over a union is exhaustiveness-checked; with two variants the
    // second arm narrows by elimination as well
    let text = case tree
    when node: Tree.NODE then "node"
    when leaf: Tree.LEAF then "leaf {leaf.value}"
    esac;

    // a default variant makes ? and ! act on it; inside if r? the value is
    // narrowed, so the fields read directly
    let r: Result[int, string] = Result.OK(7);
    if r? then
        write_line("ok {r!}");
    fi

    // enum members are UPPER_SNAKE_CASE through the type, ordered by value
    let s = Suit.HEARTS;
    let st = Status.NOT_FOUND;
    if s == Suit.HEARTS /\ st =~ Status.NOT_FOUND then
        write_line("hearts, {st}");
    fi

    write_line("{text}");
si

// a failed ! returns the error from a function that returns the same union,
// when each other variant's field implements Ghul.Error; elsewhere it throws
union ParseError: Ghul.Error is
    EMPTY;
si

parse(s: string) -> Result[int, ParseError] =>
    if s =~ "" then Result.ERROR(ParseError.EMPTY) else Result.OK(s.length) fi

total(a: string, b: string) -> Result[int, ParseError] => Result.OK(parse(a)! + parse(b)!)

parse_later(s: string) -> Concurrency.Future[Result[int, ParseError]] => Concurrency.Future.from_result(parse(s))

// await binds before a trailing !, so this awaits, then unwraps or throws
doubled(s: string) -> Concurrency.Future[int] is
    return await parse_later(s)! * 2;
si

// partial adds members to an already-declared type; impl also makes the
// target implement a trait (both same-assembly only)
partial Tally is
    reset() is count = 0; si
si

trait Printable is
    print_out() -> string;
si

impl Printable for Tally is
    print_out() -> string => "count {count}";
si
```

## 90-operators-equality

```ghul
// ghūl by example — 90: operators and equality.

use default

struct Num(v: int) is
    // a member operator takes its left operand as self
    ⊕(other: Num) -> Num => Num(v + other.v);
si

// a namespace-scope operator gives one to a type you did not write
⊗(a: Num, b: Num) -> Num => Num(a.v * b.v)

class Box: Ghul.Comparable[Box], Ghul.Equatable[Box] is
    _v: int;
    init(v: int) is _v = v; si
    <>(other: Box) -> int => _v - other._v;    // <> gives all four relational operators
    =~(other: Box) -> bool => _v == other._v;
    get_hash_code() -> int => _v;               // =~ and get_hash_code go together
si

operators() is
    let sum = Num(1) ⊕ Num(2);
    let product = Num(3) ⊗ Num(4);

    // precedence comes from an operator's first character: × before +,
    // + before bitwise, shifts, then range, pipes, comparison, boolean;
    // ** is above ×, and groups to the left like the rest
    let m = 2 + 3 * 4;               // 14
    let p = 2 * 3 ** 2;              // 18: ** comes from use default

    // \ is the bitwise complement, the unary partner of & | ^
    let complement = \5;             // -6 for an int

    // the boolean operators are /\ and \/ (each one token)
    let both = true /\ false;
    let either = true \/ false;

    write_line("{sum.v} {product.v} {m} {p} {complement} {both} {either}");
si

equality() is
    let a = Box(1);
    let b = Box(1);

    // == is identity: one machine comparison, never overloaded, and only
    // legal on scalars, enums and references
    let identical = a == b;          // false: different objects

    // =~ is equality of meaning: the declared operator runs
    let equal = a =~ b;              // true

    // <> drives the relational operators
    let ordered = a < b;             // false

    write_line("{identical} {equal} {ordered}");
si
```

## 95-generics

```ghul
// ghūl by example — 95: generics.

use default

trait Named is
    name: string;
si

trait Sized is
    size: int;
si

class Player(name: string public): Named is si

struct Box[T] is
    item: T;
    init(item: T) is self.item = item; si
si

print_something[T](value: T) is
    write_line("something is {value}");

si
// a bound makes T behave as the bound type
greet[T: Named](x: T) is
    write_line("hello {x.name}");

si
// several bounds joined with /\ ; kind constraints (class, struct, optional,
// init) combine with type bounds, space-separated
describe2[T: Named /\ Sized class](x: T) is
    write_line("{x.name}: {x.size}");

si
find_boxed[T: class init](key: string) -> T => throw Ghul.Exception("not found");

generics() is
    print_something(1234);             // T inferred from the argument
    print_something[int](1234);        // explicit type arguments

    let b = Box("hello");             // Box[string], from the constructor arg
    let n = Box(42);                  // Box[int]

    // write the type argument explicitly when neither the arguments nor
    // any later use decides it: Box[int](default_value)
    greet(Player("alice"));

    write_line("{b.item} {n.item}");
si
```

## 97-dotnet-async

```ghul
// ghūl by example — 97: .NET interop and asynchronous code.

use default

// .NET names convert: members become snake_case; System.Console is IO.Std,
// System.Text.StringBuilder is Text.StringBuilder,
// System.Collections.Generic is Collections, System.IO is IO.

interop() is
    let root = sqrt(2.0);                       // Ghul.Math, from use default
    let rnd = Ghul.Random();
    let next = rnd.next(100);
    let sb = Text.StringBuilder();
    sb.append("hello");
    sb.append_line("world");
    let text = sb.to_string();

    // nested .NET types join names with an underscore
    let home = System.Environment.get_folder_path(System.Environment_SpecialFolder.USER_PROFILE);

    // indexers are reached with [], whatever the underlying property is called
    let ch = "hello"[1];

    // a function referred to by name converts to a delegate type directly;
    // a stored function value does not, and needs the delegate constructor
    let xs = Collections.LIST[int]([3, 1, 2]);
    xs.sort(compare_descending);                     // by name: converts
    let compare = (a: int, b: int) -> int => b - a;  // a stored function value
    xs.sort(System.Comparison[int](compare));        // wrapped explicitly

    write_line("{root} {next} {text} {home} {ch} {xs[0]}");
si

compare_descending(a: int, b: int) -> int => b - a

// attributes are written as pragmas: positional, named, arrays and typeof
@Ghul.Obsolete("use Product instead")
class LegacyProduct is
    init() is si
si

// asynchronous code: declaring Concurrency.Future[T] as the return type makes await
// available in the body
double_async(n: int) -> Concurrency.Future[int] => Concurrency.Future.from_result(n * 2)

compute_async() -> Concurrency.Future[int] is
    let a = await double_async(10);     // await is an expression; suspends here
    let b = await double_async(a);
    return b;                           // a bare T return is wrapped for you
si

// top-level statements can await too, and an entry can return a Future (see 10)
```

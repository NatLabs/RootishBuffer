import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";

import ActorSpec "./utils/ActorSpec";

import StableRootishBuffer "../src/StableRootishBuffer";

let {
    assertTrue;
    assertFalse;
    assertAllTrue;
    describe;
    it;
    skip;
    pending;
    run;
} = ActorSpec;

let success = run([
    describe(
        " StableRootishBuffer ",
        [
            it(
                "init()",
                do {
                    let buffer = StableRootishBuffer.init();
                    assertAllTrue([
                        StableRootishBuffer.size(buffer) == 0,
                        StableRootishBuffer.capacity(buffer) == 0,
                    ]);
                },
            ),

            it(
                "add() / get()",
                do {
                    let buffer = StableRootishBuffer.init();
                    StableRootishBuffer.add(buffer, 1);
                    StableRootishBuffer.add(buffer, 2);
                    StableRootishBuffer.add(buffer, 3);
                    StableRootishBuffer.add(buffer, 4);

                    assertAllTrue([
                        StableRootishBuffer.size(buffer) == 4,
                        StableRootishBuffer.capacity(buffer) == 10,
                        StableRootishBuffer.get(buffer, 0) == 1,
                        StableRootishBuffer.get(buffer, 1) == 2,
                        StableRootishBuffer.get(buffer, 2) == 3,
                        StableRootishBuffer.get(buffer, 3) == 4,
                    ]);
                },
            ),

            it(
                "toArray()",
                do {
                    let buffer = StableRootishBuffer.init();
                    StableRootishBuffer.add(buffer, 1);
                    StableRootishBuffer.add(buffer, 2);
                    StableRootishBuffer.add(buffer, 3);
                    StableRootishBuffer.add(buffer, 4);

                    assertAllTrue([
                        StableRootishBuffer.size(buffer) == 4,
                        StableRootishBuffer.capacity(buffer) == 10,
                        StableRootishBuffer.toArray(buffer) == [1, 2, 3, 4],
                    ]);
                },
            ),

            it(
                "fromArray()",
                do {
                    let buffer = StableRootishBuffer.fromArray([1, 2, 3, 4]);

                    assertAllTrue([
                        StableRootishBuffer.size(buffer) == 4,
                        StableRootishBuffer.capacity(buffer) == 10,
                        StableRootishBuffer.get(buffer, 0) == 1,
                        StableRootishBuffer.get(buffer, 1) == 2,
                        StableRootishBuffer.get(buffer, 2) == 3,
                        StableRootishBuffer.get(buffer, 3) == 4,
                    ]);
                },
            ),

            it(
                "put()",
                do {
                    let buffer = StableRootishBuffer.fromArray([1, 2, 3, 4]);
                    StableRootishBuffer.put(buffer, 0, 4);
                    StableRootishBuffer.put(buffer, 3, 1);

                    assertAllTrue([
                        StableRootishBuffer.size(buffer) == 4,
                        StableRootishBuffer.capacity(buffer) == 10,
                        StableRootishBuffer.get(buffer, 0) == 4,
                        StableRootishBuffer.get(buffer, 1) == 2,
                        StableRootishBuffer.get(buffer, 2) == 3,
                        StableRootishBuffer.get(buffer, 3) == 1,
                    ]);
                },
            ),
            it(
                "removeLast()",
                do {
                    let buffer = StableRootishBuffer.fromArray([1, 2, 3, 4]);

                    assertAllTrue([
                        StableRootishBuffer.size(buffer) == 4,
                        StableRootishBuffer.capacity(buffer) == 10,

                        StableRootishBuffer.removeLast(buffer) == ?4,
                        StableRootishBuffer.removeLast(buffer) == ?3,

                        StableRootishBuffer.size(buffer) == 2,
                        StableRootishBuffer.capacity(buffer) == 6,

                        StableRootishBuffer.removeLast(buffer) == ?2,
                        StableRootishBuffer.removeLast(buffer) == ?1,

                        StableRootishBuffer.size(buffer) == 0,
                        StableRootishBuffer.capacity(buffer) == 3,

                        StableRootishBuffer.removeLast(buffer) == null,
                    ]);
                },
            ),
        ],
    ),
]);

if (success == false) {
    Debug.trap("\1b[46;41mTests failed\1b[0m");
} else {
    Debug.print("\1b[23;42;3m Success!\1b[0m");
};

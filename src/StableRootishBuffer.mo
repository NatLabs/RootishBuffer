import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Iter "mo:base/Iter";

import StableBuffer "mo:OptStableBuffer/StableBuffer";

module {
    type StableBuffer<Nat> = StableBuffer.StableBuffer<Nat>;

    public type RootishBuffer = {
        var count : Nat;
        blocks : StableBuffer<[var Nat]>;
    };

    public func init() : RootishBuffer {
        {
            var count = 0;
            blocks = StableBuffer.init<[var Nat]>();
        };
    };

    public func initPresized(n : Nat) : RootishBuffer {
        let blocks_size = get_block_index(n) + 1;
        let blocks = StableBuffer.initPresized<[var Nat]>(blocks_size);

        for (i in Iter.range(1, blocks_size)) {
            StableBuffer.add(blocks, Array.init<Nat>(i, 1));
        };

        {
            var count = 0;
            blocks;
        };
    };

    public func size(self : RootishBuffer) : Nat {
        self.count;
    };

    func capacity_of(n : Nat) : Nat {
        (n * (n + 1)) / 2;
    };

    public func capacity({ blocks } : RootishBuffer) : Nat {
        let blocks_size = StableBuffer.size(blocks);

        capacity_of(blocks_size);
    };

    func get_block_index(index : Nat) : Nat {
        Int.abs(
            Float.toInt(
                Float.ceil(
                    (-3 + Float.sqrt(Float.fromInt(9 + 8 * index))) / 2,
                ),
            ),
        );
    };

    func inner_block_index(block_index : Nat, i : Nat) : Nat {
        i - capacity_of(block_index);
    };

    // Returns a tuple of the block index and the index of the element in the block
    func get_pos(i : Nat) : (Nat, Nat) {
        let block_index = get_block_index(i);
        (block_index, inner_block_index(block_index, i));
    };

    public func get(self : RootishBuffer, i : Nat) : Nat {
        let (block_index, inner_index) = get_pos(i);
        let block = StableBuffer.get(self.blocks, block_index);

        block[inner_index];
    };

    public func getOpt(self : RootishBuffer, i : Nat) : ?Nat {
        if (i < self.count) {
            ?get(self, i);
        } else {
            null;
        };
    };

    public func put(self : RootishBuffer, i : Nat, val : Nat) {
        assert i < self.count;

        let (block_index, inner_index) = get_pos(i);
        let block = StableBuffer.get(self.blocks, block_index);

        block[inner_index] := val;
    };

    func grow(self : RootishBuffer) {
        let blocks_size = StableBuffer.size(self.blocks);
        if (capacity(self) - blocks_size < self.count + 1) {

            StableBuffer.add(
                self.blocks,
                Array.init<Nat>(blocks_size + 1, 1),
            );
        };
    };

    func shrink(self : RootishBuffer) {
        let blocks_size = StableBuffer.size(self.blocks);

        while (
            get_block_index(capacity(self) - 1) > get_block_index(self.count) + 1,
        ) {
            ignore StableBuffer.removeLast(self.blocks);
        };
    };

    public func insert(self : RootishBuffer, i : Nat, val : Nat) {
        grow(self);
        self.count += 1;

        var j = self.count - 1;

        // shift all elements by 1
        while (j > i) {
            let prev = get(self, j);
            put(self, j + 1, prev);
        };

        put(self, i, val);

    };

    public func add(self : RootishBuffer, val : Nat) {
        insert(self, self.count, val);
    };

    public func remove(self : RootishBuffer, i : Nat) : Nat {
        let elem = get(self, i);

        var j = i;

        while (j < self.count - 1) {
            let right = get(self, j + 1);
            put(self, j, right);
            j += 1;
        };

        self.count -= 1;
        // shrink(self);

        elem;
    };

    public func removeLast(self : RootishBuffer) : ?Nat {
        if (self.count > 0) {
            ?remove(self, self.count - 1);
        } else {
            null;
        };
    };

    public func fromArray(arr : [Nat]) : RootishBuffer {
        let buffer = init();

        for (n in arr.vals()) {
            add(buffer, n);
        };

        buffer;
    };

    public func toArray(self : RootishBuffer) : [Nat] {
        Array.tabulate(self.count, func(i : Nat) : Nat { get(self, i) });
    };

    public func toVarArray(self : RootishBuffer) : [var Nat] {
        Array.tabulateVar(self.count, func(i : Nat) : Nat { get(self, i) });
    };

    public func vals(self : RootishBuffer) : Iter.Iter<Nat> {
        var i = 0;

        object {
            public func next() : ?Nat {
                if (i < self.count) {
                    i += 1;
                    ?get(self, i - 1);
                } else {
                    null;
                };
            };
        };
    };

    public func append(self : RootishBuffer, other : RootishBuffer) {
        for (elem in vals(other)) {
            add(self, elem);
        };
    };

    public func appendArray(self : RootishBuffer, arr : [Nat]) {
        for (elem in arr.vals()) {
            add(self, elem);
        };
    };

    public func clear(self : RootishBuffer) {
        self.count := 0;
    };
};

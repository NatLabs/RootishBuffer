import StableRootishBuffer "StableRootishBuffer";

module {
    public class RootishBuffer<A>() {
        let buffer = StableRootishBuffer.init<A>();

        public func add(val : A) {
            StableRootishBuffer.add(buffer, val);
        };

        public func get(i : Nat) : A {
            StableRootishBuffer.get(buffer, i);
        };

        public func removeLast() : ?A {
            StableRootishBuffer.removeLast(buffer);
        };
    };
};

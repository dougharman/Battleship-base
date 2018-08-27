pragma solidity ^0.4.24;


library CounterLib {
    struct Counter { uint i; }

    function incremented(Counter storage self) public returns (uint) {
        return ++self.i;
    }
}
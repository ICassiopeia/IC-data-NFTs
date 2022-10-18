import HashMap "mo:base/HashMap";
import Result "mo:base/Result";

import T "./types";

module {

  public func hash(x : Nat32) : Nat32 {
    return x;
  };

  public func _exists<A,B>(target: HashMap.HashMap<A, B>, id : A) : Bool {
    switch (target.get(id)) {
      case (?result) true;
      case (_) false;
    };
  };

  public func _hashMapGetWithResult<A,B>(target: HashMap.HashMap<A, B>, id : A) : Result.Result<B, Text> {
    switch (target.get(id)) {
      case (?result) {
				return #ok(result);
      };
      case (_) {
        return #err("Not Found");
      };
    };
  };

};

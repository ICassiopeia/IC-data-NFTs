import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import List "mo:base/List";
import Bool "mo:base/Bool";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Nat32 "mo:base/Nat32";
import Option "mo:base/Option";
import Time "mo:base/Time";

import ExtNonFungible "../toniq-ext/motoko/ext/NonFungible";
import ExtCore "../toniq-ext/motoko/ext/Core";

import T "../libs/types";
import L "../libs/libs";
import A "../libs/admin";

import FNFT "canister:F-NFT";

actor DatasetNFT {
  
  private stable var _datasetsState : [(Nat32, T.DatasetConfiguration)] = [];
  private var _datasets : HashMap.HashMap<Nat32, T.DatasetConfiguration> = HashMap.fromIter(_datasetsState.vals(), 0, Nat32.equal, L.hash);
  
  private stable var _datasetValuesState : [(Nat32, [T.DatasetEntry])] = [];
  private var _datasetValues : HashMap.HashMap<Nat32, [T.DatasetEntry]> = HashMap.fromIter(_datasetValuesState.vals(), 0, Nat32.equal, L.hash);
  
  private stable var _datasetProducersState : [(Nat32, [Principal])] = [];
  private var _datasetProducers : HashMap.HashMap<Nat32, [Principal]> = HashMap.fromIter(_datasetProducersState.vals(), 0, Nat32.equal, L.hash);
  
  // private stable var _mintingAuthority : Principal = Principal.fromText(CanisterIds.serviceCanisterId);
  private stable var _nextDatasetId : Nat32  = 0;
  private stable var _nextDimensionId : Nat32  = 0;

  //State functions
  system func preupgrade() {
    _datasetsState := Iter.toArray(_datasets.entries());
    _datasetValuesState := Iter.toArray(_datasetValues.entries());
    _datasetProducersState := Iter.toArray(_datasetProducers.entries());
  };
  system func postupgrade() {
    _datasetsState := [];
    _datasetValuesState := [];
    _datasetProducersState := [];
  };

  // CREATE
  public shared({caller}) func createDataSet(request: T.DatasetCreateRequest) : async Nat32 {
		_nextDatasetId := _nextDatasetId + 1;
    assert(L._exists<Nat32, T.DatasetConfiguration>(_datasets, _nextDatasetId) == false);
    // Create dataset
    let _datasetConfig = {
      name=request.datasetConfig.name;
      assetId=request.datasetConfig.assetId;
      dimensions=request.datasetConfig.dimensions;
      createdAt=Time.now();
      updatedAt=Time.now();
    };
		_datasets.put(_nextDatasetId, _datasetConfig);
    // Configure init producer
		_datasetProducers.put(_nextDatasetId, [caller]);
    // Mint NFT
    let nftRequest: ExtNonFungible.MintRequest = {to= #principal(caller); metadata=?request.metadataNFT};
    let _ = await FNFT.mintNFT(
      _nextDatasetId,
      nftRequest,
      "DATATOKEN" #  Nat32.toText(_nextDatasetId),
      "DTOK" # Nat32.toText(_nextDatasetId),
      request.initialSupply
      );
    _nextDatasetId
	};

  // Producer auth
  public shared({caller}) func getProducers(datasetId : Nat32) : async (?[Principal]) {
    _datasetProducers.get(datasetId)
	};

  public shared({caller}) func isUserProducer(datasetId : Nat32) : async (Bool) {
    switch(_datasetProducers.get(datasetId)) {
      case (?_producers) Option.isSome(Array.find<Principal>(_producers, func(t) { return (Principal.equal(t, caller) == true) }));
      case (_) false;
    };
	};

  public shared({caller}) func updateProducerList(datasetId : Nat32, user: Principal, mode: T.UpdateMode) : async () {
    assert(await FNFT.isOwner(caller, datasetId));
    switch(_datasetProducers.get(datasetId)) {
      case (?_entryList) {
        let filteredArray = Array.filter<Principal>(_entryList, func(t) { return (Principal.equal(t, user) == false) } );
        if((mode == #Add) and Nat.notEqual(filteredArray.size(), _entryList.size())) {
          _datasetProducers.put(datasetId, List.toArray(List.push<Principal>(user, List.fromArray(filteredArray))));
        } else {
          _datasetProducers.put(datasetId, filteredArray);
        };
      };
      case (_) {
        if(mode == #Add) {
          _datasetProducers.put(datasetId, Array.make<Principal>(user));
        };
      };
    };
	};

  // Read
  public query({caller}) func getUserDataByDatasetId(datasetId : Nat32) : async ([T.DatasetEntry]) {
    switch(_datasetValues.get(datasetId)) {
      case (?_entryList) {
        Array.filter<T.DatasetEntry>(_entryList, func(t) { return T.RecordKey.equal(t.id, #user(caller)) } );
      };
      case (_) {
        []
      };
    };
	};

  public query func getDatasetByDatasetId(datasetId : Nat32) : async (?T.DatasetConfiguration) {
    _datasets.get(datasetId);
	};

  public query func getDatasetEntryCounts(datasetIds: [Nat32]) : async [(Nat32, Nat)] {
    let idList = List.fromArray(datasetIds);
    let isInList = func (x : Nat32, y: [T.DatasetEntry]) : ?[T.DatasetEntry] {if(List.some<Nat32>(idList, func (z: Nat32): Bool = (Nat32.equal(x, z)))) ?y else null };
    let filteredList = HashMap.mapFilter<Nat32, [T.DatasetEntry], [T.DatasetEntry]>(_datasetValues, Nat32.equal, L.hash, isInList);
    var res = Buffer.Buffer<(Nat32, Nat)>(1);
    for(item in filteredList.entries()) {
      res.add((item.0, item.1.size()));
    };
    res.toArray()
	};

  // Update
  public shared({caller}) func putEntry(datasetId: Nat32, datasetValue: T.DatasetEntryInput, mode: T.UpdateMode) : () {
    // assert(Principal.equal(datasetValue.user, caller));
    let _entry: T.DatasetEntry = {
    id=datasetValue.id;
    values=datasetValue.values;
    createdAt=Time.now();
    updatedAt=Time.now();
    };
    switch(_datasetValues.get(datasetId)) {
      case (?_entryList) {
        let filterFn = func(t: T.DatasetEntry): Bool { return T.RecordKey.equal(t.id, _entry.id)};
        let filteredArray = Array.filter<T.DatasetEntry>(_entryList, filterFn);
        if(mode == #Add) {
          _datasetValues.put(datasetId, List.toArray(List.push<T.DatasetEntry>(_entry, List.fromArray(filteredArray))));
        } else {
          _datasetValues.put(datasetId, filteredArray);
        };
      };
      case (_) {
        if(mode == #Add) {
          _datasetValues.put(datasetId, Array.make<T.DatasetEntry>(_entry));
        };
      };
    };
  };
 
  public shared({caller}) func putManyEntries(datasetId: Nat32, datasetValues: [T.DatasetEntryInput]) : () {
    // Check ownership or
    for(_entry in Iter.fromArray(datasetValues)) {
      putEntry(datasetId, _entry, #Add);
    };
  };

  // Delete
  public shared({caller}) func deleteDataNFT(datasetId : Nat32) : async () {
    assert(await FNFT.isOwner(caller, datasetId));
    _datasets.delete(datasetId);
	};

  public shared({caller}) func deleteUserEntry(datasetId : Nat32) : async Bool {
    switch(_datasetValues.get(datasetId)) {
      case (?_entryList) {
        let filteredArray = Array.filter<T.DatasetEntry>(_entryList, func(t) { return T.RecordKey.equal(t.id, #user(caller))});
        if(Nat.notEqual(filteredArray.size(), _entryList.size())) {
          _datasetValues.put(datasetId, filteredArray);
          true
        } else false
      };
      case (_) false;
    };
	};

  // GDPR - Data Protection
  public shared({caller}) func deleteAllEntriesOfUser(datasetId : Nat32) : async Bool {
    switch(_datasetValues.get(datasetId)) {
      case (?_entryList) {
        let filteredArray = Array.filter<T.DatasetEntry>(_entryList, func(t) { return T.RecordKey.equal(t.id, #user(caller))} );
        if(Nat.notEqual(filteredArray.size(), _entryList.size())) {
          _datasetValues.put(datasetId, filteredArray);
          true
        } else false
      };
      case (_) false;
    };
	};

  // Analytical functions
  public query({caller}) func getDataByDatasetId(datasetId : Nat32) : async (?[T.DatasetEntry]) {
    _datasetValues.get(datasetId)
	};

  public query({caller}) func getRowsByDatasetId(datasetId : Nat32, rows: Int) : async (?T.DatasetEntry) {
    // let _entries = _datasetValues.get(datasetId);
    switch (_datasetValues.get(datasetId)) {
      case(?_entries) Iter.fromArray<T.DatasetEntry>(_entries).next();
      case(_) null
    };
	};

  public query({caller}) func getGDPRAggregatedDataset(datasetId : Nat32, attributeId : Nat32, metricId : Nat32) : async ([(T.Value, {count: Nat32; sum: Nat32})]) {
    let limit:Nat32 = 5;
    let findAttribute = func(val : T.DatasetValue) : (Bool) {Nat32.equal(val.dimensionId, attributeId)};
    let findMetric = func(val : T.DatasetValue) : (Bool) {Nat32.equal(val.dimensionId, metricId)};
    let init : [(T.Value, {count: Nat32; sum: Nat32})] = [];
    let result: HashMap.HashMap<T.Value, {count: Nat32; sum: Nat32}> = HashMap.fromIter(init.vals(), 0, T.Value.equal, T.Value.hash);
    switch(_datasetValues.get(datasetId)) {
      case (?_entries) {
        for(_entry in Iter.fromArray(_entries)) {
          switch(Array.find(_entry.values, findAttribute)) { // Find attribute
            case(?_att) {
              switch(Array.find(_entry.values, findMetric)) { // Find metric
                case(?_met) {
                  switch(result.get(_att.value)) {
                    case(?_res) {
                      switch(_met.value) {
                        case(#metric(val)) result.put(_att.value, {count=_res.count+1; sum=_res.sum+val});
                        case(#attribute(val)) result.put(_att.value, {count=_res.count+1; sum=_res.sum});
                      };
                    };
                    case(_) {
                      switch(_met.value) {
                        case(#metric(val)) result.put(_att.value, {count=1; sum=val});
                        case(#attribute(val)) result.put(_att.value, {count=1; sum=0});
                      };
                    };
                  };
                };
                case(_) {};
              };
            };
            case(_) {};
          };
        };
      };
      case (_) {};
    };

    let resArray = Iter.toArray<(T.Value, {count: Nat32; sum: Nat32})>(result.entries());
    Array.filter<(T.Value, {count: Nat32; sum: Nat32})>(resArray, func(val : (T.Value, {count: Nat32; sum: Nat32})) : (Bool) {Nat32.less(val.1.count, limit)})
	};

}


import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Hash "mo:base/Hash";

import ExtNonFungible "../toniq-ext/motoko/ext/NonFungible";

module {

  public type DatasetCreateRequest = {
    metadataNFT: Blob;
    initialSupply: Nat;
    datasetConfig: DatasetConfigurationInput;
  };

  public type DimensionType = {
    #Binary;
    #Categorical: [Text];
    #Numerical;
  };

  public type DatasetConfiguration = {
    name : Text;
    assetId : Text;
    dimensions: [DatasetDimension];
    createdAt: Int;
    updatedAt: Int;
  };

  public type DatasetConfigurationInput = {
    name : Text;
    assetId : Text;
    dimensions: [DatasetDimension];
  };

  public type DatasetDimension = {
    dimensionId : Nat32;
    title : Text;
    dimensionType : DimensionType;
  };

  public type RecordKey = {
    #user : Principal;
    #id : Nat32;
  };

  public module RecordKey = {
    public func equal(x : RecordKey, y : RecordKey) : Bool {
      return switch(x) {
        case(#user(x1)) switch(y) {
            case(#user(y1)) (Principal.equal(x1, y1) == false);
            case(#id(_)) true;
          };
        case(#id(x2))  switch(y) {
          case(#user(_)) true;
          case(#id(y2)) (Nat32.equal(x2, y2) == false);
        };
      };
    };
    // public func hash(x : RecordKey) : Hash.Hash {
    //   return x;
    // };
  };

  public type Value = {
    #metric : Nat32;
    #attribute : Text;
  };

  public module Value = {
    public func equal(x : Value, y : Value) : Bool {
      return switch(x) {
        case(#metric(x1)) switch(y) {
            case(#metric(y1)) (Nat32.equal(x1, y1) == false);
            case(#attribute(_)) true;
          };
        case(#attribute(x2))  switch(y) {
          case(#metric(_)) true;
          case(#attribute(y2)) (Text.equal(x2, y2) == false);
        };
      };
    };
    public func hash(x : Value) : Hash.Hash {
      return switch(x) {
        case(#metric(x1)) return x1;
        case(#attribute(x2)) return Text.hash(x2);
      };
    };
  };

  public type DatasetEntry = {
    id : RecordKey;
    values : [DatasetValue];
    createdAt: Int;
    updatedAt: Int;
  };

  public type DatasetEntryInput = {
    id : RecordKey;
    values : [DatasetValue];
  };

  public type DatasetValue = {
    dimensionId : Nat32;
    value : Value;
  };

  public type DatasetType = {
    datasetId : Nat32;
    datasetConfig: DatasetConfiguration;
    entries : [DatasetEntry];
  };

  public type UpdateMode = {
    #Add;
    #Remove;
  };



}
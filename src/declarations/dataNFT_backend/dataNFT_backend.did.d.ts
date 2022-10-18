import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface DatasetConfiguration {
  'assetId' : string,
  'name' : string,
  'createdAt' : bigint,
  'updatedAt' : bigint,
  'dimensions' : Array<DatasetDimension>,
}
export interface DatasetConfigurationInput {
  'assetId' : string,
  'name' : string,
  'dimensions' : Array<DatasetDimension>,
}
export interface DatasetCreateRequest {
  'metadataNFT' : Array<number>,
  'initialSupply' : bigint,
  'datasetConfig' : DatasetConfigurationInput,
}
export interface DatasetDimension {
  'title' : string,
  'dimensionId' : number,
  'dimensionType' : DimensionType,
  'values' : Array<string>,
}
export interface DatasetEntry {
  'id' : RecordKey,
  'createdAt' : bigint,
  'values' : Array<DatasetValue>,
  'updatedAt' : bigint,
}
export interface DatasetEntryInput {
  'id' : RecordKey,
  'values' : Array<DatasetValue>,
}
export interface DatasetValue { 'dimensionId' : number, 'value' : string }
export type DimensionType = { 'Binary' : null } |
  { 'Numerical' : null } |
  { 'Categorical' : null };
export type RecordKey = { 'id' : number } |
  { 'user' : Principal };
export type UpdateMode = { 'Add' : null } |
  { 'Remove' : null };
export interface _SERVICE {
  'createDataSet' : ActorMethod<[DatasetCreateRequest], number>,
  'deleteAllEntriesOfUser' : ActorMethod<[number], boolean>,
  'deleteDataNFT' : ActorMethod<[number], undefined>,
  'deleteEntry' : ActorMethod<[number], boolean>,
  'getAllData' : ActorMethod<[], Array<[number, Array<DatasetEntry>]>>,
  'getDataByDatasetId' : ActorMethod<[number], [] | [Array<DatasetEntry>]>,
  'getDatasetByDatasetId' : ActorMethod<[number], [] | [DatasetConfiguration]>,
  'getDatasetEntryCounts' : ActorMethod<
    [Array<number>],
    Array<[number, bigint]>,
  >,
  'getProducers' : ActorMethod<[number], [] | [Array<Principal>]>,
  'getUserDataByDatasetId' : ActorMethod<[number], Array<DatasetEntry>>,
  'isUserProducer' : ActorMethod<[number], boolean>,
  'putEntry' : ActorMethod<[number, DatasetEntryInput, UpdateMode], undefined>,
  'putManyEntries' : ActorMethod<[number, Array<DatasetEntryInput>], undefined>,
  'updateProducerList' : ActorMethod<
    [number, Principal, UpdateMode],
    undefined,
  >,
}

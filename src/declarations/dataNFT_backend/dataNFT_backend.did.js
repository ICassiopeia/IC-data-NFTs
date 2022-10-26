export const idlFactory = ({ IDL }) => {
  const DimensionType = IDL.Variant({
    'Binary' : IDL.Null,
    'Numerical' : IDL.Null,
    'Categorical' : IDL.Vec(IDL.Text),
  });
  const DatasetDimension = IDL.Record({
    'title' : IDL.Text,
    'dimensionId' : IDL.Nat32,
    'dimensionType' : DimensionType,
  });
  const DatasetConfigurationInput = IDL.Record({
    'assetId' : IDL.Text,
    'name' : IDL.Text,
    'dimensions' : IDL.Vec(DatasetDimension),
  });
  const DatasetCreateRequest = IDL.Record({
    'metadataNFT' : IDL.Vec(IDL.Nat8),
    'initialSupply' : IDL.Nat,
    'datasetConfig' : DatasetConfigurationInput,
  });
  const RecordKey = IDL.Variant({ 'id' : IDL.Nat32, 'user' : IDL.Principal });
  const Value = IDL.Variant({ 'metric' : IDL.Nat32, 'attribute' : IDL.Text });
  const DatasetValue = IDL.Record({
    'dimensionId' : IDL.Nat32,
    'value' : Value,
  });
  const DatasetEntry = IDL.Record({
    'id' : RecordKey,
    'createdAt' : IDL.Int,
    'values' : IDL.Vec(DatasetValue),
    'updatedAt' : IDL.Int,
  });
  const DatasetConfiguration = IDL.Record({
    'assetId' : IDL.Text,
    'name' : IDL.Text,
    'createdAt' : IDL.Int,
    'updatedAt' : IDL.Int,
    'dimensions' : IDL.Vec(DatasetDimension),
  });
  const DatasetEntryInput = IDL.Record({
    'id' : RecordKey,
    'values' : IDL.Vec(DatasetValue),
  });
  const UpdateMode = IDL.Variant({ 'Add' : IDL.Null, 'Remove' : IDL.Null });
  return IDL.Service({
    'createDataSet' : IDL.Func([DatasetCreateRequest], [IDL.Nat32], []),
    'deleteAllEntriesOfUser' : IDL.Func([IDL.Nat32], [IDL.Bool], []),
    'deleteDataNFT' : IDL.Func([IDL.Nat32], [], []),
    'deleteUserEntry' : IDL.Func([IDL.Nat32], [IDL.Bool], []),
    'getDataByDatasetId' : IDL.Func(
        [IDL.Nat32],
        [IDL.Opt(IDL.Vec(DatasetEntry))],
        ['query'],
      ),
    'getDatasetByDatasetId' : IDL.Func(
        [IDL.Nat32],
        [IDL.Opt(DatasetConfiguration)],
        ['query'],
      ),
    'getDatasetEntryCounts' : IDL.Func(
        [IDL.Vec(IDL.Nat32)],
        [IDL.Vec(IDL.Tuple(IDL.Nat32, IDL.Nat))],
        ['query'],
      ),
    'getGDPRAggregatedDataset' : IDL.Func(
        [IDL.Nat32, IDL.Nat32, IDL.Nat32],
        [
          IDL.Vec(
            IDL.Tuple(
              Value,
              IDL.Record({ 'sum' : IDL.Nat32, 'count' : IDL.Nat32 }),
            )
          ),
        ],
        ['query'],
      ),
    'getProducers' : IDL.Func(
        [IDL.Nat32],
        [IDL.Opt(IDL.Vec(IDL.Principal))],
        [],
      ),
    'getRowsByDatasetId' : IDL.Func(
        [IDL.Nat32, IDL.Int],
        [IDL.Opt(DatasetEntry)],
        ['query'],
      ),
    'getUserDataByDatasetId' : IDL.Func(
        [IDL.Nat32],
        [IDL.Vec(DatasetEntry)],
        ['query'],
      ),
    'isUserProducer' : IDL.Func([IDL.Nat32], [IDL.Bool], []),
    'putEntry' : IDL.Func(
        [IDL.Nat32, DatasetEntryInput, UpdateMode],
        [],
        ['oneway'],
      ),
    'putManyEntries' : IDL.Func(
        [IDL.Nat32, IDL.Vec(DatasetEntryInput)],
        [],
        ['oneway'],
      ),
    'updateProducerList' : IDL.Func(
        [IDL.Nat32, IDL.Principal, UpdateMode],
        [],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };

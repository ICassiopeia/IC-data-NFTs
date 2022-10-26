var fs = require('fs');
const path = require("path");
const {parse} = require('csv-parse');

const { getActor, getHost } = require('./config');

const ENV = process.env.ENV || "local"
const DEFAULT_HOST = getHost(ENV)

const datasetConfig = {
  name: "Exams dataset from Kaggle",
  assetId: "kaggle_exams_dataset",
  dimensions: [
    {dimensionId : 0, title: "gender", dimensionType: {Categorical: ["male", "female"]}},
    {dimensionId : 1, title: "ethnicity", dimensionType: {Categorical: ["group A", "group B", "group C", "group D", "group E"]}},
    {dimensionId : 2, title: "parental_education", dimensionType: {Categorical: ["high school", "some high school", "associate's degree"]}},
    {dimensionId : 3, title: "lunch", dimensionType: {Categorical: ["free/reduced", "standard"]}},
    {dimensionId : 4, title: "preparation_course", dimensionType: {Categorical: ["completed", "none"]}},
    {dimensionId : 5, title: "math_score", dimensionType: {Numerical: null}},
    {dimensionId : 6, title: "reading_score", dimensionType: {Numerical: null}},
    {dimensionId : 7, title: "writing_score", dimensionType: {Numerical: null}},
  ],
}

const createDatasetRequest = {
  metadataNFT: JSON.stringify({name: datasetConfig.name, assetId: datasetConfig.assetId}).split('').map(x => x.charCodeAt()),
  initialSupply: 100,
  datasetConfig,
}
function getRandomInt(max) {
  return Math.floor(Math.random() * max);
}

const main = async () => {
  const actor = getActor("dataNFT_backend", ENV, DEFAULT_HOST);

  console.log("Mint dataset")
  var datasetId, dataset
  try{
    datasetId = await actor.createDataSet(createDatasetRequest);
    dataset = (await actor.getDatasetByDatasetId(datasetId))[0];
  } catch (e) {
    console.error(e);
  };
  // console.log("Dataset configuration:", dataset)

  console.log("Import dataset")
  try{
    if(datasetId) {
      var datasetEntries=[];
      fs.createReadStream(path.join(__dirname, "exams.csv"))
      .pipe(parse({delimiter: ','}))
      .on('data', function(csvrow) {
        datasetEntries.push({
          id: {id: getRandomInt(100000)},
          values: csvrow.map((val, idx) => {
            const value = idx<5 ? {attribute: val} : {metric: parseInt(val)}
            return {dimensionId: idx, value: value}
          }),
        })
      })
      .on('end',async () => {
        console.log("Uploading data for dataset:", datasetId)
        const BATCH_SIZE = 100
        const chunks = datasetEntries.reduce((resultArray, item, index) => { 
          const chunkIndex = Math.floor(index/BATCH_SIZE)
          if(!resultArray[chunkIndex]) {
            resultArray[chunkIndex] = [] // start a new chunk
          }
          resultArray[chunkIndex].push(item)
          return resultArray
        }, [])
        for(i=0;i<chunks.length;i++) {
          console.log(`Uploading data chunk ${i+1}/${chunks.length}`)
          await actor.putManyEntries(datasetId, chunks[i])
        }
      })
    }
  } catch (e) {
    console.error(e);
  };


};

main();
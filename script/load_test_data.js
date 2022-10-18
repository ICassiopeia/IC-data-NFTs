var fs = require('fs');
const path = require("path");
const {parse} = require('csv-parse');

const { getActor, getHost } = require('./config');

const ENV = process.env.ENV || "local"
const DEFAULT_HOST = getHost(ENV)

// Automate wiht Panda.js
const datasetConfig = {
  name: "Housing market dataset from Kaggle",
  assetId: "kaggle_housing_dataset",
  dimensions: [
    {dimensionId : 1, title: "price", dimensionType: {Numerical: null}, values : []},
    {dimensionId : 2, title: "area", dimensionType: {Numerical: null}, values : []},
    {dimensionId : 3, title: "bedrooms", dimensionType: {Numerical: null}, values : []},
    {dimensionId : 4, title: "bathrooms", dimensionType: {Numerical: null}, values : []},
    {dimensionId : 5, title: "stories", dimensionType: {Numerical: null}, values : []},
    {dimensionId : 6, title: "mainroad", dimensionType: {Numerical: null}, values : []},
    {dimensionId : 7, title: "guestroom", dimensionType: {Numerical: null}, values : []},
    {dimensionId : 8, title: "basement", dimensionType: {Numerical: null}, values : []},
    {dimensionId : 9, title: "hotwaterheating", dimensionType: {Numerical: null}, values : []},
    {dimensionId : 10, title: "parking", dimensionType: {Numerical: null}, values : []},
    {dimensionId : 11, title: "prefarea", dimensionType: {Numerical: null}, values : []},
    {dimensionId : 12, title: "semi-furnished", dimensionType: {Numerical: null}, values : []},
    {dimensionId : 13, title: "unfurnished", dimensionType: {Numerical: null}, values : []},
    {dimensionId : 14, title: "areaperbedroom", dimensionType: {Numerical: null}, values : []},
    {dimensionId : 15, title: "bbratio", dimensionType: {Numerical: null}, values : []},
  ],
}

const createDatasetRequest = {
  metadataNFT: JSON.stringify({name: "Housing market dataset from Kaggle", assetId: "kaggle_housing_dataset"}).split('').map(x => x.charCodeAt()),
  initialSupply: 100,
  datasetConfig,
}
function getRandomInt(max) {
  return Math.floor(Math.random() * max);
}

const main = async () => {
  const actor = getActor("dataNFT_backend", ENV, DEFAULT_HOST);

  console.log("Mint dataset")
  var datasetId
  try{
    datasetId = await actor.createDataSet(createDatasetRequest);
  } catch (e) {
    console.error(e);
  };

  console.log("Import dataset")
  try{
    if(datasetId) {

      var datasetEntries=[];
      fs.createReadStream(path.join(__dirname, "newhousing.csv"))
      .pipe(parse({delimiter: ','}))
      .on('data', function(csvrow) {
        datasetEntries.push({
          id: {id: getRandomInt(100000)},
          values: csvrow.map((val, idx) => {return {dimensionId: idx, value: val}}),
        })
      })
      .on('end',async () => {
        console.log("Uploading data for dataset:", datasetId)
        console.log("Uploading data for dataset:", datasetEntries[0])
        await actor.putManyEntries(datasetId, datasetEntries.slice(0, 1));
      })
    }
  } catch (e) {
    console.error(e);
  };


};

main();
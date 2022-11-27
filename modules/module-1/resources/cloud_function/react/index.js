var fs = require('fs');
const util = require('util');
const readFileAsync = util.promisify(fs.readFile);
let path = require("path");

exports.httpServer = function httpServer(req, res) {
    console.log(req);
    // res.status(200).send('Server is working');
    let bucket = process.env.BUCKET_NAME
    var html = fs.readFileSync(__dirname +'/index.html', 'utf8');
    html = html.replace(/GCP_BUCKET/g,  `https://storage.googleapis.com/${bucket}/build`);
    res.status(200).send(html);
 }
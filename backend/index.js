const express = require("express");
const bodyParser = require('body-parser');
// const bodyParser = require('body-parser');
const app = express();
app.use(bodyParser.text());
const cors = require('cors');
app.use(cors());
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    next();
});


const parser = require('./compiler.js');
app.post("/",(req,res) => {
    console.log(req.body.toString())

    // const textContent = req.body;
    // console.log("This is the request body",req);
    
    // console.log(textCon
    try {
    const arr = parser.parse_and_run_go(req.body.toString())
    console.log(arr)
    // } catch (error){
    //     console.log("THis is the text2",textContent)
    //     console.log(error)
    // }
    //res.send("hi");
    const arr_word = arr.join("\n")
    res.send(arr_word);
    } catch {
    res.send("error in parsing and execution");
    }
    // res.status(200).send('Success');
    //res.send("Hello world 2")
});

app.listen(5000, () => console.log("Server is listening to port 5000"))
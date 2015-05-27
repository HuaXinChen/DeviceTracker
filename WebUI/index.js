var express = require('express');
var app = express();
 
var Parse = require('parse').Parse;

//Parse.initialize("EIpND6CzdgXRq1MvORSD53SZLjjeVyLMUWQXWAAO", "JhYzL8coaYHorczG5usbLuQzINggYa3GEmCdlhFR");

//var Devices = Parse.Object.extend("Devices");
//var query = new Parse.Query(Devices); 

//var displayData = '';


app.use(express.static(__dirname));

app.get('/', function(req, res) {
    
    //res.send(displayData);
    
    res.sendFile(__dirname +'/public/index.html');
    //res.sendFile(__dirname +'/public/css/styles.css');
    
    /*query.find({
        success: function(devices) {
            for (var i = 0; i < devices.length; i++) {
                displayData += devices[i].get('deviceid').toString() + '/n';
            }
            res.send(displayData);
        }
    });*/
    
});
  
app.listen(3000);

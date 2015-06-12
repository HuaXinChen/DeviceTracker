Parse.Cloud.job("NotifyUser1", function(request, status) {
    notifyLateReturnUsers(status);
});

Parse.Cloud.job("NotifyUser2", function(request, status) {
    notifyLateReturnUsers(status);
});

function validateEmail(email) {
    var re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
    return re.test(email);
}

function sendEmailwith(deviceID, model, user) {
    var Mailgun = require('mailgun');
    Mailgun.initialize('sandbox6e52f31b7a044f37839ce035cd213a9e.mailgun.org', 'key-865ba1409c47bf9c1040c278c0637a5b');
    //Find email belongs to late user found in previous query 
    var Users = Parse.Object.extend("Users");
    var userQuery = new Parse.Query(Users);
    userQuery.equalTo("userName", user);
    userQuery.find({
        success: function(users) {
            var email = users[0].get("email");
            if(validateEmail(email)){
                Mailgun.sendEmail({
                    to: email,
                    bcc: "pnidevicetracker@gmail.com",
                    from: "QA@pnimedia.com",
                    subject: model + " is OVERDUE",
                    text: user + ", " + model + " (" + deviceID + ") is now overdue.\n\nPlease return your device as soon as possible, or contact the QA team for an extension.\n\nThanks,\n\nPNI QA Team"
                }, {
                    success: function(httpResponse) {
                        console.log(httpResponse);
                    },
                    error: function(httpResponse) {
                        console.error(httpResponse);
                    }
                });
            }
        },
        error: function(error) {
            console.error(error);
        }
    });
}


function notifyLateReturnUsers(status) {

    var today = new Date();
    var twoDaysAgo = new Date(today);
    twoDaysAgo.setDate(today.getDate());
    
    //Find Device that has not been return by certain time, return the user's name
    var Devices = Parse.Object.extend("Devices");
    var query = new Parse.Query(Devices);
    query.lessThan ("updatedAt",twoDaysAgo);
    query.notEqualTo("user","");
    query.find({
        success: function(results) {
            if(results.length < 0){
                status.success("No late Users, job completed successfully.");
                return;
            }
            
            for (var i = 0; i < results.length; i++) { 
                var deviceID = results[i].get("deviceId");
                var model = results[i].get("model");
                var user = results[i].get("user");

                console.log("User: " + user + ", deviceId: " + deviceID + ", model: " + model);

                sendEmailwith(deviceID, model, user);
            }
        },
        error: function(error) {
            console.error(error);
            status.error("Uh oh, device query went wrong.");
        }
    });
    
    
    
}
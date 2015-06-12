Parse.Cloud.job("notifyLateReturnUser", function(request, status) {
    
    var Mailgun = require('mailgun');
    Mailgun.initialize('sandbox6e52f31b7a044f37839ce035cd213a9e.mailgun.org', 'key-865ba1409c47bf9c1040c278c0637a5b');

    var today = new Date();
    var twoDaysAgo = new Date(today);
    twoDaysAgo.setDate(today.getDate());
    
    var lateUserList = [];
    var emailList = "";
    
    //Find Device that has not been return by certain time, return the user's name
    var Devices = Parse.Object.extend("Devices");
    var query = new Parse.Query(Devices);
    query.lessThan ("updatedAt",twoDaysAgo);
    query.notEqualTo("user","");
    query.find({
        success: function(results) {
            console.log("over two days: " + results);
            for (var i = 0; i < results.length; i++) { 
                var object = results[i];
                lateUserList.push(object.get('user'));
            }
            
            console.log("lateUserList:" + lateUserList);
        
            //Find email belongs to late user found in previous query 
            var Users = Parse.Object.extend("Users");
            var userQuery = new Parse.Query(Users);
            for (var i = 0; i < lateUserList.length; i++)
            {
                userQuery.EqualTo("user",lateUserList[i]);    
            }
            
            userQuery.find({
                success: function(results) {
                    console.log("return late users: " + results);
                    for (var i = 0; i < results.length; i++) { 
                        var object = results[i];
                        emailList += object.get('email') + ",";
                    }
                    
                    console.log("emailList: " + emailList);
                    
                    Mailgun.sendEmail({
                        to: emailList,
                        from: "PNI QA",
                        subject: "You have checkouted QA device is OVERDUE",
                        text: "Please return your device ASAP or talk to QA team for an extension"
                    }, {
                        success: function(httpResponse) {
                            console.log(httpResponse);
                            response.success("Email sent!");
                            status.success("NotifyLateReturnUser completed successfully.");
                        },
                        error: function(httpResponse) {
                            console.error(httpResponse);
                            response.error("Uh oh, something went wrong");
                            status.error("Uh oh, email went wrong.");
                        }
                    });
                    
                },  

                error: function(error) {
                    status.error("Uh oh, user query went wrong.");
                }
            });
        },  

        error: function(error) {
            status.error("Uh oh, device query went wrong.");
        }
        
    });

    
});

function notifyLateReturnUsers(status) {
    var Mailgun = require('mailgun');
    Mailgun.initialize('sandbox6e52f31b7a044f37839ce035cd213a9e.mailgun.org', 'key-865ba1409c47bf9c1040c278c0637a5b');

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
                                subject: deviceID + " is OVERDUE",
                                text: users[0].get("userName") + ", ++is now overdue.\nPlease return your device as soon as possible, or contact the QA team for an extension.\n\nThanks,\n\nPNI QA Team"
                            }, {
                                success: function(httpResponse) {
                                    console.log(httpResponse);
                                    status.success("Notification email sent to " + user);
                                },
                                error: function(httpResponse) {
                                    console.error(httpResponse);
                                    status.error("Uh oh, email went wrong.");
                                }
                            });
                        }
                    },
                    error: function(error) {
                        console.error(error);
                        status.error("Uh oh, user query went wrong.");
                    }
                });
            }
        },
        error: function(error) {
            console.error(error);
            status.error("Uh oh, device query went wrong.");
        }
    });
    
}
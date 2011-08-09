
var PushNotification = function() {

}

PushNotification.prototype.register = function(success, fail, options) {
    PhoneGap.exec(success, fail, "PushNotification", "registerAPN", options);
};

PushNotification.prototype.startNotify = function(notificationCallback) {
    PhoneGap.exec(null, null, "PushNotification", "startNotify", []/* BUG - dies on null */);
};
PushNotification.prototype.log = function(message) {
    PhoneGap.exec(null, null, "PushNotification", "log", [{"msg":message,}]);
};

                                                      
//PhoneGap.addConstructor(function() {
//    if (typeof window.plugins.pushNotification == "undefined") window.plugins.pushNotification = new PushNotification();
//});

PhoneGap.addConstructor(function() 
{
	if(!window.plugins)
	{
		window.plugins = {};
	}
	window.plugins.pushNotification = new PushNotification();
});
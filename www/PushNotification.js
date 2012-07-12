// ///////////////////
(function(){
// ///////////////////

// get local ref to global PhoneGap/Cordova/cordova object for exec function
var cordovaRef = window.PhoneGap || window.Cordova || window.cordova; // old to new fallbacks

var PushNotification = function() {

}

// call this to register for push notifications
PushNotification.prototype.register = function(success, fail, options) {
    cordovaRef.exec(success, fail, "PushNotification", "registerAPN", options);
};

// call this to notify the plugin that the device is ready
PushNotification.prototype.startNotify = function(notificationCallback) {
    cordovaRef.exec(null, null, "PushNotification", "startNotify", []/* BUG - dies on null */);
};

// use this to log from JS to the Xcode console - useful!
PushNotification.prototype.log = function(message) {
    cordovaRef.exec(null, null, "PushNotification", "log", [{"msg":message,}]);
};


PhoneGap.addConstructor(function() 
{
	if(!window.plugins)
	{
		window.plugins = {};
	}
	window.plugins.pushNotification = new PushNotification();
});

// ///////////////////
})();
// ///////////////////
var exec = require('cordova/exec');

exports.chooseFiles = function(successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'MultiSelect', 'chooseFiles', []);
};

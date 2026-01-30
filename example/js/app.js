document.addEventListener('DOMContentLoaded', function() {
    const backButton = document.getElementById('backButton');
    if (backButton) {
        backButton.addEventListener('click', function() {
            window.history.back();
        });
    }
});

// Cordova Device Ready Event
document.addEventListener('deviceready', function() {
    const deviceReadyElement = document.getElementById('deviceready');
    deviceReadyElement?.classList.add('ready');

    deviceReadyElement?.classList.add('configuring');
    DevRev.configure('<APPID>', function() {
        console.log('DevRev SDK configured successfully.');
        deviceReadyElement?.classList.remove('configuring');
        deviceReadyElement?.classList.add('configured');
    }, function(error) {
        console.error('Failed to configure DevRev SDK:', error);
        deviceReadyElement?.classList.remove('configuring');
        deviceReadyElement?.classList.add('error');
    });

    cordova.plugins.firebase.messaging.requestPermission();

    cordova.plugins.firebase.messaging.getToken().then(function(token) {
        console.log('Got device token: ', token);
    });
    cordova.plugins.firebase.messaging.onTokenRefresh(function(refreshedToken) {
        console.log('Refreshed FCM token:', refreshedToken);
    });

    console.log('Running cordova-' + cordova.platformId + '@' + cordova.version);
}, false);

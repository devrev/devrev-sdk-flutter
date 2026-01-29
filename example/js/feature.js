// Feature list for different screens
const featureData = {
    'index.html': [
        {
            title: 'Features',
            list: [
                { text: 'Identification', link: 'identification.html' },
                { text: 'Push Notifications', link: 'pushNotifications.html' },
                { text: 'Support', link: 'support.html' },
                { text: 'Session Analytics', link: 'sessionAnalytics.html' }
            ]
        },
        {
            title: 'Web View',
            list: [
                { text: 'Open Web View', link: 'webView.html' }
            ]
        },
        {
            title: 'Large Scrollable List',
            list: [
                { text: 'Open Large Scrollable List', link: 'largeScrollableList.html' }
            ]
        },
        {
            title: 'Debug',
            list: [
                {
                    text: 'Simulate crash',
                    action: () => {
                        throw new Error('Simulated crash');
                    }
                },
                {
                    text: 'Simulate ANR',
                    action: () => {
                        if (cordova.platformId === 'android') {
                            const startTime = Date.now();
                            while (Date.now() - startTime < 5000) {
                                void 0;
                            }
                        }
                    },
                    condition: () => cordova.platformId === 'android'
                }
            ]
        },
        {
            title: 'Animation',
            list: [
                {
                    text: 'Animation',
                    action: () => {
                        const elements = document.querySelectorAll('a');
                        const animationElement = Array.from(elements).find(el => el.textContent === 'Animation');
                        if (animationElement) {
                            animationElement.style.transition = 'all 2s';
                            animationElement.style.transform = 'scale(1.5)';

                            setTimeout(() => {
                                animationElement.style.transform = 'scale(1)';
                            }, 2000);
                        }
                    },
                    condition: () => cordova.platformId === 'android'
                }
            ],
            condition: () => cordova.platformId === 'android'
        }
    ],
    'identification.html': [
        {
            title: 'Unverified User',
            list: [
                {
                    text: 'Identify User',
                    type: 'input-group',
                    inputs: [
                        {
                            id: 'unverifiedUserId',
                            type: 'text',
                            placeholder: 'User ID'
                        }
                    ],
                    action: () => {
                        const userId = document.getElementById('unverifiedUserId').value;
                        if (userId) {
                            var identity = {
                                userID: userId
                            };
                            currentUserId = userId;
                            DevRev.identifyUnverifiedUser(identity);
                        }
                    }
                }
            ]
        },
        {
            title: 'Verified User',
            list: [
                {
                    text: 'Verify User',
                    type: 'input-group',
                    inputs: [
                        {
                            id: 'verifiedUserId',
                            type: 'text',
                            placeholder: 'User ID'
                        },
                        {
                            id: 'sessionToken',
                            type: 'text',
                            placeholder: 'Session Token'
                        }
                    ],
                    action: () => {
                        const userId = document.getElementById('verifiedUserId').value;
                        const sessionToken = document.getElementById('sessionToken').value;
                        if (userId && sessionToken) {
                            currentUserId = userId;
                            DevRev.verifyUser(userId, sessionToken);
                        }
                    }
                }
            ]
        },
        {
            title: 'Update User',
            list: [
                {
                    text: 'Update User',
                    type: 'input-group',
                    inputs: [
                        {
                            id: 'email',
                            type: 'email',
                            placeholder: 'New Email'
                        }
                    ],
                    action: () => {
                        if (!currentUserId) {
                            alert('Please identify or verify a user first');
                            return;
                        }

                        const email = document.getElementById('email').value;

                        const identity = {
                            userID: currentUserId,
                            userTraits: {
                                email: email
                            }
                        };

                        DevRev.updateUser(identity);
                    }
                }
            ]
        },
        {
            title: 'Logout',
            list: [
                { text: 'Logout', action: () => logout() }
            ]
        }
    ],
    'pushNotifications.html': [
        { title: 'Push Notifications',
            list: [
                { text: 'Register for Push Notifications', action: () => registerDevice() },
                { text: 'Unregister from Push Notifications', action: () => unregisterDevice() }
            ]
        }
    ],
    'support.html': [
        { title: 'Support',
            list: [
                { text: 'Support Chat', action: () => DevRev.createSupportConversation() },
                { text: 'Support View', action: () => DevRev.showSupport() }
            ]
        }
    ],

    'sessionAnalytics.html': [
        { title: 'Session Monitoring',
            list: [
                { text: 'Stop Monitoring', action: () => {
                    DevRev.stopAllMonitoring(
                        () => alert('Monitoring stopped successfully'),
                        (error) => alert('Failed to stop monitoring: ' + error)
                    );
                }},
                { text: 'Resume Monitoring', action: () => {
                    DevRev.resumeAllMonitoring(
                        () => alert('Monitoring resumed successfully'),
                        (error) => alert('Failed to resume monitoring: ' + error)
                    );
                }}
            ]
        },
        {
            title: 'Session Recording',
            list: [
                { text: 'Start Recording', action: () => {
                    DevRev.startRecording(
                        () => alert('Recording started successfully'),
                        (error) => alert('Failed to start recording: ' + error)
                    );
                }},
                { text: 'Stop Recording', action: () => {
                    DevRev.stopRecording(
                        () => alert('Recording stopped successfully'),
                        (error) => alert('Failed to stop recording: ' + error)
                    );
                }},
                { text: 'Pause Recording', action: () => {
                    DevRev.pauseRecording(
                        () => alert('Recording paused successfully'),
                        (error) => alert('Failed to pause recording: ' + error)
                    );
                }},
                { text: 'Resume Recording', action: () => {
                    DevRev.resumeRecording(
                        () => alert('Recording resumed successfully'),
                        (error) => alert('Failed to resume recording: ' + error)
                    );
                }},
                { text: 'Pause User Interaction Tracking', action: () => {
                    DevRev.pauseUserInteractionTracking(
                        () => alert('User interaction tracking paused'),
                        (error) => alert('Failed to pause user interaction tracking: ' + error)
                    );
                }},
                { text: 'Resume User Interaction Tracking', action: () => {
                    DevRev.resumeUserInteractionTracking(
                        () => alert('User interaction tracking has resumed'),
                        (error) => alert('Failed to resume user interaction tracking: ' + error)
                    );
                }}
            ]
        },
        {
            title: 'Timer',
            list: [
                { text: 'Start Timer', action: () => {
                    let properties = {'id': 'foo-bar-123'};
                    DevRev.startTimerWithProperties('Sample Timer', properties,
                        () => alert('Timer started successfully'),
                        (error) => alert('Failed to start timer with properties: ' + error)
                    );
                }},
                { text: 'End Timer', action: () => {
                    let properties = {'id': 'foo-bar-123'};
                    DevRev.endTimerWithProperties('Sample Timer', properties,
                        () => alert('Timer ended successfully'),
                        (error) => alert('Failed to end timer with properties: ' + error)
                    );
                }}
            ]
        },
        {
            title: 'Manual Masking / Unmasking',
            list: [
                {
                    text: 'Manually Masked UI Item',
                    type: 'label',
                    className: 'devrev-mask'
                },
                {
                    text: 'Manually Unmasked UI Item',
                    type: 'input',
                    className: 'devrev-unmask',
                    placeholder: 'Manually Unmasked UI Item'
                }
            ]
        },
        {
            title: 'On-Demand Session',
            list: [
                {
                    text: 'Process On-Demand Session',
                    action: () => {
                        DevRev.processAllOnDemandSessions(
                            () => alert('On-demand sessions processed successfully'),
                            (error) => alert('Failed to process on-demand sessions: ' + error)
                        );
                    }
                }
            ]
        },
        {
            title: 'Delayed Screen',
            list: [
                {
                    text: 'Navigate to the Delayed Screen',
                    action: () => {
                        if (cordova.platformId === 'android') {
                            DevRev.setInScreenTransitioning(true);
                            setTimeout(function() {
                                window.location.href = 'delayedScreen.html';
                            }, 2000);
                        }
                    }
                }
            ],
            condition: () => cordova.platformId === 'android'
        },
    ]
};

let currentUserId = null;

function logout() {
    if(device.uuid) {
        DevRev.logout(device.uuid,
            () => alert('Logged out successfully'),
            (error) => alert('Failed to logout: ' + error)
        );
    } else {
        alert('Device UUID not found');
    }
}

async function registerDevice() {
    try {
        if (!window.device?.uuid) {
            alert('Device UUID not available');
            return;
        }
        await cordova.plugins.firebase.messaging.requestPermission();

        const token = await cordova.plugins.firebase.messaging.getToken();
        if (!token) {
            alert('Failed to retrieve device token');
            return;
        }

        console.log('Got device token:', token);
        DevRev.registerDeviceToken(token, window.device.uuid,
            () => alert('Device registered successfully for push notifications'),
            (error) => alert('Failed to register device: ' + error)
        );

    } catch (error) {
        console.error('Registration failed:', error);
        alert('Registration failed: ' + error.message);
    }
}

async function unregisterDevice() {
    if (!window.device?.uuid) {
        alert('Device UUID not available');
        return;
    }

    DevRev.unregisterDevice(window.device.uuid,
        () => alert('Device unregistered successfully from push notifications'),
        (error) => alert('Failed to unregister device: ' + error)
    );
}

function renderFeatureList() {
    const list = document.getElementById('featureList');
    if (!list) return;

    const screen = window.location.pathname.split('/').pop();
    const featureList = featureData[screen] || [];

    list.innerHTML = '';

    featureList.forEach(section => {
        if(section.condition && !section.condition()) {
            return;
        }
        if (section.title) {
            const header = document.createElement('h3');
            header.textContent = section.title;
            list.appendChild(header);
        }

        if (section.list) {
            const ul = document.createElement('ul');
            ul.className = section.title === 'Manual Masking / Unmasking' ? 'input-group' : 'feature-list';

            section.list.forEach(item => {
                // Skip items that don't meet their condition
                if (item.condition && !item.condition()) {
                    return;
                }

                if (item.type === 'input-group') {
                    // Create input group container
                    const inputGroup = document.createElement('div');
                    inputGroup.className = 'input-group';

                    // Add inputs
                    item.inputs.forEach(input => {
                        const inputElement = document.createElement('input');
                        inputElement.type = input.type;
                        inputElement.id = input.id;
                        inputElement.placeholder = input.placeholder;
                        inputGroup.appendChild(inputElement);
                    });

                    list.appendChild(inputGroup);

                    // Create button list item
                    const li = document.createElement('li');
                    li.style.cursor = 'pointer';

                    if (item.action) {
                        li.addEventListener('click', (e) => {
                            e.preventDefault();
                            item.action();
                            console.log(`"${item.text}" executed successfully.`);
                        });
                    }

                    const a = document.createElement('a');
                    a.textContent = item.text;
                    a.href = '#';
                    a.style.pointerEvents = 'none';
                    a.style.textDecoration = 'none';
                    a.style.color = 'inherit';

                    li.appendChild(a);
                    ul.appendChild(li);
                } else if (item.type === 'input') {
                    const li = document.createElement('li');
                    const input = document.createElement('input');
                    input.type = 'text';
                    input.placeholder = item.placeholder;
                    input.className = item.className;
                    li.appendChild(input);
                    ul.appendChild(li);
                } else if (item.type === 'label') {
                    const li = document.createElement('li');
                    const label = document.createElement('label');
                    label.textContent = item.text;
                    label.className = item.className;
                    li.appendChild(label);
                    ul.appendChild(li);
                } else {
                    const li = document.createElement('li');
                    li.style.cursor = 'pointer';

                    if (item.link) {
                        li.addEventListener('click', () => {
                            window.location.href = item.link;
                        });
                    } else if (item.action) {
                        li.addEventListener('click', (e) => {
                            e.preventDefault();
                            item.action();
                            console.log(`"${item.text}" executed successfully.`);
                        });
                    }

                    const a = document.createElement('a');
                    a.textContent = item.text;
                    a.href = item.link || '#';
                    a.style.pointerEvents = 'none';
                    a.style.textDecoration = 'none';
                    a.style.color = 'inherit';

                    li.appendChild(a);
                    ul.appendChild(li);
                }
            });
            list.appendChild(ul);
        }
    });
}

document.addEventListener('DOMContentLoaded', function() {
    renderFeatureList();

    const currentPage = window.location.pathname.split('/').pop();
    if (currentPage === 'sessionAnalytics.html') {
        const properties = {
            'page': 'session_analytics',
            'timestamp': new Date().toISOString()
        };
        DevRev.addSessionProperties(properties,
            () => console.log('Session properties added successfully'),
            (error) => console.error('Failed to add session properties:', error)
        );
        DevRev.trackScreenName('session-analytics',
            () => console.log('Screen name tracked successfully'),
            (error) => console.error('Failed to track screen name:', error)
        );
    }
});

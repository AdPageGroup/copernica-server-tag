___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Copernica",
  "brand": {
    "displayName": "AdPage"
  },
  "description": "Send user data to Copernica",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "GROUP",
    "name": "authentication",
    "displayName": "Authentication",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "TEXT",
        "name": "apiAccessToken",
        "displayName": "API Access Token",
        "simpleValueType": true,
        "help": "Your Copernica API Access Token",
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ]
      },
      {
        "type": "TEXT",
        "name": "databaseId",
        "displayName": "Database ID",
        "simpleValueType": true,
        "help": "Your Copernica Database ID",
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ]
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "operationType",
    "displayName": "Operation Type",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "RADIO",
        "name": "operation",
        "displayName": "Operation",
        "radioItems": [
          {
            "value": "create",
            "displayValue": "Create Profile"
          },
          {
            "value": "update",
            "displayValue": "Update Profile"
          }
        ],
        "simpleValueType": true,
        "defaultValue": "create"
      },
      {
        "type": "TEXT",
        "name": "profileId",
        "displayName": "Profile ID",
        "simpleValueType": true,
        "help": "Required when updating an existing profile",
        "enablingConditions": [
          {
            "paramName": "operation",
            "paramValue": "update",
            "type": "EQUALS"
          }
        ],
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ]
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "profileFields",
    "displayName": "Profile Fields",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "TEXT",
        "name": "email",
        "displayName": "Email",
        "simpleValueType": true,
        "help": "Email address of the profile (required)",
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ]
      },
      {
        "type": "PARAM_TABLE",
        "name": "fields",
        "displayName": "Additional Fields",
        "paramTableColumns": [
          {
            "param": {
              "type": "TEXT",
              "name": "name",
              "displayName": "Field Name",
              "simpleValueType": true
            },
            "isUnique": true
          },
          {
            "param": {
              "type": "TEXT",
              "name": "value",
              "displayName": "Field Value",
              "simpleValueType": true
            },
            "isUnique": false
          }
        ]
      }
    ]
  }
]

___SANDBOXED_JS_FOR_SERVER___

const sendHttpRequest = require('sendHttpRequest');
const JSON = require('JSON');
const logToConsole = require('logToConsole');

// Prepare the profile data
const profileData = {
  email: data.email
};

// Add additional fields if they exist
if (data.fields && data.fields.length > 0) {
  data.fields.forEach(field => {
    profileData[field.name] = field.value;
  });
}

// Determine the endpoint and method based on operation type
const baseUrl = 'https://api.copernica.com/v4';
let endpoint = '';
let method = '';

if (data.operation === 'create') {
  endpoint = baseUrl + '/database/' + data.databaseId + '/profiles';
  method = 'POST';
} else {
  endpoint = baseUrl + '/database/' + data.databaseId + '/profile/' + data.profileId;
  method = 'PUT';
}

// Send the request
sendHttpRequest(endpoint, (statusCode, headers, body) => {
  if (statusCode >= 200 && statusCode < 300) {
    data.gtmOnSuccess();
  } else {
    logToConsole('Error:', statusCode, body);
    data.gtmOnFailure();
  }
}, {
  method: method,
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ' + data.apiAccessToken
  }
}, JSON.stringify(profileData));


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://api.copernica.com/*"
              }
            ]
          }
        }
      ]
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Create profile with required fields only
  code: |
    const JSON = require('JSON');
    const mockData = {
      apiAccessToken: 'test-token',
      operation: 'create',
      email: 'test@example.com',
      databaseId: '1234'
    };

    mock('sendHttpRequest', function(url, callback, options, body) {
      assertThat(url).isEqualTo('https://api.copernica.com/v4/database/1234/profiles');
      
      const requestData = JSON.parse(body);
      assertThat(requestData.email).isEqualTo('test@example.com');
      assertThat(options.method).isEqualTo('POST');
      assertThat(options.headers['Authorization']).isEqualTo('Bearer test-token');
      
      callback(200);
    });

    runCode(mockData);
    assertApi('gtmOnSuccess').wasCalled();

- name: Create profile with additional fields
  code: |
    const JSON = require('JSON');
    const mockData = {
      apiAccessToken: 'test-token',
      operation: 'create',
      email: 'test@example.com',
      fields: [
        { name: 'firstName', value: 'John' },
        { name: 'lastName', value: 'Doe' }
      ],
      databaseId: '1234'
    };

    mock('sendHttpRequest', function(url, callback, options, body) {
      const requestData = JSON.parse(body);
      
      assertThat(requestData.email).isEqualTo('test@example.com');
      assertThat(requestData.firstName).isEqualTo('John');
      assertThat(requestData.lastName).isEqualTo('Doe');
      assertThat(options.method).isEqualTo('POST');
      
      callback(200);
    });

    runCode(mockData);
    assertApi('gtmOnSuccess').wasCalled();

- name: Update existing profile
  code: |
    const JSON = require('JSON');
    const mockData = {
      apiAccessToken: 'test-token',
      operation: 'update',
      profileId: '12345',
      email: 'test@example.com',
      fields: [
        { name: 'phoneNumber', value: '+31612345678' }
      ],
      databaseId: '1234'
    };

    mock('sendHttpRequest', function(url, callback, options, body) {
      assertThat(url).isEqualTo('https://api.copernica.com/v4/database/1234/profile/12345');
      
      const requestData = JSON.parse(body);
      assertThat(requestData.email).isEqualTo('test@example.com');
      assertThat(requestData.phoneNumber).isEqualTo('+31612345678');
      assertThat(options.method).isEqualTo('PUT');
      
      callback(200);
    });

    runCode(mockData);
    assertApi('gtmOnSuccess').wasCalled();

- name: Failed API request
  code: |
    const mockData = {
      apiAccessToken: 'invalid-token',
      operation: 'create',
      email: 'test@example.com',
      databaseId: '1234'
    };

    mock('sendHttpRequest', function(url, callback, options) {
      callback(401, {}, 'Unauthorized');
    });

    mock('logToConsole', function(message, statusCode, body) {
      assertThat(message).isEqualTo('Error:');
      assertThat(statusCode).isEqualTo(401);
      assertThat(body).isEqualTo('Unauthorized');
    });

    runCode(mockData);
    assertApi('gtmOnFailure').wasCalled();


___NOTES___

Created on 5/21/2024, 1:00:00 PM



___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Copernica",
  "categories": ["EMAIL_MARKETING", "LEAD_GENERATION"],
  "brand": {
    "displayName": "AdPage",
    "thumbnail": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAABCFBMVEUAAAARKmQRKmQRKmQRKmR5Ojj/TwARKmQRKmSIPDIRKmSFPDMRKmSIPTKMPTBOYIyiq8LGzNrq7PH39/rM0d6krsRLXoqMmLTEytlCVYSPPi8TLGWPm7b///9zgqTZ3eZQY421vc/+/v77/P1RZI4tQ3b6+/yLl7RFWYYYMWk1S3yYo7zKz9zd4ekWLmegqsFTZY/v8fV2hKY4TX4ULWbz9Pdeb5YiOW/c4OloeJ2utspUZpAyR3nn6e+7wtORnLezu874+PoVLWZSZI94hqf09fjl6O7Fy9n9/f68w9M8UICstckqQXRgcZiBjq11g6VIW4gcNGsxRnlNX4shOG4RKmQRKmQRKmSp9aF5AAAAWHRSTlMAOsHy////O/3/vf/z////////////////////////////////////////////////////////////////////////////////////////////////Pvw9QywndwAAAQxJREFUeJy9k1lTwkAQhJcwEkA5FBQUghhAUEAB5T4FQUGUw+v//xOT2ZAyMEne6Jft6v52M9mqZcwhOIHQgYuLiW6qVuTRAK9JD3DIgSNTAHwImPecsATAbwcok/4DAsHjk1D49AwiUVXnGF7oQCwuaUpc4pLk+QaIXW16SU7hkjYC+n5dRiBzbQNkeRjN3dzmSaCAWfFO9fccKBmAMmYV9A8UwAcPoH+UiU9UMauhr1MnNDALom9SQ7b4FbUV2+lSgLZL6vUHT+RvDos2FwWlHWBkBOBZb8YT6gSA3Avmr9PZG5rkNgAwf/9YLFcA609VX7sAqX0A5k8P5WXfP1a9W2Tsl37+qpyCg/0BZ1024DImT68AAAAASUVORK5CYII\u003d",
    "id": "brand_custom_template"
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
  code: "const JSON = require('JSON');\nconst mockData = {\n  apiAccessToken: 'test-token',\n\
    \  operation: 'create',\n  email: 'test@example.com',\n  databaseId: '1234'\n\
    };\n\nmock('sendHttpRequest', function(url, callback, options, body) {\n  assertThat(url).isEqualTo('https://api.copernica.com/v4/database/1234/profiles');\n\
    \  \n  const requestData = JSON.parse(body);\n  assertThat(requestData.email).isEqualTo('test@example.com');\n\
    \  assertThat(options.method).isEqualTo('POST');\n  assertThat(options.headers['Authorization']).isEqualTo('Bearer\
    \ test-token');\n  \n  callback(200);\n});\n\nrunCode(mockData);\nassertApi('gtmOnSuccess').wasCalled();\n"
- name: Create profile with additional fields
  code: "const JSON = require('JSON');\nconst mockData = {\n  apiAccessToken: 'test-token',\n\
    \  operation: 'create',\n  email: 'test@example.com',\n  fields: [\n    { name:\
    \ 'firstName', value: 'John' },\n    { name: 'lastName', value: 'Doe' }\n  ],\n\
    \  databaseId: '1234'\n};\n\nmock('sendHttpRequest', function(url, callback, options,\
    \ body) {\n  const requestData = JSON.parse(body);\n  \n  assertThat(requestData.email).isEqualTo('test@example.com');\n\
    \  assertThat(requestData.firstName).isEqualTo('John');\n  assertThat(requestData.lastName).isEqualTo('Doe');\n\
    \  assertThat(options.method).isEqualTo('POST');\n  \n  callback(200);\n});\n\n\
    runCode(mockData);\nassertApi('gtmOnSuccess').wasCalled();\n"
- name: Update existing profile
  code: "const JSON = require('JSON');\nconst mockData = {\n  apiAccessToken: 'test-token',\n\
    \  operation: 'update',\n  profileId: '12345',\n  email: 'test@example.com',\n\
    \  fields: [\n    { name: 'phoneNumber', value: '+31612345678' }\n  ],\n  databaseId:\
    \ '1234'\n};\n\nmock('sendHttpRequest', function(url, callback, options, body)\
    \ {\n  assertThat(url).isEqualTo('https://api.copernica.com/v4/database/1234/profile/12345');\n\
    \  \n  const requestData = JSON.parse(body);\n  assertThat(requestData.email).isEqualTo('test@example.com');\n\
    \  assertThat(requestData.phoneNumber).isEqualTo('+31612345678');\n  assertThat(options.method).isEqualTo('PUT');\n\
    \  \n  callback(200);\n});\n\nrunCode(mockData);\nassertApi('gtmOnSuccess').wasCalled();\n"
- name: Failed API request
  code: |-
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



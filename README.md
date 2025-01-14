# AdPage Copernica Tag

This server tag allows you to send user profile data to Copernica's API. It supports creating new profiles and updating existing ones.

## Authentication

- **API Access Token** - Your Copernica API access token for authentication
- **Database ID** - The ID of your Copernica database where profiles will be stored

## Operation Types

- **Create Profile** - Create a new profile in Copernica
- **Update Profile** - Update an existing profile (requires Profile ID)

## Profile Fields

- **Email** (Required) - The email address for the profile
- **Additional Fields** - Custom fields that can be added to the profile:
  - Field Name - The name of the custom field in Copernica
  - Field Value - The value to be stored for that field

The tag will automatically handle the API communication and provide success/failure feedback in the GTM debug console.

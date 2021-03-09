# Strava Challenge Hunter

Returns a list of challenges on Strava that match the given activity type. When run with a valid credential, the script will inform you if you have joined and completed the listed challenges. It will only return challenges that have not already ended.

## Script Parameters

- **StartNumber** - Contains the starting challenge number to search from.
- **EndNumber** - Contains the challenge number to end at.
- **Credential** - A PowerShell object with the credentials that you would like to use to login to Strava. Will prompt if not provided. If the credentials are not valid, the joined/completed values will not be returned. Only supports Email based login (not Facebook/gmail).

## Usage Example

```PowerShell
.\stravaChallenges.ps1 | Format-Table
```

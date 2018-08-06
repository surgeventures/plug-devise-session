# Changelog

## Unreleased
### Added
- Allow to pass `domain` and `max_age` options to `PlugDeviseSession.Rememberable.remember_user/4`.

## [0.4.0] - 2018-08-03
### Added
- `PlugDeviseSession.Rememberable` module for handling Devise's remember session cookie.

## [0.3.0] - 2018-07-31
### Added
- Function to delete user auth data (`PlugDeviseSession.Helpers.delete_user_auth_data/2`).

## [0.2.0] - 2018-07-29
### Added
- Functions to get and put user auth data (`PlugDeviseSession.Helpers.get_user_auth_data/2` and `PlugDeviseSession.Helpers.put_user_auth_data/4`).

### Deprecated
- `PlugDeviseSession.Helpers.get_user_id/2` in favor of `PlugDeviseSession.Helpers.get_user_auth_data/2`

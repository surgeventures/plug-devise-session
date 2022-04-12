# Changelog

## [1.0.0] - 2022-04-11
### Breaking
- Use `plug_rails_cookie_session_store` version ~> 2.0 to unlock OTP 24 compatibility.

## [0.9.0] - 2020-02-07
### Changed
- Update `PlugDeviseSession` plug to also accept `path`, `secure`, and `max_age` cookie options and the special `extra` options used to add arbitrary cookie options.

## [0.8.0] - 2020-02-07
### Changed
- Update `PlugDeviseSession.Rememberable` to also accept `path`, `secure` cookie options and the special `extra` options used to add arbitrary cookie options.

## [0.7.1] - 2019-09-12
### Changed
- Usage of `DateTime.to_unix` in `PlugDeviseSession.Rememberable` to not use deprecated format anymore.

## [0.7.0] - 2018-10-16
### Added
- Ability to configure cookie key using env variable.

## [0.6.0] - 2018-08-20
### Added
- Function to remove user remember session cookie (`PlugDeviseSession.Rememberable.forget_user/3`).

## [0.5.0] - 2018-08-06
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
